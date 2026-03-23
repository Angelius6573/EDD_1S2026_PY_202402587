# Árbol BST — Binary Search Tree

## Definición

Un árbol binario de búsqueda organiza sus nodos de modo que para cualquier nodo `N`:
- Todos los nodos del subárbol **izquierdo** tienen clave **menor** que `N`.
- Todos los nodos del subárbol **derecho** tienen clave **mayor** que `N`.

## Propiedades en esta implementación

- **Clave de ordenamiento:** código del equipo (String, comparación lexicográfica).
- **Sin balanceo automático:** si los datos se insertan en orden, el árbol puede degradarse a una lista (O(n) en el peor caso). Para equipos médicos, la inserción es suficientemente aleatoria como para mantener una altura razonable.
- **Sin claves duplicadas:** si se intenta insertar un código ya existente, se muestra error.

## Recorridos

| Recorrido | Secuencia | Resultado |
|-----------|-----------|-----------|
| In-Orden | izq → raíz → der | Equipos ordenados por código |
| Pre-Orden | raíz → izq → der | Útil para copiar el árbol |
| Post-Orden | izq → der → raíz | Útil para liberar memoria |

---

[← Volver a Estructuras](README.md)
