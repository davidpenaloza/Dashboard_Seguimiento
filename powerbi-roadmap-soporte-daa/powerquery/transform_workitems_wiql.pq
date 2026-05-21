let
    // Patrón técnico requerido: VSTS.AccountContents + Functions[WiqlRunFlatWorkItemQueryById]
    contents = (o as record) => VSTS.AccountContents(pAdoUrl, o),
    RawWiql = Functions[WiqlRunFlatWorkItemQueryById](
        contents,
        pAdoUrl,
        [Collection = pAdoCollection, Project = pAdoProject, Team = pAdoTeam],
        pAdoQueryId
    ),

    // Normalización de nombres de columnas de entrada (soporta variantes de WIQL)
    T0 = FunctionsAzureDevOps[FnCoalesceColumn](RawWiql,{"ID","Id","WorkItemId"},"WorkItemId"),
    T1 = FunctionsAzureDevOps[FnCoalesceColumn](T0,{"Work Item Type","WorkItemType","Type"},"WorkItemType"),
    T2 = FunctionsAzureDevOps[FnCoalesceColumn](T1,{"Title","System.Title","Title 1"},"Title"),
    T3 = FunctionsAzureDevOps[FnCoalesceColumn](T2,{"Title 1","FeatureTitle"},"Title 1"),
    T4 = FunctionsAzureDevOps[FnCoalesceColumn](T3,{"Title 2","UserStoryTitle"},"Title 2"),
    T5 = FunctionsAzureDevOps[FnCoalesceColumn](T4,{"Title 3","TaskTitle"},"Title 3"),
    T6 = FunctionsAzureDevOps[FnCoalesceColumn](T5,{"Assigned To","AssignedTo"},"Assigned To"),
    T7 = FunctionsAzureDevOps[FnCoalesceColumn](T6,{"State","System.State"},"State"),
    T8 = FunctionsAzureDevOps[FnCoalesceColumn](T7,{"Tags","System.Tags"},"Tags"),
    T9 = FunctionsAzureDevOps[FnCoalesceColumn](T8,{"Parent","ParentWorkItemId"},"ParentWorkItemId"),
    T10 = FunctionsAzureDevOps[FnCoalesceColumn](T9,{"Area Path","AreaPath"},"AreaPath"),
    T11 = FunctionsAzureDevOps[FnCoalesceColumn](T10,{"Iteration Path","IterationPath"},"IterationPath"),
    T12 = FunctionsAzureDevOps[FnCoalesceColumn](T11,{"Created Date","CreatedDate"},"CreatedDate"),
    T13 = FunctionsAzureDevOps[FnCoalesceColumn](T12,{"Changed Date","ChangedDate"},"ChangedDate"),
    T14 = FunctionsAzureDevOps[FnCoalesceColumn](T13,{"Closed Date","ClosedDate"},"ClosedDate"),
    T15 = FunctionsAzureDevOps[FnCoalesceColumn](T14,{"Priority"},"Priority"),
    T16 = FunctionsAzureDevOps[FnCoalesceColumn](T15,{"Board Column","BoardColumn"},"BoardColumn"),
    T17 = FunctionsAzureDevOps[FnCoalesceColumn](T16,{"Board Column Done","BoardColumnDone"},"BoardColumnDone"),

    Typed = Table.TransformColumnTypes(T17,{{"WorkItemId", Int64.Type},{"ParentWorkItemId", Int64.Type}}),
    I = Table.AddIndexColumn(Typed,"SortOrder",1,1,Int64.Type),

    A = Table.AddColumn(I,"AssignedRec", each FunctionsAzureDevOps[FnParseAssignedTo](try Text.From([Assigned To]) otherwise null)),
    E = Table.ExpandRecordColumn(A,"AssignedRec",{"AssignedToName","AssignedToEmail"},{"AssignedToName","AssignedToEmail"}),
    N1 = Table.AddColumn(E,"FeatureTitleRaw", each if [Title 1]<>null then [Title 1] else if Text.Proper(Text.From([WorkItemType]))="Feature" then [Title] else null),
    N2 = Table.AddColumn(N1,"UserStoryTitleRaw", each if [Title 2]<>null then [Title 2] else if Text.Proper(Text.From([WorkItemType]))="User Story" then [Title] else null),
    N3 = Table.AddColumn(N2,"TaskTitleRaw", each if [Title 3]<>null then [Title 3] else if Text.Proper(Text.From([WorkItemType]))="Task" then [Title] else null),
    N4 = Table.TransformColumns(N3,{{"WorkItemType", each Text.Proper(Text.Trim(Text.From(_))), type text},{"State", each if _=null then null else Text.Proper(Text.Trim(Text.From(_))), type text}}),

    // Lookup de padres para reconstrucción jerárquica si la query viene flat con Parent
    ParentLookup = Table.SelectColumns(N4,{"WorkItemId","WorkItemType","Title","ParentWorkItemId","FeatureTitleRaw"}),
    JoinP1 = Table.NestedJoin(N4,{"ParentWorkItemId"},ParentLookup,{"WorkItemId"},"P1",JoinKind.LeftOuter),
    ExpP1 = Table.ExpandTableColumn(JoinP1,"P1",{"WorkItemId","WorkItemType","Title","ParentWorkItemId","FeatureTitleRaw"},{"P1_WorkItemId","P1_WorkItemType","P1_Title","P1_ParentWorkItemId","P1_FeatureTitleRaw"}),
    JoinP2 = Table.NestedJoin(ExpP1,{"P1_ParentWorkItemId"},ParentLookup,{"WorkItemId"},"P2",JoinKind.LeftOuter),
    ExpP2 = Table.ExpandTableColumn(JoinP2,"P2",{"WorkItemId","WorkItemType","Title","FeatureTitleRaw"},{"P2_WorkItemId","P2_WorkItemType","P2_Title","P2_FeatureTitleRaw"}),

    // IDs jerárquicos por tipo
    H1 = Table.AddColumn(ExpP2,"FeatureWorkItemId", each if [WorkItemType]="Feature" then [WorkItemId] else if [WorkItemType]="User Story" and [P1_WorkItemType]="Feature" then [P1_WorkItemId] else if [WorkItemType]="Task" and [P1_WorkItemType]="Feature" then [P1_WorkItemId] else if [WorkItemType]="Task" and [P2_WorkItemType]="Feature" then [P2_WorkItemId] else null, Int64.Type),
    H2 = Table.AddColumn(H1,"UserStoryWorkItemId", each if [WorkItemType]="User Story" then [WorkItemId] else if [WorkItemType]="Task" and [P1_WorkItemType]="User Story" then [P1_WorkItemId] else null, Int64.Type),

    // Títulos finales (prioriza salida tree Title1/2/3; fallback a parent)
    H3 = Table.AddColumn(H2,"FeatureTitle", each if [FeatureTitleRaw]<>null then [FeatureTitleRaw] else if [P1_WorkItemType]="Feature" then [P1_Title] else if [P2_WorkItemType]="Feature" then [P2_Title] else null),
    H4 = Table.AddColumn(H3,"UserStoryTitle", each if [UserStoryTitleRaw]<>null then [UserStoryTitleRaw] else if [WorkItemType]="User Story" then [Title] else if [P1_WorkItemType]="User Story" then [P1_Title] else null),
    H5 = Table.AddColumn(H4,"TaskTitle", each if [TaskTitleRaw]<>null then [TaskTitleRaw] else if [WorkItemType]="Task" then [Title] else null),

    D = Table.AddColumn(H5,"DisplayTitle", each if [WorkItemType]="Feature" then [FeatureTitle] else if [WorkItemType]="User Story" then [UserStoryTitle] else [TaskTitle]),
    TRec = Table.AddColumn(D,"TrackRec", each FunctionsAzureDevOps[FnTrackFromText]([FeatureTitle])),
    TExp = Table.ExpandRecordColumn(TRec,"TrackRec",{"TrackCode","TrackName"},{"TrackCode","TrackName"}),

    SNorm = Table.AddColumn(TExp,"StateNormalized", each if [State]="New" then "Pendiente" else if List.Contains({"Active","In Progress","Resolved"}, [State]) then "En curso" else if List.Contains({"Closed","Done"}, [State]) then "Cerrado" else "Otro"),
    F0 = Table.AddColumn(SNorm,"HasOwner", each [AssignedToName]<>null and Text.Trim([AssignedToName])<>"", type logical),
    F1 = Table.AddColumn(F0,"IsFeature", each [WorkItemType]="Feature", type logical),
    F2 = Table.AddColumn(F1,"IsUserStory", each [WorkItemType]="User Story", type logical),
    F3 = Table.AddColumn(F2,"IsTask", each [WorkItemType]="Task", type logical),
    F4 = Table.AddColumn(F3,"ProgressWeight", each if [StateNormalized]="Cerrado" then 1 else if [StateNormalized]="En curso" then 0.5 else 0, type number),
    F5 = Table.AddColumn(F4,"SourceMode", each "WIQL", type text),
    F6 = Table.AddColumn(F5,"HierarchyLevel", each if [IsFeature] then 1 else if [IsUserStory] then 2 else if [IsTask] then 3 else null, Int64.Type),
    F7 = Table.AddColumn(F6,"HierarchyStatus", each if [IsFeature] and [TrackCode]=null then "Track no detectado" else if [IsUserStory] and [FeatureWorkItemId]=null then "User Story sin Feature" else if [IsTask] and [ParentWorkItemId]=null then "Sin parent" else if [IsTask] and [UserStoryWorkItemId]=null then "Jerarquía incompleta" else "Completa", type text),
    F8 = Table.ReplaceValue(F7,null,"Track sin clasificar",Replacer.ReplaceValue,{"TrackName"}),
    F9 = Table.ReplaceValue(F8,null,"T00",Replacer.ReplaceValue,{"TrackCode"}),
    ECols = FunctionsAzureDevOps[FnEnsureColumns](F9,{"BoardColumnDone","AreaPath","IterationPath","CreatedDate","ChangedDate","ClosedDate","Priority","ParentWorkItemId"}),

    S = Table.SelectColumns(ECols,{"WorkItemId","WorkItemType","TrackCode","TrackName","FeatureWorkItemId","FeatureTitle","UserStoryWorkItemId","UserStoryTitle","TaskTitle","DisplayTitle","AssignedToName","AssignedToEmail","State","StateNormalized","Tags","HasOwner","IsFeature","IsUserStory","IsTask","SortOrder","ProgressWeight","SourceMode","ParentWorkItemId","AreaPath","IterationPath","CreatedDate","ChangedDate","ClosedDate","Priority","BoardColumn","BoardColumnDone","HierarchyLevel","HierarchyStatus"})
in
    S
