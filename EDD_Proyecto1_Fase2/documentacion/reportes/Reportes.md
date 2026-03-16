# Reportes
## Documentación Asociada
| Módulo | README |
| ------ | ------ |
| Lista Simple | [Lista simple](lista_simple.md) |
| Lista Doblemente Enlazada | [Lista doblemente enlazada](lista_doblemente_enlazada.md) |
| Lista Circular Simple | [Lista circular simple](lista_circular_simple.md) |
| Lista Circular Doblemente Enlazada | [Lista circular doblemente enlazada](lista_circular_doblemente_enlazada.md) |
| Matriz Dispersa | [Matriz dispersa](matriz_dispersa.md) |

## Teoría

### Estructuras de Datos Lineales

Una **estructura de datos lineal** es aquella en la que los elementos se organizan de forma secuencial, donde cada elemento tiene un único predecesor y un único sucesor, a excepción del primero y el último. Esta característica distingue a las estructuras lineales de las no lineales como árboles o grafos, donde un nodo puede relacionarse con múltiples elementos simultáneamente.

Las estructuras lineales son fundamentales en el diseño de software porque modelan con naturalidad una gran variedad de problemas del mundo real: colas de espera, historiales de acciones, recorridos secuenciales, entre otros. Su implementación puede realizarse de dos formas principales: mediante **arreglos** (memoria contigua) o mediante **nodos enlazados** (memoria dinámica).

---

### El Nodo: Unidad Básica

La mayoría de las estructuras lineales dinámicas se construyen a partir de **nodos**, que son unidades de memoria que almacenan dos cosas: el dato en sí y una o más referencias hacia otros nodos. En su forma más simple un nodo luce así:

```
┌─────────┬───────────┐
│   Dato  │ Siguiente │──────► (siguiente nodo)
└─────────┴───────────┘
```

En implementaciones orientadas a objetos o con hashes (como en Perl), un nodo se representa típicamente como una estructura con campos:

```perl
my $nodo = {
  dato => $valor,
  siguiente => undef   # referencia al siguiente nodo
};
```

---

### Comparativa General

| Estructura | Dirección de recorrido | Circular | Acceso directo | Inserción O(1) en extremos |
| - | - | - | - | - |
| Lista Simple | Unidireccional | No | No | Solo inicio |
| Lista Doblemente Enlazada | Bidireccional | No | No | Inicio y final |
| Lista Circular Simple | Unidireccional | Sí | No | Solo inicio |
| Lista Circular Doblemente Enlazada | Bidireccional | Sí | No | Inicio y final |
| Matriz Dispersa | Por índice | No | Sí (hash) | N/A |

---

## Regresar al menú principal
[<Regresar>](../../README.md)
