/*
Functions auxiliares para conexión Azure DevOps.
Patrón alineado a dashboard de Reporte Gestión de Soporte:
- Wrapper VSTS.AccountContents
- Ejecución Functions[WiqlRunFlatWorkItemQueryById]

Nota: si ya existe una tabla técnica `Functions` en otro dashboard, reutilizarla sin cambios.
Este archivo solo deja el contrato y helpers reutilizables para este proyecto.
*/
let
    FnContents = (adoUrl as text) as function => (o as record) => VSTS.AccountContents(adoUrl, o),

    // Convierte distintos nombres de columna a un nombre canónico si existe.
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
        FnCoalesceColumn = FnCoalesceColumn,
        FnEnsureColumns = FnEnsureColumns,
        FnParseAssignedTo = FnParseAssignedTo,
        FnTrackFromText = FnTrackFromText
    ]
