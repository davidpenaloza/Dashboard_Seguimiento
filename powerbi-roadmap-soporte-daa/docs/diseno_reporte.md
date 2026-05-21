# Diseño recomendado del reporte Power BI

## Página 1: Consolidado Ejecutivo de Tracks
Cards: Total Tracks, Total User Stories, Total Tasks, Avance Global %, Tasks sin responsable.
Visuales: barras Avance por Track, donut Tasks por estado, tabla ejecutiva con TrackCode, TrackName, Owner, Hands, ExecutiveStatus, Total Tasks, Tasks Cerradas, Avance %, Próximo hito, Riesgo principal.
Extra: tarjetas pequeñas por track para vista portafolio.

## Página 2: Detalle por Track
Filtros: Track, Estado, Responsable.
Cards: Track seleccionado, Avance, Total tareas, Cerradas, Abiertas.
Visuales: matriz Feature > User Story > Task; tabla tareas abiertas; tabla tareas sin responsable; bloque de metadata ejecutiva (Objective, Comment, NextMilestones, Dependencies, Risks, AdditionalInfo).

## Página 3: Seguimiento Operativo
Visuales: tabla completa de work items, segmentadores Track/Type/State/AssignedTo/Tags, tareas por responsable, tareas por estado, tareas por track, tabla sin responsable, tareas abiertas por User Story.

## Página 4: Roadmap / Próximos Hitos
Uso actual (sin fechas): backlog candidato por track, tareas abiertas, matriz jerárquica.
**Nota obligatoria visible:** roadmap temporal real requiere Due Date / Target Date / Iteration Path / Sprint / Start Date / Closed Date.

## Página 5 (opcional): Calidad de Datos
Visuales: tasks sin responsable, tracks sin tareas, user stories sin tasks, items sin tags, estados no normalizados, registros incompletos.
