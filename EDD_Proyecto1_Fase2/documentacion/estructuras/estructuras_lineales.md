# Lista Doblemente Enlazada — Inventario de Medicamentos

Estructura heredada de la Fase 1, sin cambios funcionales. Almacena los medicamentos (`MED-xxx`) ordenados por código.

## Diagrama

```
[Cabeza]                                    [Cola]
   │                                           │
   ▼                                           ▼
┌───┬──────────┬───┐    ┌───┬──────────┬───┐    ┌───┬──────────┬───┐
│ / │ MED-001  │ ──┼───►│ ◄─│ MED-002  │ ──┼───►│ ◄─│ MED-009  │ / │
└───┴──────────┴───┘    └───┴──────────┴───┘    └───┴──────────┴───┘
```

## Nodo

```perl
my $nodo = {
    dato      => {    # Hash con los datos del medicamento
        codigo            => "MED-001",
        nombre            => "Tylenol",
        principio_activo  => "Paracetamol",
        fabricante        => "LabFarma",
        precio_unitario   => 2.50,
        cantidad          => 5000,
        fecha_vencimiento => "2026-12-31",
        nivel_minimo      => 500,
    },
    siguiente => undef,
    anterior  => undef,
};
```

## Complejidades

| Operación | Complejidad |
|-----------|:-----------:|
| Insertar ordenado por código | O(n) |
| Buscar por código | O(n) |
| Eliminar nodo conocido | O(1) |
| Recorrer completo | O(n) |

---

[← Volver a Estructuras](README.md)

---

# Lista Circular Doblemente Enlazada — Proveedores

Evolución de la lista circular simple de la Fase 1. Ahora cada nodo tiene puntero `siguiente` **y** `anterior`, formando un anillo bidireccional. Almacena los proveedores del hospital.

## Diagrama

```
  ┌────────────────────────────────────────────┐
  ▼                                            │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ ◄ Prov. A ──┼───►│ ◄ Prov. B ──┼───►│ ◄ Prov. C ──┼─┐
└─────────────┘    └─────────────┘    └─────────────┘ │
  ▲                                                   │
  └───────────────────────────────────────────────────┘
```

## Nodo de proveedor

```perl
my $nodo = {
    dato => {
        nit            => "98765432-1",
        nombre         => "Juanito proveedor",
        telefono       => "2245 6789",
        direccion      => "Zona 9, Ciudad de Guatemala",
        historial      => [   # Entregas registradas
            {
                fecha_entrega   => "2026-03-15",
                numero_factura  => "FAC-2026-00145",
                items_entregados => 3,
            }
        ],
    },
    siguiente => undef,
    anterior  => undef,
};
```

## Por qué lista circular

La naturaleza circular permite recorrer los proveedores de forma cíclica para tareas de rotación de consultas o reabastecimiento programado, retomando desde cualquier punto sin necesidad de reiniciar desde el inicio.

## Complejidades

| Operación | Complejidad |
|-----------|:-----------:|
| Insertar al inicio o al final | O(1) |
| Eliminar nodo conocido | O(1) |
| Buscar por NIT | O(n) |
| Recorrer completo | O(n) |

---

[← Volver a Estructuras](README.md)

---

# Matriz Dispersa — Proveedores vs. Fabricantes

Almacena únicamente las celdas con valor distinto de cero. Cada celda representa la cantidad total de productos entregados por un proveedor (fila) provenientes de un fabricante (columna).

## Representación interna

```perl
# Hash con clave compuesta "proveedor,fabricante"
my %datos = (
    "Juanito proveedor,LabFarma"     => 5000,
    "Juanito proveedor,MediSupplyGT" => 75000,
    "Benito proveedor,GenericLab"    => 5500,
    "Benito proveedor,BuenaVidaGT"   => 40000,
);
```

## Comparativa con arreglo 2D convencional

| Escenario | Arreglo 2D | Matriz Dispersa |
|-----------|:----------:|:---------------:|
| 10 proveedores, 50 fabricantes, 8 relaciones activas | 500 celdas | 8 entradas |
| Acceso a celda | O(1) | O(1) |
| Memoria usada | O(m × n) | O(k), k = relaciones activas |

---

[← Volver a Estructuras](README.md)
