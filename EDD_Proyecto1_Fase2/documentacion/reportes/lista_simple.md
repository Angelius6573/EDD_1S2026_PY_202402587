# Lista Simple (Enlazada)
Es la estructura lineal más básica. Cada nodo apunta únicamente al siguiente, formando una cadena unidireccional. El acceso siempre parte desde la **cabeza** de la lista.

```
[Cabeza]
   │
   ▼
 ┌───┬───┐    ┌───┬───┐    ┌───┬───┐
 │ A │ ──┼───►│ B │ ──┼───►│ C │ / │
 └───┴───┘    └───┴───┘    └───┴───┘
```

| Operación | Complejidad |
| --------- | ----------- |
| Insertar al inicio | O(1) |
| Insertar al final | O(n) |
| Buscar un elemento | O(n) |
| Eliminar al inicio | O(1) |
| Eliminar en posición arbitraria | O(n) |

Su principal limitación es que solo permite recorridos en un sentido, por lo que eliminar el último nodo o recorrer la lista en reversa requiere atravesarla completa.

---
### Regresar al menú de listas
![<Regresar>](Reportes.md)
