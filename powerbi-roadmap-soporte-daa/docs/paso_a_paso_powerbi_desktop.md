# Paso a paso Power BI Desktop

1. Abrir Power BI Desktop.
2. Crear parámetros M: `pSourceMode`, `pCsvPath`, `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`, `pODataUrl`.
3. Importar/pegar `powerquery/functions_azure_devops.pq` con nombre de consulta **FunctionsAzureDevOps**.
4. Importar `transform_workitems_csv.pq` (consulta `TransformWorkItemsCsv`).
5. Importar `transform_workitems_wiql.pq` (consulta `TransformWorkItemsWiql`).
6. Importar `transform_workitems_odata.pq` (consulta `TransformWorkItemsOData`).
7. Importar `transform_workitems_unified.pq` y nombrarla `Fact_WorkItems`.
8. Definir `pSourceMode = WIQL`.
9. Completar parámetros ADO: `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`.
10. Configurar credenciales en Desktop cuando se solicite (sin PAT embebido en código).
11. Validar carga de `Fact_WorkItems`.
12. Crear medidas de `dax/measures.md`.
13. Importar `theme/amsa_powerbi_theme.json`.
14. Construir páginas del reporte.
15. Publicar en Power BI Service.
16. Configurar credenciales y refresh.
