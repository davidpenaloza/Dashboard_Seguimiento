# Validación técnica post ajuste WIQL-first

## Resultado ejecutivo
- **Implementable en Power BI Desktop/PBIP:** Sí.
- **Dependencia crítica resuelta:** Sí. La función `WiqlRunFlatWorkItemQueryById` ya quedó implementada localmente en `FunctionsAzureDevOps`.
- **Fuente principal real:** WIQL por ID.
- **CSV:** respaldo/desarrollo.
- **OData:** alternativa futura.

## 1) Ejecutabilidad real de `transform_workitems_wiql.pq`
Es ejecutable si existen en el modelo:
1. Parámetros: `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`.
2. Consulta `FunctionsAzureDevOps` cargada antes de `TransformWorkItemsWiql`.

Patrón confirmado:
- `contents = (o) => VSTS.AccountContents(pAdoUrl, o)`
- `FunctionsAzureDevOps[FnWiqlRunFlatWorkItemQueryById](contents, pAdoUrl, [Collection=..., Project=..., Team=...], pAdoQueryId)`

## 2) Estado de la función WIQL
- `FnWiqlRunFlatWorkItemQueryById` está implementada en:
  - `powerquery/functions_azure_devops.pq`
- Incluye:
  - armado de endpoint `.../_apis/wit/wiql/{id}` por `RelativePath`
  - uso de `VSTS.AccountContents`
  - manejo de errores HTTP con `ManualStatusHandling`
  - expansión de IDs a detalles vía `.../_apis/wit/workitems?ids=...`
  - salida tabular para transformación posterior

## 3) Comparación de patrón con dashboard existente
- `VSTS.AccountContents`: ✅ usado.
- `WiqlRunFlatWorkItemQueryById`: ✅ implementado localmente.
- `Collection`: ✅ parametrizado (`pAdoCollection`).
- `Project`: ✅ parametrizado (`pAdoProject`).
- `Team`: ✅ parametrizado (`pAdoTeam`).
- `QueryId`: ✅ parametrizado (`pAdoQueryId`).

## 4) Consistencia de parámetros
Consistentes entre `parameters.md`, queries y docs:
- `pSourceMode`
- `pCsvPath`
- `pAdoUrl`
- `pAdoCollection`
- `pAdoProject`
- `pAdoTeam`
- `pAdoQueryId`
- `pODataUrl`

## 5) Esquema final unificado CSV vs WIQL
Ambos modos proyectan exactamente estas columnas:
`WorkItemId, WorkItemType, TrackCode, TrackName, FeatureWorkItemId, FeatureTitle, UserStoryWorkItemId, UserStoryTitle, TaskTitle, DisplayTitle, AssignedToName, AssignedToEmail, State, StateNormalized, Tags, HasOwner, IsFeature, IsUserStory, IsTask, SortOrder, ProgressWeight, SourceMode, ParentWorkItemId, AreaPath, IterationPath, CreatedDate, ChangedDate, ClosedDate, Priority, BoardColumn, BoardColumnDone, HierarchyLevel, HierarchyStatus`.

## 6) Validación DAX
`dax/measures.md` referencia columnas existentes en el esquema unificado.

## 7) Lógica de jerarquía
- Si WIQL trae `Title 1/2/3`, se priorizan para `FeatureTitle`, `UserStoryTitle`, `TaskTitle`.
- Si WIQL trae `Parent`, se reconstruye con join de padre/abuelo:
  - `FeatureWorkItemId`
  - `UserStoryWorkItemId`
  - `HierarchyStatus`

## 8) Checklist de prueba Power BI Desktop
1. Crear parámetros M obligatorios.
2. Importar `FunctionsAzureDevOps`.
3. Importar `TransformWorkItemsCsv`, `TransformWorkItemsWiql`, `TransformWorkItemsOData`, `Fact_WorkItems`.
4. Probar `pSourceMode=CSV` y confirmar preview con 33 columnas.
5. Probar `pSourceMode=WIQL` con `pAdoQueryId` válido.
6. Verificar `SourceMode = WIQL`.
7. Verificar distribución `HierarchyStatus`.
8. Confirmar que DAX compila sin errores.
9. Publicar y validar credenciales/refresh en Service.

## 9) Seguridad
- No se incluyen credenciales, PAT, tokens ni secretos en código o documentación.

## 10) Validación específica modo CSV (herencia de Track)
- En `transform_workitems_csv.pq` se implementó herencia jerárquica por `FillDown` para:
  - `FeatureTitle` desde filas Feature.
  - `FeatureWorkItemId` hacia User Stories y Tasks hijas.
  - `UserStoryWorkItemId` y `UserStoryTitle` hacia Tasks hijas.
- `TrackCode` y `TrackName` ahora se calculan desde `FeatureTitle` heredado, por lo que filas hijas con padre válido **no** deben quedar en `T00`.
- `T00 / Track sin clasificar` queda reservado para registros realmente sin Feature padre detectable.
