let
    mode = Text.Upper(Text.Trim(pSourceMode)),
    Fact_WorkItems =
        if mode = "CSV" then TransformWorkItemsCsv
        else if mode = "WIQL" then TransformWorkItemsWiql
        else if mode = "ODATA" then TransformWorkItemsOData
        else error "pSourceMode inválido. Use CSV, WIQL u OData."
in
    Fact_WorkItems
