# Reportes Gráficos con Graphviz

Todos los reportes se generan mediante la herramienta `dot` de Graphviz. El sistema Perl produce un archivo `.dot` con la descripción del grafo y ejecuta el comando para generar la imagen PNG, que luego se muestra en la interfaz mediante un `Gtk3::Image`.

Los reportes se regeneran automáticamente cada vez que se modifica la estructura correspondiente.

---

## Generación de imágenes

```perl
sub generar_imagen {
    my ($ruta_dot, $ruta_png) = @_;
    my $cmd = "dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>&1";
    my $salida = `$cmd`;
    if ($? != 0) {
        warn "Error al generar imagen: $salida";
    }
}
```

---

## Reporte Árbol BST

Muestra la estructura completa del Árbol BST de equipos médicos.

**Especificaciones visuales:**
- Nodos rectangulares con la información del equipo (código, nombre, cantidad, fabricante).
- Aristas etiquetadas: `izq` hacia hijo izquierdo, `der` hacia hijo derecho.
- La raíz se distingue con borde más grueso.
- Los nodos hoja tienen fondo de color diferenciado.

**Ejemplo de archivo `.dot` generado:**

```dot
digraph BST_Equipos {
    graph [charset="UTF-8" fontname="Arial"]
    node  [shape=record fontname="Arial" fontsize=10]
    edge  [fontname="Arial" fontsize=9]

    EQU001 [label="{EQU-001|Tensiómetro Digital|Cant: 25|MediSupplyGT}"
            style=filled fillcolor="#D6EAF8"]
    EQU002 [label="{EQU-002|Oxímetro de Pulso|Cant: 40|BuenaVidaGT}"
            style=filled fillcolor="#D6EAF8"]
    EQU005 [label="{EQU-005|Desfibrilador|Cant: 3|MediSupplyGT}"
            style=filled fillcolor="#D6EAF8" penwidth=2]

    EQU005 -> EQU001 [label="izq"]
    EQU005 -> EQU002 [label="der"]
}
```

---

## Reporte Árbol AVL

Muestra la estructura del Árbol AVL con el personal médico autorizado.

**Especificaciones visuales:**
- Nodos **circulares** (`shape=circle` o `shape=ellipse`).
- Cada nodo muestra: número de colegio (clave), nombre completo, tipo y departamento.
- Se indica el **factor de balance** de cada nodo entre paréntesis.
- Aristas etiquetadas `izq` y `der`.

**Ejemplo de archivo `.dot` generado:**

```dot
digraph AVL_Personal {
    graph [charset="UTF-8" fontname="Arial"]
    node  [shape=ellipse fontname="Arial" fontsize=9
           style=filled fillcolor="#D5F5E3"]
    edge  [fontname="Arial" fontsize=8]

    COL20567 [label="COL-20567\nJorge Pineda\nTIPO-03 | DEP-MED\nFB: 0"]
    COL10245 [label="COL-10245\nAna Ramírez\nTIPO-01 | DEP-MED\nFB: 0"]
    COL30412 [label="COL-30412\nLuis Morales\nTIPO-04 | DEP-LAB\nFB: 0"]

    COL20567 -> COL10245 [label="izq"]
    COL20567 -> COL30412 [label="der"]
}
```

---

## Reporte Árbol B Orden 4

Muestra la estructura del Árbol B con los suministros médicos.

**Especificaciones visuales:**
- Nodos como **bloques horizontales segmentados** (`shape=record`), con una celda por clave.
- Flechas descendentes hacia cada hijo.
- Se indica el número de claves actuales y la capacidad máxima (ej. `2/3`).
- **Código de colores:**
  - 🟡 Amarillo (`#F9E79F`) — nodo con 3 claves (al límite).
  - 🟢 Verde (`#D5F5E3`) — nodo con espacio disponible.

**Ejemplo de archivo `.dot` generado:**

