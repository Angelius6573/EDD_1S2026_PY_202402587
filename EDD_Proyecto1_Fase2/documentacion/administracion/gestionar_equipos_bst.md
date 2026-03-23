# Gestionar Inventario de Equipos Médicos — Árbol BST

El administrador accede a este submenú para gestionar todos los equipos médicos (prefijo `EQU-`) almacenados en el Árbol BST. Las operaciones disponibles son inserción, búsqueda, eliminación y visualización por recorridos.

---

## ¿Qué es un Árbol BST?

Un **Árbol Binario de Búsqueda** (Binary Search Tree) es una estructura no lineal donde cada nodo tiene a lo sumo dos hijos. La propiedad fundamental es:

```
Para todo nodo N:
  - Todos los nodos del subárbol izquierdo tienen clave < clave(N)
  - Todos los nodos del subárbol derecho tienen clave > clave(N)
```

Esta propiedad permite búsquedas en O(log n) en el caso promedio.

```
           EQU-005
          /       \
       EQU-002   EQU-008
       /    \        \
  EQU-001  EQU-003  EQU-010
```

| Operación | Caso promedio | Caso peor |
|-----------|:-------------:|:---------:|
| Insertar  | O(log n) | O(n) árbol degenerado |
| Buscar    | O(log n) | O(n) |
| Eliminar  | O(log n) | O(n) |

---

## Estructura de un nodo de equipo

```perl
my $nodo = {
    codigo         => "EQU-001",   # Clave de ordenamiento
    nombre         => "Tensiómetro Digital",
    fabricante     => "MediSupplyGT",
    precio_unitario => 350.00,
    cantidad       => 25,
    fecha_ingreso  => "2026-03-15",
    nivel_minimo   => 5,
    izquierdo      => undef,       # Hijo izquierdo
    derecho        => undef,       # Hijo derecho
};
```

---

## Operaciones disponibles

### 2.1 Registrar equipo individual

El administrador completa un formulario GTK3 con los siguientes campos:

| Campo | Tipo | Requerido |
|-------|------|:---------:|
| Código (EQU-XXX) | String | ✓ |
| Nombre | String | ✓ |
| Fabricante | String | ✓ |
| Precio unitario | Decimal ≥ 0 | ✓ |
| Cantidad | Entero > 0 | ✓ |
| Fecha de ingreso | YYYY-MM-DD | ✓ |
| Nivel mínimo | Entero > 0 | ✓ |

El sistema verifica que el código no exista previamente en el árbol antes de insertar.

**Algoritmo de inserción:**
```perl
sub insertar {
    my ($self, $nodo_nuevo) = @_;
    if (!defined $self->{raiz}) {
        $self->{raiz} = $nodo_nuevo;
        return;
    }
    my $actual = $self->{raiz};
    while (1) {
        if ($nodo_nuevo->{codigo} lt $actual->{codigo}) {
            if (!defined $actual->{izquierdo}) {
                $actual->{izquierdo} = $nodo_nuevo; last;
            }
            $actual = $actual->{izquierdo};
        } else {
            if (!defined $actual->{derecho}) {
                $actual->{derecho} = $nodo_nuevo; last;
            }
            $actual = $actual->{derecho};
        }
    }
}
```

---

### 2.2 Buscar equipo por código

El sistema recorre el árbol comparando el código buscado con la clave de cada nodo:

- Si `clave < nodo_actual` → ir al hijo izquierdo.
- Si `clave > nodo_actual` → ir al hijo derecho.
- Si `clave == nodo_actual` → mostrar información completa del equipo.
- Si se llega a `undef` → mostrar mensaje "Equipo no encontrado".

---

### 2.3 Eliminar equipo del inventario

La eliminación en un BST maneja tres casos:

| Caso | Descripción | Acción |
|------|-------------|--------|
| Nodo hoja | Sin hijos | Eliminación directa |
| Un hijo | Solo izquierdo o solo derecho | El padre apunta al hijo del nodo eliminado |
| Dos hijos | Ambos hijos presentes | Reemplazar con el sucesor in-orden (mínimo del subárbol derecho) |

```perl
sub _encontrar_minimo {
    my ($nodo) = @_;
    while (defined $nodo->{izquierdo}) {
        $nodo = $nodo->{izquierdo};
    }
    return $nodo;
}
```

---

### 2.4 Visualizar inventario por recorridos

Desde el panel del administrador se pueden seleccionar tres tipos de recorrido:

**Pre-Orden** (raíz → izq → der):
```perl
sub pre_orden {
    my ($self, $nodo, $resultado) = @_;
    return unless defined $nodo;
    push @$resultado, $nodo;
    $self->pre_orden($nodo->{izquierdo}, $resultado);
    $self->pre_orden($nodo->{derecho},   $resultado);
}
```

**In-Orden** (izq → raíz → der) — produce la lista ordenada por código:
```perl
sub in_orden {
    my ($self, $nodo, $resultado) = @_;
    return unless defined $nodo;
    $self->in_orden($nodo->{izquierdo}, $resultado);
    push @$resultado, $nodo;
    $self->in_orden($nodo->{derecho},   $resultado);
}
```

**Post-Orden** (izq → der → raíz):
```perl
sub post_orden {
    my ($self, $nodo, $resultado) = @_;
    return unless defined $nodo;
    $self->post_orden($nodo->{izquierdo}, $resultado);
    $self->post_orden($nodo->{derecho},   $resultado);
    push @$resultado, $nodo;
}
```

Los resultados se muestran en una tabla GTK3 dentro del panel de recorridos.

---

## Reporte gráfico

El reporte del Árbol BST se genera con Graphviz y se muestra en la sección de reportes del administrador. Ver [Reporte Árbol BST](../reportes/ReportesGraficos.md#reporte-árbol-bst).

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
