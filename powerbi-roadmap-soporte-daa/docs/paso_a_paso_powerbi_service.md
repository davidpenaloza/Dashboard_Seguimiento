# Paso a paso Power BI Service

- Publicar PBIX en workspace objetivo.
- En Dataset > Settings, configurar credenciales Azure DevOps.
- Configurar gateway si la política corporativa lo exige.
- Activar refresh programado.
- Validar permisos del usuario/service principal sobre org/proyecto/team/query WIQL.

## Errores comunes
- Credenciales inválidas.
- Usuario sin permiso a la query guardada.
- `pAdoQueryId` incorrecto.
- `pAdoProject` o `pAdoTeam` incorrectos.
- Cambio de columnas en query WIQL que rompe transformaciones.
