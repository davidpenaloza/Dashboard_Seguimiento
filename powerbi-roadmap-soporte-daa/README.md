# powerbi-roadmap-soporte-daa

## 1) Objetivo
Base versionable para construir un dashboard Power BI de seguimiento ejecutivo y operativo de Soporte DAA AMSA, iniciando con CSV exportado desde Azure DevOps y preparado para migrar a OData.

## 2) Fuente de datos inicial
- Archivo muestra: `data/azure_devops_query_sample.csv`.
- Estructura esperada: `ID`, `Work Item Type`, `Title 1`, `Title 2`, `Title 3`, `Assigned To`, `State`, `Tags`.

## 3) Análisis del CSV (muestra actual)
- Total work items: **172**
- Features: **8**
- User Stories: **19**
- Tasks: **145**
- Estados detectados: **Closed, New**
- Responsables detectados: **2**
- Work items sin responsable: **169**
- Tags detectados: **ACTIVIDAD DE SOPORTE, AUTOMATIZACIONES**
- Tracks detectados: **T01..T08**

### Tracks detectados
- T01 - Plataforma de Monitoreo
- T02 - Automatizaciones Operativas
- T03 - Dashboard de Gestión
- T04 - Portal Interno de Soporte
- T05 - IA GEN
- T06 - Capacitaciones
- T07 - Grafana
- T08 - Permisologías y Accesos

### Hallazgos de calidad de datos
- Alto porcentaje sin responsable.
- Estados limitados a `New`/`Closed` (sin granularidad de progreso intermedio).
- Tags poco variados.
- Sin fechas para roadmap temporal real.

## 4) Cómo reemplazar el CSV
1. Reemplazar `data/azure_devops_query_sample.csv` por la nueva exportación.
2. Mantener mismo esquema de columnas (o adaptar `powerquery/transform_workitems.pq`).
3. Actualizar parámetro `pCsvPath` en Power BI Desktop.

## 5) Cómo construir el reporte en Power BI Desktop
1. Crear archivo `.pbix` nuevo.
2. Crear parámetro `pCsvPath` (texto).
3. Abrir Editor Avanzado y pegar `powerquery/transform_workitems.pq`.
4. Nombrar la consulta resultante como `Fact_WorkItems`.
5. Crear dimensiones desde referencias (`Dim_Tracks`, `Dim_Status`, `Dim_WorkItemType`, `Dim_AssignedTo`).
6. Crear relaciones indicadas en `docs/modelo_datos.md`.

## 6) Cómo importar Power Query
- Copiar el contenido de `powerquery/transform_workitems.pq` al Editor Avanzado de una nueva consulta.

## 7) Cómo crear medidas DAX
- Copiar las medidas de `dax/measures.md` en la vista Modelo > Nueva medida.

## 8) Cómo importar tema JSON
- En Power BI Desktop: **Vista > Temas > Examinar temas**.
- Seleccionar `theme/amsa_powerbi_theme.json`.

## 9) Estructura de carpetas
- `data/`: muestra CSV.
- `powerquery/`: script M.
- `dax/`: catálogo de medidas.
- `theme/`: tema visual corporativo.
- `docs/`: modelo, diseño, limitaciones, migración OData.

## 10) Limitaciones actuales
Ver `docs/limitaciones_csv_actual.md`.

## 11) Próximos pasos recomendados
1. Completar metadata de `Dim_Tracks` (owner, riesgo, hitos, dependencias).
2. Enriquecer query Azure DevOps con Parent, fechas, Iteration Path y Priority.
3. Migrar a OData para actualización automática y trazabilidad histórica.
4. Implementar página de calidad de datos para gobernanza.
