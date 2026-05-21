# Dashboard Seguimiento Soporte DAA (PBIP)

Este repositorio contiene el proyecto **PBIP real**:

- `Dashboard_Seguimiento_Soporte_DAA.pbip`
- `Dashboard_Seguimiento_Soporte_DAA.Report/`
- `Dashboard_Seguimiento_Soporte_DAA.SemanticModel/`
- `powerbi-roadmap-soporte-daa/`

## Abrir el PBIP en Power BI Desktop

1. Usar **Power BI Desktop** con soporte PBIP.
2. Abrir `Dashboard_Seguimiento_Soporte_DAA.pbip` (archivo de entrada del proyecto).
3. Verificar que el reporte apunta al modelo semántico por ruta relativa en `Dashboard_Seguimiento_Soporte_DAA.Report/definition.pbir`.

## Validación rápida del proyecto

1. Confirmar páginas del reporte en `Dashboard_Seguimiento_Soporte_DAA.Report/definition/pages/pages.json`.
2. Confirmar definición de páginas y visuales en `Dashboard_Seguimiento_Soporte_DAA.Report/definition/pages/<pageId>/`.
3. Confirmar modelo tabular en TMDL en `Dashboard_Seguimiento_Soporte_DAA.SemanticModel/definition/tables/Fact_WorkItems.tmdl`.
4. Validar que el parámetro `pSourceMode` y la arquitectura **WIQL-first** sigan operando (con CSV como modo de prueba).

## Publicación

1. Abrir el PBIP en Desktop y actualizar datos según modo (`CSV`, `WIQL` u `OData`) sin guardar secretos en el repo.
2. Ejecutar comprobaciones visuales de páginas y medidas.
3. Publicar al workspace objetivo desde Power BI Desktop.

## Tema visual AMSA

Tema de referencia disponible en:

- `powerbi-roadmap-soporte-daa/theme/amsa_powerbi_theme.json`

Aplicar desde Power BI Desktop: **View > Themes > Browse for themes**.
