# Query WIQL requerida

La query guardada debe incluir tipos: `Feature`, `User Story`, `Task`.

## Campos mínimos
- ID
- Work Item Type
- Title
- State
- Assigned To
- Tags

## Campos recomendados
- Parent
- Area Path
- Iteration Path
- Created Date
- Changed Date
- Closed Date
- Priority
- Board Column
- Board Column Done

## Escenarios soportados
- **Tree/jerárquica**: con `Title 1`, `Title 2`, `Title 3`.
- **Flat con parent**: con `WorkItemId`, `ParentWorkItemId`, `WorkItemType`, `Title`.

Si viene flat sin parent, se conserva visibilidad total y `HierarchyStatus` marca jerarquía incompleta.
