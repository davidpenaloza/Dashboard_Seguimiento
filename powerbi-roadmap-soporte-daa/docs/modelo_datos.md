# Modelo de datos actualizado (fuente principal WIQL)

`Fact_WorkItems` se construye desde `transform_workitems_unified.pq` y soporta `CSV`, `WIQL`, `OData` por parámetro `pSourceMode`.

## Esquema unificado
Incluye siempre: IDs, tipo, track, jerarquía, owner, estado normalizado, calidad de datos, campos operativos (Area/Iteration/fechas/Priority/Board) y `SourceMode`.

## Tablas
- Fact_WorkItems
- Dim_Tracks
- Dim_Status
- Dim_WorkItemType
- Dim_AssignedTo

## Reglas
- Fuente principal: WIQL por Query ID.
- CSV solo respaldo/desarrollo.
- OData solo alternativa futura.
