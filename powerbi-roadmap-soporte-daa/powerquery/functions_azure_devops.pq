/*
Functions Azure DevOps locales para eliminar dependencia externa.
Incluye implementación de WiqlRunFlatWorkItemQueryById usando VSTS.AccountContents.
*/
let
    FnContents = (adoUrl as text) as function => (o as record) => VSTS.AccountContents(adoUrl, o),

    FnHttpErrorMessage = (status as nullable number, body as any) as text =>
        let
            bodyText = try Text.FromBinary(body) otherwise "",
            msg = if status = null then "Error HTTP desconocido"
                  else "Error HTTP " & Text.From(status) & " al ejecutar query WIQL por ID."
        in msg & (if bodyText <> "" then " Detalle: " & bodyText else ""),

    FnWiqlRunFlatWorkItemQueryById = (
        contents as function,
        adoUrl as text,
        scope as record,
        queryId as text
    ) as table =>
        let
            collection = try Text.From(scope[Collection]) otherwise "",
            project = try Text.From(scope[Project]) otherwise "",
            team = try Text.From(scope[Team]) otherwise "",
            relPath = Text.Combine(
                List.Select({collection, project, team, "_apis", "wit", "wiql", queryId}, each _ <> null and _ <> ""),
                "/"
            ),
            wiqlResponse = contents([
                RelativePath = relPath,
                Query = [#"api-version" = "7.0"],
                ManualStatusHandling = {400,401,403,404,429,500}
            ]),
            wiqlMeta = Value.Metadata(wiqlResponse),
            wiqlStatus = try wiqlMeta[Response.Status] otherwise 200,
            wiqlChecked = if wiqlStatus >= 400 then error Error.Record("WiqlRunFlatWorkItemQueryById", FnHttpErrorMessage(wiqlStatus, wiqlResponse), [Status=wiqlStatus, RelativePath=relPath]) else wiqlResponse,
            wiqlJson = Json.Document(wiqlChecked),
            workItems = try wiqlJson[workItems] otherwise {},
            ids = List.Transform(workItems, each try Text.From(_[id]) otherwise null),
            idsClean = List.Select(ids, each _ <> null),
            idsCsv = Text.Combine(idsClean, ","),
            empty = #table({}, {}),
            result = if List.Count(idsClean) = 0 then empty else
                let
                    itemsPath = Text.Combine(List.Select({collection, project, "_apis", "wit", "workitems"}, each _ <> null and _ <> ""), "/"),
                    itemsResp = contents([
                        RelativePath = itemsPath,
                        Query = [ids = idsCsv, #"api-version" = "7.0", #"$expand" = "Relations"],
                        ManualStatusHandling = {400,401,403,404,429,500}
                    ]),
                    itemsMeta = Value.Metadata(itemsResp),
                    itemsStatus = try itemsMeta[Response.Status] otherwise 200,
                    itemsChecked = if itemsStatus >= 400 then error Error.Record("WiqlRunFlatWorkItemQueryById", FnHttpErrorMessage(itemsStatus, itemsResp), [Status=itemsStatus, RelativePath=itemsPath]) else itemsResp,
                    itemsJson = Json.Document(itemsChecked),
                    values = try itemsJson[value] otherwise {},
                    baseRows = List.Transform(values, each [
                        ID = try _[id] otherwise null,
                        Title = try _[fields][#"System.Title"] otherwise null,
                        #"Work Item Type" = try _[fields][#"System.WorkItemType"] otherwise null,
                        State = try _[fields][#"System.State"] otherwise null,
                        #"Assigned To" = try _[fields][#"System.AssignedTo"][displayName] & " <" & _[fields][#"System.AssignedTo"][uniqueName] & ">" otherwise null,
                        Tags = try _[fields][#"System.Tags"] otherwise null,
                        Parent = try _[fields][#"System.Parent"] otherwise null,
                        #"Area Path" = try _[fields][#"System.AreaPath"] otherwise null,
                        #"Iteration Path" = try _[fields][#"System.IterationPath"] otherwise null,
                        #"Created Date" = try _[fields][#"System.CreatedDate"] otherwise null,
                        #"Changed Date" = try _[fields][#"System.ChangedDate"] otherwise null,
                        #"Closed Date" = try _[fields][#"Microsoft.VSTS.Common.ClosedDate"] otherwise null,
                        Priority = try _[fields][#"Microsoft.VSTS.Common.Priority"] otherwise null,
                        #"Board Column" = try _[fields][#"System.BoardColumn"] otherwise null,
                        #"Board Column Done" = try _[fields][#"System.BoardColumnDone"] otherwise null
                    ]),
                    tbl = Table.FromRecords(baseRows)
                in tbl
        in
            result,

    FnCoalesceColumn = (tbl as table, candidates as list, target as text) as table =>
        let
            exists = List.Select(candidates, each Table.HasColumns(tbl, {_})),
            out = if List.Count(exists) = 0 then Table.AddColumn(tbl, target, each null)
                  else if List.First(exists) = target then tbl
                  else Table.RenameColumns(tbl, {{List.First(exists), target}}, MissingField.Ignore)
        in
            out,

    FnEnsureColumns = (tbl as table, cols as list) as table =>
        List.Accumulate(cols, tbl, (state, c) => if Table.HasColumns(state, {c}) then state else Table.AddColumn(state, c, each null)),

    FnParseAssignedTo = (assigned as nullable text) as record =>
        let
            a = if assigned = null then "" else Text.Trim(assigned),
            name = if a = "" then null else if Text.Contains(a, "<") then Text.Trim(Text.BeforeDelimiter(a, "<")) else a,
            email = if a = "" then null else if Text.Contains(a, "<") and Text.Contains(a, ">") then Text.Lower(Text.Trim(Text.BetweenDelimiters(a, "<", ">"))) else null
        in [AssignedToName = name, AssignedToEmail = email],

    FnTrackFromText = (txt as nullable text) as record =>
        let
            t = if txt = null then "" else Text.Trim(txt),
            has = Text.StartsWith(t, "T") and Text.Length(t) >= 4 and Text.Range(t, 1, 2) >= "00" and Text.Range(t, 1, 2) <= "99" and Text.Contains(t, " - "),
            code = if has then Text.Start(t, 3) else null,
            name = if has then Text.AfterDelimiter(t, " - ") else null
        in [TrackCode = code, TrackName = name]
in
    [
        FnContents = FnContents,
        FnWiqlRunFlatWorkItemQueryById = FnWiqlRunFlatWorkItemQueryById,
        FnCoalesceColumn = FnCoalesceColumn,
        FnEnsureColumns = FnEnsureColumns,
        FnParseAssignedTo = FnParseAssignedTo,
        FnTrackFromText = FnTrackFromText
    ]
