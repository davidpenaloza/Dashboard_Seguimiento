# powerbi-roadmap-soporte-daa

## Estado del proyecto
- Arquitectura de datos: **WIQL-first** con fallback `CSV` y alternativa futura `OData`.
- Tabla principal del modelo: `Fact_WorkItems`.
- En esta copia del repositorio **no se detectan archivos PBIP/PBIR/TMDL**, por lo que el layout visual debe aplicarse desde Power BI Desktop usando la guía de `docs/diseno_reporte.md`.

## Fuentes
- Principal: `WIQL` por Query ID (Azure DevOps).
- Secundaria de prueba: `CSV` (`pSourceMode=CSV`).
- Alternativa futura: `OData` (`pSourceMode=OData`).

## Parámetros M obligatorios
- `pSourceMode`
- `pCsvPath`
- `pAdoUrl`
- `pAdoCollection`
- `pAdoProject`
- `pAdoTeam`
- `pAdoQueryId`
- `pODataUrl`

## Abrir y validar en Power BI Desktop
1. Crear un PBIX nuevo.
2. Crear los parámetros M anteriores.
3. Importar la consulta `FunctionsAzureDevOps` desde `powerquery/functions_azure_devops.pq`.
4. Importar:
   - `transform_workitems_csv.pq` (query: `TransformWorkItemsCsv`)
   - `transform_workitems_wiql.pq` (query: `TransformWorkItemsWiql`)
   - `transform_workitems_odata.pq` (query: `TransformWorkItemsOData`)
   - `transform_workitems_unified.pq` (query final: `Fact_WorkItems`)
5. Probar primero `pSourceMode=CSV` con `data/azure_devops_query_sample.csv`.
6. Validar carga esperada (172 filas en muestra actual).
7. Crear medidas desde `dax/measures.md`.
8. Importar tema `theme/amsa_powerbi_theme.json`.
9. Construir las 6 páginas con `docs/diseno_reporte.md`.

## Publicación y refresh
1. Publicar en Power BI Service.
2. Configurar credenciales del origen (organizacionales) en dataset.
3. Configurar refresh programado.
4. Verificar que `Fact_WorkItems` refresca sin errores.

## Validaciones funcionales clave
- User Stories y Tasks **heredan** `TrackCode`/`TrackName` desde Feature padre/ancestro.
- `TrackCode=T00` solo para casos realmente sin track detectable.
- `HierarchyStatus` permite monitoreo de calidad de datos.

## Seguridad
- No incluir credenciales, PAT, tokens ni secretos en el repositorio.
