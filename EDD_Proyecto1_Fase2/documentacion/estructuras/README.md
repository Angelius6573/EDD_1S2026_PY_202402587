# Estructuras de Datos — EDD MedTrack Fase 2

Este módulo documenta todas las estructuras de datos implementadas en la Fase 2. Todas han sido desarrolladas manualmente en Perl, sin el uso de librerías externas.

---

## Nuevas estructuras (Fase 2)

| Estructura | Uso en el sistema | Documentación |
|------------|------------------|---------------|
| Árbol BST | Inventario de equipos médicos (EQU-xxx) | [arbol_bst.md](arbol_bst.md) |
| Árbol AVL | Personal médico autorizado | [arbol_avl.md](arbol_avl.md) |
| Árbol B Orden 4 | Inventario de suministros médicos (SUM-xxx) | [arbol_b.md](arbol_b.md) |

## Estructuras heredadas (Fase 1, actualizadas)

| Estructura | Uso en el sistema | Documentación |
|------------|------------------|---------------|
| Lista Doblemente Enlazada | Inventario de medicamentos (MED-xxx) | [lista_doble.md](lista_doble.md) |
| Lista Circular Doblemente Enlazada | Proveedores del hospital | [lista_circular_doble.md](lista_circular_doble.md) |
| Matriz Dispersa | Relación proveedor ↔ fabricante | [matriz_dispersa.md](matriz_dispersa.md) |

---

## Comparativa general

| Estructura | Tipo | Inserción | Búsqueda | Balance automático |
|------------|------|:---------:|:--------:|:-----------------:|
| Lista Doble | Lineal | O(n) ordenada | O(n) | — |
| Lista Circular Doble | Lineal | O(1) extremos | O(n) | — |
| Matriz Dispersa | Lineal (hash) | O(1) | O(1) | — |
| Árbol BST | No lineal | O(log n) promedio | O(log n) promedio | No |
| Árbol AVL | No lineal | O(log n) garantizado | O(log n) garantizado | Sí |
| Árbol B Orden 4 | No lineal | O(log n) garantizado | O(log n) garantizado | Sí (altura uniforme) |

---

## Principio de separación de estructuras

El sistema usa estructuras diferentes para cada tipo de inventario deliberadamente:

- **Lista doble** para medicamentos: permite inserción ordenada por código y recorrido secuencial eficiente, adecuado para listas de tamaño moderado.
- **Árbol BST** para equipos: búsquedas frecuentes de disponibilidad por código hacen que el acceso en O(log n) sea más eficiente que O(n) de la lista.
- **Árbol B** para suministros: alta rotación de ítems y grandes volúmenes se benefician de la menor altura del árbol B frente al BST.
- **Árbol AVL** para usuarios: el auto-balanceo garantiza tiempos de autenticación consistentes independientemente del orden de registro del personal.

---

[← Volver al README principal](../../README.md)
