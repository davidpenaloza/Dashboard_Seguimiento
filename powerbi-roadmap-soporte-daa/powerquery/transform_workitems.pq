/*
Power Query M - Transformación de Work Items Azure DevOps (CSV MVP)
- Sin credenciales embebidas.
- Ruta de CSV parametrizable (parámetro pCsvPath).
- Preparado para evolucionar a OData (ver docs/migracion_a_odata.md).
*/
let
    // 1) Parámetro de entrada para la ruta del CSV.
    //    En Power BI Desktop crear parámetro de texto: pCsvPath
    //    Ejemplo: "data/azure_devops_query_sample.csv"
    Source = Csv.Document(
        File.Contents(pCsvPath),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),

    // 2) Promover encabezados.
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    // 3) Limpiar nombres de columnas.
    CleanColumnNames = Table.TransformColumnNames(PromotedHeaders, each Text.Trim(_)),

    // 4) Convertir tipos de datos base y preservar orden original.
    AddSortOrder = Table.AddIndexColumn(CleanColumnNames, "SortOrder", 1, 1, Int64.Type),
    Typed = Table.TransformColumnTypes(
        AddSortOrder,
        {
            {"ID", Int64.Type},
            {"Work Item Type", type text},
            {"Title 1", type text},
            {"Title 2", type text},
            {"Title 3", type text},
            {"Assigned To", type text},
            {"State", type text},
            {"Tags", type text},
            {"SortOrder", Int64.Type}
        }
    ),

    // 5) Normalizar Work Item Type.
    AddWorkItemType = Table.AddColumn(
        Typed,
        "WorkItemType",
        each if [Work Item Type] = null then ""
             else Text.Proper(Text.Trim([Work Item Type])),
        type text
    ),

    // 6) Limpiar estado base.
    AddStateClean = Table.AddColumn(
        AddWorkItemType,
        "StateClean",
        each if [State] = null then "" else Text.Proper(Text.Trim([State])),
        type text
    ),

    // 7) Extraer TrackCode y TrackName desde Title 1 (ej: T01 - Plataforma de Monitoreo).
    AddTrackCode = Table.AddColumn(
        AddStateClean,
        "TrackCode",
        each let t = if [Title 1] = null then "" else Text.Trim([Title 1])
             in if Text.StartsWith(t, "T") and Text.Contains(t, " - ")
                then Text.BeforeDelimiter(t, " - ")
                else null,
        type text
    ),
    AddTrackName = Table.AddColumn(
        AddTrackCode,
        "TrackName",
        each let t = if [Title 1] = null then "" else Text.Trim([Title 1])
             in if Text.StartsWith(t, "T") and Text.Contains(t, " - ")
                then Text.AfterDelimiter(t, " - ")
                else t,
        type text
    ),

    // 8) Reconstrucción de jerarquía.
    AddFeatureTitle = Table.AddColumn(AddTrackName, "FeatureTitle", each Text.Trim(Text.From([Title 1])), type text),
    AddUserStoryTitle = Table.AddColumn(AddFeatureTitle, "UserStoryTitle", each if [Title 2] = null then null else Text.Trim([Title 2]), type text),
    AddTaskTitle = Table.AddColumn(AddUserStoryTitle, "TaskTitle", each if [Title 3] = null then null else Text.Trim([Title 3]), type text),

    // 9) Título visible según tipo.
    AddDisplayTitle = Table.AddColumn(
        AddTaskTitle,
        "DisplayTitle",
        each if [WorkItemType] = "Feature" then [FeatureTitle]
             else if [WorkItemType] = "User Story" then [UserStoryTitle]
             else if [WorkItemType] = "Task" then [TaskTitle]
             else [FeatureTitle],
        type text
    ),

    // 10) Flags booleanos.
    AddIsFeature = Table.AddColumn(AddDisplayTitle, "IsFeature", each [WorkItemType] = "Feature", type logical),
    AddIsUserStory = Table.AddColumn(AddIsFeature, "IsUserStory", each [WorkItemType] = "User Story", type logical),
    AddIsTask = Table.AddColumn(AddIsUserStory, "IsTask", each [WorkItemType] = "Task", type logical),

    // 11) Normalizar Assigned To: Nombre <email>.
    AddAssignedToName = Table.AddColumn(
        AddIsTask,
        "AssignedToName",
        each let a = if [Assigned To] = null then "" else Text.Trim([Assigned To])
             in if a = "" then null
                else if Text.Contains(a, "<") then Text.Trim(Text.BeforeDelimiter(a, "<"))
                else a,
        type text
    ),
    AddAssignedToEmail = Table.AddColumn(
        AddAssignedToName,
        "AssignedToEmail",
        each let a = if [Assigned To] = null then "" else Text.Trim([Assigned To])
             in if a = "" then null
                else if Text.Contains(a, "<") and Text.Contains(a, ">")
                     then Text.Lower(Text.Trim(Text.BetweenDelimiters(a, "<", ">")))
                     else null,
        type text
    ),
    AddHasOwner = Table.AddColumn(AddAssignedToEmail, "HasOwner", each [AssignedToName] <> null and Text.Trim([AssignedToName]) <> "", type logical),

    // 12) Normalizar estado para gestión ejecutiva.
    AddStateNormalized = Table.AddColumn(
        AddHasOwner,
        "StateNormalized",
        each if [StateClean] = "New" then "Pendiente"
             else if [StateClean] = "Active" or [StateClean] = "In Progress" or [StateClean] = "Resolved" then "En curso"
             else if [StateClean] = "Closed" or [StateClean] = "Done" then "Cerrado"
             else "Otro",
        type text
    ),

    // 13) Peso de avance para métricas ponderadas.
    AddProgressWeight = Table.AddColumn(
        AddStateNormalized,
        "ProgressWeight",
        each if [StateNormalized] = "Cerrado" then 1
             else if [StateNormalized] = "En curso" then 0.5
             else 0,
        type number
    ),

    // 14) Renombrar columnas a modelo final.
    FinalRename = Table.RenameColumns(
        AddProgressWeight,
        {
            {"ID", "WorkItemId"},
            {"StateClean", "State"}
        }
    ),

    // 15) Seleccionar columnas principales del modelo.
    FinalSelect = Table.SelectColumns(
        FinalRename,
        {
            "WorkItemId", "WorkItemType", "TrackCode", "TrackName", "FeatureTitle", "UserStoryTitle", "TaskTitle",
            "DisplayTitle", "AssignedToName", "AssignedToEmail", "State", "StateNormalized", "Tags", "HasOwner",
            "IsFeature", "IsUserStory", "IsTask", "ProgressWeight", "SortOrder"
        }
    )
in
    FinalSelect
