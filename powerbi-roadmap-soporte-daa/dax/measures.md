# Medidas DAX sugeridas (Fact_WorkItems)

> Supuesto: la tabla principal se llama `Fact_WorkItems`.

```DAX
Total Work Items = COUNTROWS(Fact_WorkItems)

Total Tracks = DISTINCTCOUNT(Fact_WorkItems[TrackCode])

Total User Stories =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsUserStory] = TRUE()
)

Total Tasks =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsTask] = TRUE()
)

Tasks Pendientes =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsTask] = TRUE(),
    Fact_WorkItems[StateNormalized] = "Pendiente"
)

Tasks En Curso =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsTask] = TRUE(),
    Fact_WorkItems[StateNormalized] = "En curso"
)

Tasks Cerradas =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsTask] = TRUE(),
    Fact_WorkItems[StateNormalized] = "Cerrado"
)

Tasks Sin Responsable =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsTask] = TRUE(),
    Fact_WorkItems[HasOwner] = FALSE()
)

% Tasks Sin Responsable = DIVIDE([Tasks Sin Responsable], [Total Tasks])

Avance Global % = DIVIDE([Tasks Cerradas], [Total Tasks])

Avance Track % = [Avance Global %]

Avance Ponderado % =
DIVIDE(
    SUMX(
        FILTER(Fact_WorkItems, Fact_WorkItems[IsTask] = TRUE()),
        Fact_WorkItems[ProgressWeight]
    ),
    CALCULATE(
        COUNTROWS(Fact_WorkItems),
        Fact_WorkItems[IsTask] = TRUE()
    )
)

User Stories Cerradas =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsUserStory] = TRUE(),
    Fact_WorkItems[StateNormalized] = "Cerrado"
)

User Stories Pendientes =
CALCULATE(
    COUNTROWS(Fact_WorkItems),
    Fact_WorkItems[IsUserStory] = TRUE(),
    Fact_WorkItems[StateNormalized] = "Pendiente"
)

Tracks Sin Detalle =
VAR tTracks = VALUES(Dim_Tracks[TrackCode])
VAR tConTasks = VALUES(Fact_WorkItems[TrackCode])
RETURN COUNTROWS(EXCEPT(tTracks, tConTasks))

Tracks En Curso =
COUNTROWS(
    FILTER(
        VALUES(Fact_WorkItems[TrackCode]),
        CALCULATE([Avance Ponderado %]) > 0 && CALCULATE([Avance Ponderado %]) < 1
    )
)

Tracks Cerrados =
COUNTROWS(
    FILTER(
        VALUES(Fact_WorkItems[TrackCode]),
        CALCULATE([Avance Ponderado %]) = 1
    )
)

Estado Ejecutivo =
SWITCH(
    TRUE(),
    [Avance Ponderado %] = 0, "No iniciado",
    [Avance Ponderado %] > 0 && [Avance Ponderado %] < 1, "En curso",
    [Avance Ponderado %] = 1, "Cerrado",
    "Sin información"
)

Color Estado =
SWITCH(
    [Estado Ejecutivo],
    "Cerrado", "#2E7D32",
    "En curso", "#F9A825",
    "No iniciado", "#9E9E9E",
    "Sin información", "#BDBDBD",
    "#BDBDBD"
)
```
