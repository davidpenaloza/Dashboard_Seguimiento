# Paso a paso Power BI Desktop

1. Abrir Power BI Desktop.
2. Crear parámetros M: `pSourceMode`, `pCsvPath`, `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`, `pODataUrl`.
3. Importar/pegar `powerquery/functions_azure_devops.pq` (consulta `FunctionsAzureDevOps`).
4. Importar consulta técnica `Functions` desde dashboard base (Reporte Gestión de Soporte), incluyendo `WiqlRunFlatWorkItemQueryById`.
5. Importar `transform_workitems_csv.pq` (consulta `TransformWorkItemsCsv`).
6. Importar `transform_workitems_wiql.pq` (consulta `TransformWorkItemsWiql`).
7. Importar `transform_workitems_odata.pq` (consulta `TransformWorkItemsOData`).
8. Importar `transform_workitems_unified.pq` como `Fact_WorkItems`.
9. Definir `pSourceMode = WIQL`.
10. Validar carga de `Fact_WorkItems`.
11. Crear medidas de `dax/measures.md`.
12. Importar `theme/amsa_powerbi_theme.json`.
13. Construir páginas del reporte.
14. Publicar en Power BI Service.
15. Configurar credenciales y refresh.
