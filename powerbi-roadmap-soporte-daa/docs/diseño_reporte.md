# Diseño de reporte ejecutivo AMSA (implementación PBIP/PBIX)

> Estado actual en este repositorio: no se detectan archivos `.pbip/.pbir/.tmdl` para editar visuales directamente. Esta guía deja la estructura exacta para implementarla en Power BI Desktop manteniendo `Fact_WorkItems`.

## Tema visual corporativo
- Importar `theme/amsa_powerbi_theme.json`.
- Fondo general: `#F5F6F8`.
- Colores principales:
  - Azul oscuro `#003A70`
  - Azul medio `#0072CE`
  - Celeste claro `#EAF4FB`
  - Verde `#2E7D32`
  - Amarillo `#F9A825`
  - Rojo `#C62828`
  - Gris `#9E9E9E`

## Página 1 — Validación Técnica
Objetivo: verificar que `Fact_WorkItems` carga bien y que filtros/modelo no rompieron.

Visuales:
- Cards: Total Work Items, Total Tracks, Total User Stories, Total Tasks.
- Card: Tasks Sin Responsable.
- Card: Work Items con jerarquía incompleta.
- Tabla QA: `WorkItemId`, `WorkItemType`, `TrackCode`, `TrackName`, `HierarchyStatus`, `AssignedToName`, `StateNormalized`.
- Slicers: `SourceMode`, `TrackCode`, `WorkItemType`.

## Página 2 — Consolidado Ejecutivo
Visuales:
- Cards: Total Work Items, Total Tracks, Total User Stories, Total Tasks, Tasks sin responsable, Avance Global %.
- Barras horizontales: Avance por Track (%).
- Columnas apiladas: Estado por Track (Pendiente/En curso/Cerrado/Otro).
- Donut: Distribución por `StateNormalized`.
- Tabla ejecutiva por track:
  - `TrackCode`, `TrackName`, Total Tasks, Tasks Cerradas, Tasks Pendientes, % Avance, Estado Ejecutivo, Tasks sin Responsable.

## Página 3 — Detalle por Track
Visuales:
- Segmentador: `TrackCode` + `TrackName`.
- Cards: Track seleccionado, Total Tasks, Tareas Abiertas, Tareas Cerradas, % Avance.
- Matriz jerárquica: `FeatureTitle` > `UserStoryTitle` > `TaskTitle`.
- Tabla: Tareas abiertas (`IsTask=true` y `StateNormalized<>"Cerrado"`).
- Tabla: Tareas sin responsable (`IsTask=true` y `HasOwner=false`).
- Barras: conteo por estado.
- Barras: conteo por responsable.

## Página 4 — Seguimiento Operativo
Visuales:
- Tabla completa: work items con columnas clave operativas.
- Slicers: `TrackCode`, `WorkItemType`, `StateNormalized`, `AssignedToName`, `HierarchyStatus`.
- Barras: tareas por responsable.
- Donut/Barras: tareas por estado.
- Barras: tareas por track.

## Página 5 — Calidad de Datos
Visuales:
- KPI: Work items sin responsable.
- KPI: Tracks sin clasificar (`TrackCode="T00"`).
- KPI: Work items con jerarquía incompleta.
- KPI: User Stories sin Feature.
- KPI: Tasks sin User Story.
- Tabla problemática filtrable:
  - `HierarchyStatus<>"Completa"` OR `HasOwner=false` OR `TrackCode="T00"`.

## Página 6 — Roadmap / Próximos Hitos
Visuales:
- Backlog por track (tareas abiertas).
- Tareas abiertas por track y estado.
- Tabla “Hitos candidatos”: tasks abiertas con prioridad/board cuando exista.
- Nota visible obligatoria:
  - "Roadmap temporal real requiere Due Date, Target Date, Iteration Path o fechas equivalentes."

## Reglas de consistencia
- Mantener `Fact_WorkItems` como tabla base.
- No cambiar parámetros M existentes.
- No guardar credenciales/secretos en el archivo.
