# Lista Circular Simple
Es una variante de la lista simple en la que el **último nodo apunta de vuelta al primero**, eliminando el concepto de un final absoluto. Esto es útil cuando el recorrido debe reiniciarse indefinidamente, como en planificadores por turnos o buffers de lectura.

```
  ┌─────────────────────────────────┐
  ▼                                 │
┌───┬───┐    ┌───┬───┐    ┌───┬───┐ │
│ A │ ──┼───►│ B │ ──┼───►│ C │ ──┼─┘
└───┴───┘    └───┴───┘    └───┴───┘
```

La condición de parada al recorrerla no es encontrar un nodo `undef`, sino volver al nodo de inicio:

```perl
my $actual = $self->{cabeza};
do {
  # procesar $actual->{dato}
  $actual = $actual->{siguiente};
} while ($actual != $self->{cabeza});
```

---
### Regresar al menú de listas
![<Regresar>](Reportes.md)
