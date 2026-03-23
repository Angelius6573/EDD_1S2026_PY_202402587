# Gestionar Inventario de Suministros Médicos — Árbol B de Orden 4

El administrador utiliza este submenú para gestionar los suministros médicos (prefijo `SUM-`) almacenados en el Árbol B de Orden 4. Esta estructura es especialmente adecuada para inventarios con alta rotación y grandes volúmenes de productos.

---

## ¿Qué es un Árbol B de Orden 4?

Un **Árbol B** es un árbol de búsqueda balanceado y multicamino. En un árbol de orden `m = 4`:

- Cada nodo puede contener entre `⌈m/2⌉ - 1 = 1` y `m - 1 = 3` claves.
- Cada nodo interno puede tener entre `⌈m/2⌉ = 2` y `m = 4` hijos.
- Todas las hojas están al mismo nivel (árbol perfectamente balanceado en altura).
- Las claves dentro de un nodo están ordenadas de menor a mayor.

```
         [SUM-004 | SUM-008]
        /         |          \
[SUM-001|SUM-002] [SUM-005|SUM-006] [SUM-010|SUM-012|SUM-015]
```

| Operación | Complejidad |
|-----------|:-----------:|
| Insertar  | O(log n) |
| Buscar    | O(log n) |
| Eliminar  | O(log n) |

La ventaja frente al BST es que, al manejar múltiples claves por nodo, la altura del árbol es menor y se producen menos accesos para encontrar un elemento, lo que es crítico en inventarios grandes.

---

## Estructura de un nodo

```perl
my $nodo = {
    claves    => [],      # Array de hasta 3 códigos de suministro
    datos     => [],      # Array de hashes con la información de cada suministro
    hijos     => [],      # Array de hasta 4 referencias a hijos
    es_hoja   => 1,       # 1 si es hoja, 0 si es nodo interno
    num_claves => 0,
};
```

---

## Estructura de un suministro (dato almacenado)

```perl
my $suministro = {
    codigo           => "SUM-001",
    nombre           => "Guantes de Nitrilo Talla M",
    fabricante       => "MediSupplyGT",
    precio_unitario  => 0.15,
    cantidad         => 50000,
    fecha_vencimiento => "2028-01-01",  # Opcional
    nivel_minimo     => 5000,
};
```

---

## Operaciones disponibles

### 3.1 Registrar suministro individual

El administrador llena un formulario GTK3 con los datos del suministro. El sistema verifica que el código no exista antes de insertar.

**Lógica de inserción (con división de nodo lleno):**

Cuando se intenta insertar en un nodo con 3 claves (lleno), se aplica la operación de *split*:

```
Nodo lleno: [SUM-002 | SUM-005 | SUM-008]
                ↓ insertar SUM-006
Resultado:
  Clave media sube al padre: SUM-005
  Nodo izquierdo: [SUM-002]
  Nodo derecho:   [SUM-006 | SUM-008]
```

```perl
sub _dividir_hijo {
    my ($self, $padre, $indice_hijo) = @_;
    my $hijo_lleno  = $padre->{hijos}[$indice_hijo];
    my $nuevo_nodo  = _crear_nodo($hijo_lleno->{es_hoja});
    my $clave_media = $hijo_lleno->{claves}[1]; # índice 1 es la clave media (orden 4)

    # Mover mitad derecha al nuevo nodo
    $nuevo_nodo->{claves}  = [$hijo_lleno->{claves}[2]];
    $nuevo_nodo->{datos}   = [$hijo_lleno->{datos}[2]];
    splice(@{ $hijo_lleno->{claves} }, 1);  # dejar solo clave[0]
    splice(@{ $hijo_lleno->{datos}  }, 1);

    # Subir clave media al padre
    splice(@{ $padre->{claves} }, $indice_hijo, 0, $clave_media);
    splice(@{ $padre->{hijos}  }, $indice_hijo + 1, 0, $nuevo_nodo);
    $padre->{num_claves}++;
}
```

---

### 3.2 Buscar suministro por código

El recorrido parte desde la raíz. En cada nodo se compara la clave buscada con las claves del nodo de izquierda a derecha hasta encontrarla o determinar en qué hijo continuar la búsqueda.

```perl
sub buscar {
    my ($self, $codigo, $nodo) = @_;
    $nodo //= $self->{raiz};
    return undef unless defined $nodo;

    my $i = 0;
    while ($i < $nodo->{num_claves} && $codigo gt $nodo->{claves}[$i]) {
        $i++;
    }
    if ($i < $nodo->{num_claves} && $codigo eq $nodo->{claves}[$i]) {
        return $nodo->{datos}[$i];   # Encontrado
    }
    return undef if $nodo->{es_hoja};
    return $self->buscar($codigo, $nodo->{hijos}[$i]);
}
```

---

### 3.3 Eliminar suministro del inventario

La eliminación en un Árbol B requiere mantener la propiedad de mínimo de claves. Los casos son:

| Caso | Acción |
|------|--------|
| Clave en hoja con claves suficientes | Eliminación directa |
| Clave en nodo interno | Reemplazar con predecesor/sucesor in-orden y eliminar ese nodo hoja |
| Hermano tiene claves para prestar | Redistribución (rotación): bajar clave del padre, subir clave del hermano |
| Hermanos sin claves para prestar | Fusión de nodos + bajar clave del padre |

---

### 3.4 Visualizar inventario por recorridos

El Árbol B soporta únicamente **In-Orden** en esta implementación, el cual produce los suministros ordenados por código de menor a mayor.

```perl
sub in_orden {
    my ($self, $nodo, $resultado) = @_;
    return unless defined $nodo;
    for my $i (0 .. $nodo->{num_claves} - 1) {
        $self->in_orden($nodo->{hijos}[$i], $resultado) unless $nodo->{es_hoja};
        push @$resultado, $nodo->{datos}[$i];
    }
    # Recorrer el último hijo derecho
    $self->in_orden($nodo->{hijos}[$nodo->{num_claves}], $resultado) unless $nodo->{es_hoja};
}
```

---

## Reporte gráfico

El reporte del Árbol B se genera con Graphviz, mostrando nodos segmentados por clave con código de colores:
- 🟡 **Amarillo** — nodo con 3 claves (al límite de capacidad).
- 🟢 **Verde** — nodo con espacio disponible.

Ver [Reporte Árbol B](../reportes/ReportesGraficos.md#reporte-árbol-b-orden-4).

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
