# Modelo de datos propuesto

## Tablas
1. **Fact_WorkItems**: granularidad 1 fila = 1 work item (Feature, User Story o Task).
2. **Dim_Tracks**: catálogo de tracks y metadata ejecutiva.
3. **Dim_Status**: catálogo de estados normalizados (Pendiente, En curso, Cerrado, Otro).
4. **Dim_WorkItemType**: catálogo de tipos (Feature, User Story, Task).
5. **Dim_AssignedTo**: catálogo de responsables (nombre/correo).

## Relaciones
- `Fact_WorkItems[TrackCode]` -> `Dim_Tracks[TrackCode]` (Muchos a uno).
- `Fact_WorkItems[StateNormalized]` -> `Dim_Status[StateNormalized]` (Muchos a uno).
- `Fact_WorkItems[WorkItemType]` -> `Dim_WorkItemType[WorkItemType]` (Muchos a uno).
- `Fact_WorkItems[AssignedToEmail]` -> `Dim_AssignedTo[AssignedToEmail]` (Muchos a uno, opcional si hay nulos).

## Reglas de negocio
- Feature = Track.
- User Story = agrupación funcional.
- Task = actividad operativa base de avance.
- Avance simple = Tasks cerradas / total tasks.
- Avance ponderado = promedio de `ProgressWeight` en tasks.

## Dim_Tracks sugerida (inicial)

| TrackCode | TrackName | Owner | Hands | ExecutiveStatus | Objective | Comment | Priority | CurrentFocus | NextMilestones | Dependencies | Risks | AdditionalInfo |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| T01 | Plataforma de Monitoreo | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Media | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T02 | Automatizaciones Operativas | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Alta | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T03 | Dashboard de Gestión | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Alta | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T04 | Portal Interno de Soporte | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Media | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T05 | IA GEN | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Media | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T06 | Capacitaciones | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Media | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T07 | Grafana | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Media | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |
| T08 | Permisologías y Accesos | POR DEFINIR | POR DEFINIR | En curso | Definir | Completar metadata | Alta | Carga inicial | Definir hito | Sin detallar | Sin detallar | MVP CSV |

