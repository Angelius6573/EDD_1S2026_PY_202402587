# Lista Circular Doblemente Enlazada
Combina las características de la lista doblemente enlazada y la circular: cada nodo tiene referencias al siguiente y al anterior, y los extremos de la lista se conectan entre sí formando un anillo bidireccional.

```
  ┌─────────────────────────────────────┐
  ▼                                     │
┌───┬───┬───┐    ┌───┬───┬───┐    ┌───┬───┬───┐
│ ◄─│ A │ ──┼───►│ ◄─│ B │ ──┼───►│ ◄─│ C │ ──┼─┐
└───┴───┴───┘    └───┴───┴───┘    └───┴───┴───┘ │
  ▲                                             │
  └─────────────────────────────────────────────┘
```

Es la estructura más completa entre las listas enlazadas. Permite insertar y eliminar en cualquier extremo en O(1), recorrer en ambas direcciones y hacerlo de forma cíclica sin perder el hilo del recorrido. Es especialmente útil para modelar estructuras como colas de doble extremo, historial de navegación o cualquier lista que deba consultarse cíclicamente desde cualquier punto.

| Operación | Complejidad |
| --------- | ----------- |
| Insertar al inicio o al final | O(1) |
| Eliminar cualquier nodo conocido | O(1) |
| Recorrer en cualquier dirección | O(n) |
| Buscar un elemento | O(n) |

---
### Regresar al menú de listas
![<Regresar>](Reportes.md)
