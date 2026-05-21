let
    Source = Csv.Document(File.Contents(pCsvPath), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    H = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    C = Table.TransformColumnNames(H, each Text.Trim(_)),
    I = Table.AddIndexColumn(C, "SortOrder", 1, 1, Int64.Type),
    T = Table.TransformColumnTypes(I,{{"ID", Int64.Type},{"Work Item Type", type text},{"Title 1", type text},{"Title 2", type text},{"Title 3", type text},{"Assigned To", type text},{"State", type text},{"Tags", type text}}),

    A1 = Table.AddColumn(T,"WorkItemId", each [ID]),
    A2 = Table.AddColumn(A1,"WorkItemType", each Text.Proper(Text.Trim(Text.From([Work Item Type])))),
    F0 = Table.AddColumn(A2,"IsFeature", each [WorkItemType]="Feature", type logical),
    F1 = Table.AddColumn(F0,"IsUserStory", each [WorkItemType]="User Story", type logical),
    F2 = Table.AddColumn(F1,"IsTask", each [WorkItemType]="Task", type logical),

    // Segmentación por Feature para herencia controlada dentro de cada track
    G0 = Table.AddColumn(F2, "FeatureSegment", each if [IsFeature] then 1 else 0, Int64.Type),
    G1 = Table.AddColumn(G0, "FeatureGroup", each List.Sum(List.FirstN(G0[FeatureSegment], [SortOrder])), Int64.Type),

    B1 = Table.AddColumn(G1,"FeatureTitleSeed", each if [IsFeature] then [Title 1] else null, type text),
    B2 = Table.FillDown(B1,{"FeatureTitleSeed"}),
    B3 = Table.AddColumn(B2,"FeatureTitle", each [FeatureTitleSeed], type text),

    B4 = Table.AddColumn(B3,"FeatureWorkItemIdSeed", each if [IsFeature] then [WorkItemId] else null, Int64.Type),
    B5 = Table.FillDown(B4,{"FeatureWorkItemIdSeed"}),
    B6 = Table.AddColumn(B5,"FeatureWorkItemId", each if [FeatureGroup] > 0 and ([IsFeature] or [IsUserStory] or [IsTask]) then [FeatureWorkItemIdSeed] else null, Int64.Type),

    // User Story heredada solo dentro del mismo FeatureGroup
    U0 = Table.AddColumn(B6,"UserStoryWorkItemIdSeed", each if [IsUserStory] then [WorkItemId] else null, Int64.Type),
    U1 = Table.Group(U0, {"FeatureGroup"}, {{"Rows", (tt) => Table.FillDown(tt,{"UserStoryWorkItemIdSeed"}), type table}}),
    U2 = Table.Combine(U1[Rows]),
    U3 = Table.Sort(U2,{{"SortOrder", Order.Ascending}}),
    U4 = Table.AddColumn(U3,"UserStoryWorkItemId", each if [IsUserStory] or [IsTask] then [UserStoryWorkItemIdSeed] else null, Int64.Type),

    U5 = Table.AddColumn(U4,"UserStoryTitleSeed", each if [IsUserStory] then [Title 2] else null, type text),
    U6 = Table.Group(U5, {"FeatureGroup"}, {{"Rows", (tt) => Table.FillDown(tt,{"UserStoryTitleSeed"}), type table}}),
    U7 = Table.Combine(U6[Rows]),
    U8 = Table.Sort(U7,{{"SortOrder", Order.Ascending}}),
    U9 = Table.AddColumn(U8,"UserStoryTitle", each if [IsUserStory] or [IsTask] then [UserStoryTitleSeed] else null, type text),

    T1 = Table.AddColumn(U9,"TaskTitle", each if [IsTask] then [Title 3] else null, type text),
    T2 = Table.AddColumn(T1,"DisplayTitle", each if [IsFeature] then [FeatureTitle] else if [IsUserStory] then [UserStoryTitle] else [TaskTitle]),

    R1 = Table.AddColumn(T2,"TrackRec", each FunctionsAzureDevOps[FnTrackFromText]([FeatureTitle])),
    R2 = Table.ExpandRecordColumn(R1,"TrackRec",{"TrackCode","TrackName"},{"TrackCode","TrackName"}),

    E1 = Table.AddColumn(R2,"AssignedRec", each FunctionsAzureDevOps[FnParseAssignedTo]([Assigned To])),
    E2 = Table.ExpandRecordColumn(E1,"AssignedRec",{"AssignedToName","AssignedToEmail"},{"AssignedToName","AssignedToEmail"}),
    E3 = Table.TransformColumns(E2,{{"State", each if _=null then null else Text.Proper(Text.Trim(Text.From(_))), type text}}),
    E4 = Table.AddColumn(E3,"StateNormalized", each if [State]="New" then "Pendiente" else if List.Contains({"Active","In Progress","Resolved"}, [State]) then "En curso" else if List.Contains({"Closed","Done"}, [State]) then "Cerrado" else "Otro"),
    E5 = Table.AddColumn(E4,"HasOwner", each [AssignedToName]<>null and Text.Trim([AssignedToName])<>"", type logical),
    E6 = Table.AddColumn(E5,"ProgressWeight", each if [StateNormalized]="Cerrado" then 1 else if [StateNormalized]="En curso" then 0.5 else 0, type number),
    E7 = Table.AddColumn(E6,"SourceMode", each "CSV", type text),
    E8 = Table.AddColumn(E7,"ParentWorkItemId", each null, Int64.Type),
    E9 = Table.AddColumn(E8,"AreaPath", each null, type text),
    E10 = Table.AddColumn(E9,"IterationPath", each null, type text),
    E11 = Table.AddColumn(E10,"CreatedDate", each null, type datetime),
    E12 = Table.AddColumn(E11,"ChangedDate", each null, type datetime),
    E13 = Table.AddColumn(E12,"ClosedDate", each null, type datetime),
    E14 = Table.AddColumn(E13,"Priority", each null, Int64.Type),
    E15 = Table.AddColumn(E14,"BoardColumn", each null, type text),
    E16 = Table.AddColumn(E15,"BoardColumnDone", each null, type logical),
    E17 = Table.AddColumn(E16,"HierarchyLevel", each if [IsFeature] then 1 else if [IsUserStory] then 2 else if [IsTask] then 3 else null, Int64.Type),
    E18 = Table.AddColumn(E17,"HierarchyStatus", each if [TrackCode]=null then "Track no detectado" else if [IsTask] and [UserStoryWorkItemId]=null then "Jerarquía incompleta" else "Completa", type text),
    E19 = Table.ReplaceValue(E18,null,"Track sin clasificar",Replacer.ReplaceValue,{"TrackName"}),
    E20 = Table.ReplaceValue(E19,null,"T00",Replacer.ReplaceValue,{"TrackCode"}),

    S = Table.SelectColumns(E20,{"WorkItemId","WorkItemType","TrackCode","TrackName","FeatureWorkItemId","FeatureTitle","UserStoryWorkItemId","UserStoryTitle","TaskTitle","DisplayTitle","AssignedToName","AssignedToEmail","State","StateNormalized","Tags","HasOwner","IsFeature","IsUserStory","IsTask","SortOrder","ProgressWeight","SourceMode","ParentWorkItemId","AreaPath","IterationPath","CreatedDate","ChangedDate","ClosedDate","Priority","BoardColumn","BoardColumnDone","HierarchyLevel","HierarchyStatus"})
in
    S
