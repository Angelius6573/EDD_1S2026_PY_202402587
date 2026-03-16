# Lista Doblemente Enlazada
Extiende la lista simple añadiendo a cada nodo una referencia hacia el nodo **anterior**, además del siguiente. Esto permite recorridos en ambas direcciones y facilita operaciones como la eliminación de un nodo sin necesidad de mantener un puntero al predecesor de forma externa.

```
[Cabeza]                              [Cola]
   │                                    │
   ▼                                    ▼
┌───┬───┬───┐    ┌───┬───┬───┐    ┌───┬───┬───┐
│ / │ A │ ──┼───►│ ◄─│ B │ ──┼───►│ ◄─│ C │ / │
└───┴───┴───┘    └───┴───┴───┘    └───┴───┴───┘
```

```perl
my $nodo = {
  dato      => $valor,
  siguiente => undef,
  anterior  => undef
};
```

| Operación | Complejidad |
| - | - |
| Insertar al inicio o al final | O(1) |
| Eliminar cualquier nodo conocido | O(1) |
| Buscar un elemento | O(n) |

El costo es un mayor uso de memoria por el puntero adicional en cada nodo.

---
### Regresar al menú de listas
![<Regresar>](Reportes.md)
