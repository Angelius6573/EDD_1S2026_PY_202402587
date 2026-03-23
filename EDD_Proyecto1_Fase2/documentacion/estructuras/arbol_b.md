# Árbol B de Orden 4

## Definición

Un Árbol B de orden `m = 4` es un árbol de búsqueda balanceado multicamino donde:

- Cada nodo contiene entre `⌈m/2⌉ - 1 = 1` y `m - 1 = 3` claves ordenadas.
- Cada nodo interno tiene entre `⌈m/2⌉ = 2` y `m = 4` hijos.
- Todas las hojas se encuentran exactamente en el mismo nivel.
- Las claves en cada nodo están ordenadas: `clave[0] < clave[1] < clave[2]`.

## Propiedad estructural

```
Nodo con 2 claves (k1, k2) y 3 hijos (h0, h1, h2):

      [ k1 | k2 ]
      /    |    \
    h0     h1    h2

Donde:
  - Todos los elementos de h0 < k1
  - k1 < todos los elementos de h1 < k2
  - Todos los elementos de h2 > k2
```

## Comparativa con BST y AVL

| Aspecto | BST | AVL | Árbol B (orden 4) |
|---------|:---:|:---:|:-----------------:|
| Claves por nodo | 1 | 1 | 1 a 3 |
| Hijos por nodo | 0–2 | 0–2 | 0–4 |
| Balance garantizado | No | Sí | Sí (hojas mismo nivel) |
| Altura para n=1000 | ~10–1000 | ~10 | ~6–7 |
| Ideal para | Conjuntos pequeños | Autenticación | Inventarios grandes |

## División de nodo (split) al insertar

Cuando un nodo tiene 3 claves y se necesita insertar una más, se divide:

```
Antes del split:
  Nodo lleno: [ SUM-002 | SUM-005 | SUM-008 ]

Insertar SUM-006:
  Clave media (SUM-005) sube al padre
  Nodo izquierdo queda: [ SUM-002 ]
  Nodo derecho queda:   [ SUM-006 | SUM-008 ]
```

Esta operación ocurre de manera preventiva (top-down) al descender hacia la hoja de inserción, garantizando que siempre haya espacio disponible al llegar a la hoja.

## Fusión de nodos al eliminar

Si tras eliminar un nodo hoja este queda con 0 claves (incumple el mínimo de 1), se aplica:

1. **Redistribución:** si un hermano tiene 2 o 3 claves, se "presta" una clave a través del padre.
2. **Fusión:** si todos los hermanos tienen exactamente 1 clave, se fusionan dos nodos hermanos con la clave separadora del padre, reduciendo la altura si el padre también queda vacío.

---

[← Volver a Estructuras](README.md)