```dot
digraph ArbolB_Suministros {
    graph [charset="UTF-8" fontname="Arial"]
    node  [shape=record fontname="Arial" fontsize=10]
    edge  [fontname="Arial" fontsize=8]

    nodo0 [label="{SUM-004|SUM-008}" style=filled fillcolor="#D5F5E3"
           xlabel="2/3 claves"]
    nodo1 [label="{SUM-001|SUM-002}" style=filled fillcolor="#D5F5E3"
           xlabel="2/3 claves"]
    nodo2 [label="{SUM-005|SUM-006}" style=filled fillcolor="#D5F5E3"
           xlabel="2/3 claves"]
    nodo3 [label="{SUM-010|SUM-012|SUM-015}" style=filled fillcolor="#F9E79F"
           xlabel="3/3 claves"]

    nodo0 -> nodo1
    nodo0 -> nodo2
    nodo0 -> nodo3
}
```

---

## Reporte Matriz Dispersa

Visualiza la matriz dispersa de proveedores vs. fabricantes. Solo se representan las celdas con valores distintos de cero.

**Especificaciones visuales:**
- **Nodos cabecera de fila** (proveedores): rectángulos con borde azul.
- **Nodos cabecera de columna** (fabricantes): rectángulos con borde verde.
- **Nodos de valor**: círculos que contienen la cantidad total entregada.
- Conexiones horizontales desde la cabecera de fila hacia los nodos de valor.
- Conexiones verticales desde los nodos de valor hacia las cabeceras de columna.

**Ejemplo de archivo `.dot` generado:**

```dot
digraph MatrizDispersa {
    graph [charset="UTF-8" fontname="Arial" rankdir=LR]
    node  [fontname="Arial" fontsize=10]

    // Cabeceras de fila (proveedores)
    prov0 [shape=rectangle label="Juanito\nproveedor" style=filled fillcolor="#AED6F1"]
    prov1 [shape=rectangle label="Benito\nproveedor"  style=filled fillcolor="#AED6F1"]

    // Cabeceras de columna (fabricantes)
    fab0 [shape=rectangle label="LabFarma"     style=filled fillcolor="#A9DFBF"]
    fab1 [shape=rectangle label="MediSupplyGT" style=filled fillcolor="#A9DFBF"]
    fab2 [shape=rectangle label="GenericLab"   style=filled fillcolor="#A9DFBF"]
    fab3 [shape=rectangle label="BuenaVidaGT"  style=filled fillcolor="#A9DFBF"]

    // Nodos de valor (solo celdas no vacías)
    v00 [shape=circle label="5,000"]
    v01 [shape=circle label="75,000"]
    v11 [shape=circle label="20,000"]
    v12 [shape=circle label="5,500"]
    v13 [shape=circle label="40,000"]

    // Conexiones
    prov0 -> v00 -> fab0
    prov0 -> v01 -> fab1
    prov1 -> v11 -> fab1
    prov1 -> v12 -> fab2
    prov1 -> v13 -> fab3
}
```

---

## Reporte Lista Doblemente Enlazada (Medicamentos)

Reporte heredado de la Fase 1. Muestra cada medicamento como un nodo rectangular con flechas bidireccionales entre nodos consecutivos.

---

## Reporte Lista Circular Doblemente Enlazada (Proveedores)

Reporte heredado de la Fase 1, actualizado para la lista circular **doble**. Muestra los proveedores como nodos en un anillo con flechas en ambos sentidos y la conexión del último nodo de vuelta al primero.

---

## Visualización en la interfaz

El administrador accede a todos los reportes desde el botón **Reportes** del panel. Se abre una subventana con pestañas, una por cada reporte. Las imágenes PNG se cargan en un `Gtk3::Image` dentro de un `Gtk3::ScrolledWindow` para permitir desplazamiento en reportes grandes.

```perl
sub mostrar_reporte {
    my ($ruta_png) = @_;
    my $imagen   = Gtk3::Image->new_from_file($ruta_png);
    my $scroll   = Gtk3::ScrolledWindow->new;
    $scroll->set_policy('automatic', 'automatic');
    $scroll->add($imagen);
    return $scroll;
}
```

---

[← Volver al README principal](../README.md)
