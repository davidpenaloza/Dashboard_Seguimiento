# powerbi-roadmap-soporte-daa

## Fuente principal y modos
- **Principal:** WIQL Query ID (Azure DevOps) via `VSTS.AccountContents` + `Functions[WiqlRunFlatWorkItemQueryById]`.
- **Secundaria:** CSV local (`pSourceMode=CSV`).
- **Alternativa futura:** OData (`pSourceMode=OData`).

## Parámetros obligatorios
`pSourceMode`, `pCsvPath`, `pAdoUrl`, `pAdoCollection`, `pAdoProject`, `pAdoTeam`, `pAdoQueryId`, `pODataUrl`.

## Estructura
- `powerquery/transform_workitems_csv.pq`
- `powerquery/transform_workitems_wiql.pq`
- `powerquery/transform_workitems_odata.pq`
- `powerquery/transform_workitems_unified.pq`
- `powerquery/functions_azure_devops.pq`
- `powerquery/parameters.md`
- `dax/measures.md`
- `docs/*`

## Operación rápida
1. Configurar parámetros.
2. Importar `Functions` (dashboard base) y `FunctionsAzureDevOps`.
3. Cargar transform queries.
4. Usar `Fact_WorkItems` desde `transform_workitems_unified.pq`.
5. `pSourceMode=WIQL` para operación real.

## Limitaciones
- Jerarquía depende de columnas `Title 1/2/3` o `ParentWorkItemId`.
- Sin campos de fecha no hay roadmap temporal robusto.
- Cambios en esquema de query WIQL pueden requerir ajuste.

## Seguridad
No se incluyen credenciales, PAT, tokens ni secretos.
