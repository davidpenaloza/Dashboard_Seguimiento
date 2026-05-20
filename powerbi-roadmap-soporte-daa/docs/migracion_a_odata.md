# Migración de CSV a Azure DevOps Analytics / OData

## Objetivo
Sustituir la fuente local CSV por conexión gobernada a Analytics OData.

## Placeholders
- `<AZURE_DEVOPS_ORG>`
- `<AZURE_DEVOPS_PROJECT>`
- `<ANALYTICS_VIEW>`
- `<ODATA_URL>`

Ejemplo conceptual de URL:
`https://analytics.dev.azure.com/<AZURE_DEVOPS_ORG>/<AZURE_DEVOPS_PROJECT>/_odata/v3.0-preview/<ANALYTICS_VIEW>`

## Reglas de seguridad
- No incrustar credenciales, secretos, tokens ni PAT en el proyecto.
- Configurar autenticación en Power BI Desktop con credenciales corporativas.

## Pasos de migración
1. Duplicar query `Fact_WorkItems` y reemplazar `Csv.Document` por `OData.Feed(<ODATA_URL>)`.
2. Mapear columnas equivalentes a las del MVP (ID, Work Item Type, Title, Assigned To, State, Tags, Parent, fechas).
3. Mantener `StateNormalized`, `ProgressWeight` y lógica DAX para continuidad de KPIs.
4. Agregar tablas de fechas y sprint si se incorporan Iteration Path y fechas de ciclo.

## Campos recomendados y uso
- ID: identificador único.
- Work Item Type: discrimina Feature/User Story/Task.
- Title: título operativo.
- State: estado base.
- Assigned To: carga por responsable.
- Tags: clasificación temática.
- Parent: reconstrucción robusta de jerarquía.
- Area Path: segmentación organizacional.
- Iteration Path: seguimiento por sprint/ciclo.
- Created Date: antigüedad y lead time.
- Changed Date: actividad reciente.
- Closed Date: cierre y cycle time.
- Priority: ordenamiento de backlog.
- Severity (si aplica): criticidad.
- Value Area (si aplica): valor de negocio/técnico.
- Board Column: estado operativo real del tablero.
- Board Column Done: indicador de completitud tablero.
- Due Date / Target Date: roadmap temporal e hitos.
- Description / Acceptance Criteria: contexto funcional y definición de terminado.
