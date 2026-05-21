# Conexión Azure DevOps por WIQL Query ID

Este dashboard usa como fuente principal el patrón del Reporte Gestión de Soporte: `VSTS.AccountContents` + `Functions[WiqlRunFlatWorkItemQueryById]` en modo Import.

## Parámetros
- `pAdoUrl`
- `pAdoCollection` (si aplica)
- `pAdoProject`
- `pAdoTeam`
- `pAdoQueryId`

## Patrón técnico
```powerquery
contents = (o) => VSTS.AccountContents(pAdoUrl, o)
Functions[WiqlRunFlatWorkItemQueryById](contents, pAdoUrl, [Collection=pAdoCollection, Project=pAdoProject, Team=pAdoTeam], pAdoQueryId)
```

## Credenciales
Se configuran en Power BI Desktop/Service. Nunca se almacenan en el repo (sin PAT/tokens/secretos).

## Limitaciones
Depende de permisos del usuario/service principal y estabilidad del esquema devuelto por la query WIQL guardada.

## Cuándo usar OData
Si se requiere modelo analítico más amplio, histórico y menos dependiente de una query puntual.
