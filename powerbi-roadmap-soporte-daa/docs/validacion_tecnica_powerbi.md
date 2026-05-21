# Validación técnica post ajuste WIQL-first

## Resultado ejecutivo
- **Implementable en Power BI Desktop/PBIP:** Sí, con una precondición técnica: disponer de la consulta `Functions` que contiene `WiqlRunFlatWorkItemQueryById`.
- **Fuente principal real:** WIQL por ID.
- **CSV:** respaldo/desarrollo.
- **OData:** alternativa futura.

## 1) Ejecutabilidad real de `transform_workitems_wiql.pq`
Sí es ejecutable si existen en el modelo:
1. Parámetros: `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`.
2. Consulta técnica `Functions` con función `WiqlRunFlatWorkItemQueryById`.
3. Consulta `FunctionsAzureDevOps`.

Patrón confirmado:
- `contents = (o) => VSTS.AccountContents(pAdoUrl, o)`
- `Functions[WiqlRunFlatWorkItemQueryById](contents, pAdoUrl, [Collection=..., Project=..., Team=...], pAdoQueryId)`

## 2) Estado de `Functions[WiqlRunFlatWorkItemQueryById]`
- **No está implementada dentro de este repositorio** como definición completa.
- Se **depende** de copiar/reutilizar la tabla técnica `Functions` del dashboard base (Reporte Gestión de Soporte).

## 3) Instrucciones exactas para copiar `Functions`
1. Abrir PBIX/PBIP del dashboard base (Reporte Gestión de Soporte).
2. En Power Query Editor, ubicar la consulta `Functions`.
3. Duplicar o copiar la consulta completa (incluyendo todas las funciones internas y `WiqlRunFlatWorkItemQueryById`).
4. En el nuevo dashboard, pegar la consulta con el mismo nombre exacto: `Functions`.
5. Verificar que `Functions[WiqlRunFlatWorkItemQueryById]` sea accesible en una consulta temporal.
6. Validar que no existan parámetros hardcodeados dentro de `Functions`.
7. Si existieran hardcodes, reemplazar por los parámetros de este proyecto.

## 4) Comparación de patrón con dashboard existente
- `VSTS.AccountContents`: ✅ usado.
- `WiqlRunFlatWorkItemQueryById`: ✅ usado vía `Functions[...]`.
- `Collection`: ✅ parametrizado (`pAdoCollection`).
- `Project`: ✅ parametrizado (`pAdoProject`).
- `Team`: ✅ parametrizado (`pAdoTeam`).
- `QueryId`: ✅ parametrizado (`pAdoQueryId`).

## 5) Consistencia de parámetros
Consistentes entre `parameters.md`, queries y docs:
- `pSourceMode`
- `pCsvPath`
- `pAdoUrl`
- `pAdoCollection`
- `pAdoProject`
- `pAdoTeam`
- `pAdoQueryId`
- `pODataUrl`

## 6) Esquema final unificado CSV vs WIQL
Ambos modos proyectan exactamente estas columnas:
`WorkItemId, WorkItemType, TrackCode, TrackName, FeatureWorkItemId, FeatureTitle, UserStoryWorkItemId, UserStoryTitle, TaskTitle, DisplayTitle, AssignedToName, AssignedToEmail, State, StateNormalized, Tags, HasOwner, IsFeature, IsUserStory, IsTask, SortOrder, ProgressWeight, SourceMode, ParentWorkItemId, AreaPath, IterationPath, CreatedDate, ChangedDate, ClosedDate, Priority, BoardColumn, BoardColumnDone, HierarchyLevel, HierarchyStatus`.

## 7) Validación DAX
`dax/measures.md` referencia columnas existentes en el esquema unificado. No se detectaron referencias rotas.

## 8) Title 1/2/3 y reconstrucción jerárquica
- Si WIQL trae `Title 1/2/3`, se usan como prioridad para `FeatureTitle`, `UserStoryTitle`, `TaskTitle`.
- `DisplayTitle` se deriva por tipo (`Feature`, `User Story`, `Task`).

## 9) Parent y reconstrucción Feature > User Story > Task
Se implementó join de parent y grandparent:
- `FeatureWorkItemId` se infiere para User Story/Task.
- `UserStoryWorkItemId` se infiere para Task.
- `HierarchyStatus` marca `Sin parent`, `User Story sin Feature`, `Jerarquía incompleta`, etc.

## 10) Checklist de prueba Power BI Desktop
1. Crear parámetros M obligatorios.
2. Importar `Functions` desde dashboard base.
3. Importar `FunctionsAzureDevOps`.
4. Importar `TransformWorkItemsCsv`, `TransformWorkItemsWiql`, `TransformWorkItemsOData`, `Fact_WorkItems`.
5. Probar `pSourceMode=CSV` y confirmar preview con 33 columnas.
6. Probar `pSourceMode=WIQL` con QueryId válido.
7. Verificar que `SourceMode` = `WIQL`.
8. Verificar distribución `HierarchyStatus`.
9. Confirmar que DAX compila sin errores.
10. Publicar y validar credenciales/refresh en Service.

## 11) Inconsistencias corregidas en esta revisión
- Se agregó lógica funcional de reconstrucción por `ParentWorkItemId` (padre/abuelo) en modo WIQL.
- Se reforzó `HierarchyStatus` para diagnóstico de calidad jerárquica.
