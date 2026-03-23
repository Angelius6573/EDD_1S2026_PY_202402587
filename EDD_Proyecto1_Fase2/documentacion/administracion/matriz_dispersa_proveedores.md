# Consultar y Comparar Inventario por Proveedor/Fabricante — Matriz Dispersa

Esta función evoluciona la matriz dispersa de la Fase 1. En lugar de relacionar laboratorios con medicamentos, ahora relaciona **proveedores** (filas) con **fabricantes** (columnas), almacenando en cada celda la cantidad total de productos que ese proveedor ha entregado provenientes de ese fabricante.

---

## Concepto de Matriz Dispersa

Una **matriz dispersa** almacena únicamente las celdas con valores distintos de cero. Esto ahorra memoria cuando la mayoría de las combinaciones proveedor-fabricante no existen (lo cual es habitual: cada proveedor trabaja con pocos fabricantes).

```
Matriz real:
               LabFarma  MediSupplyGT  GenericLab  BuenaVidaGT
Juanito Prov.    5000        75000         0            0
Benito Prov.      0         20000        5500         40000

Representación interna (solo celdas no vacías):
{
  "Juanito Prov.,LabFarma"      => 5000,
  "Juanito Prov.,MediSupplyGT"  => 75000,
  "Benito Prov.,MediSupplyGT"   => 20000,
  "Benito Prov.,GenericLab"     => 5500,
  "Benito Prov.,BuenaVidaGT"    => 40000,
}
```

| Operación | Complejidad |
|-----------|:-----------:|
| Insertar/actualizar celda | O(1) |
| Consultar celda | O(1) |
| Recorrer fila (proveedor) | O(f), f = fabricantes del proveedor |
| Recorrer columna (fabricante) | O(p), p = proveedores del fabricante |
| Espacio en memoria | O(k), k = celdas no vacías |

---

## Estructura interna en Perl

```perl
my $matriz = {
    datos      => {},   # Hash: "proveedor,fabricante" => cantidad_total
    proveedores => [],  # Lista ordenada de nombres de fila
    fabricantes => [],  # Lista ordenada de nombres de columna
};
```

### Insertar o acumular un valor

Cada vez que se procesa una entrega, la cantidad se **acumula** (no se sobreescribe):

```perl
sub agregar_entrega {
    my ($self, $proveedor, $fabricante, $cantidad) = @_;
    my $clave = "$proveedor,$fabricante";
    $self->{datos}{$clave} = ($self->{datos}{$clave} // 0) + $cantidad;

    # Registrar fila/columna si es nueva
    push @{ $self->{proveedores} }, $proveedor
        unless grep { $_ eq $proveedor } @{ $self->{proveedores} };
    push @{ $self->{fabricantes} }, $fabricante
        unless grep { $_ eq $fabricante } @{ $self->{fabricantes} };
}
```

### Consultar un valor

```perl
sub obtener {
    my ($self, $proveedor, $fabricante) = @_;
    my $clave = "$proveedor,$fabricante";
    return $self->{datos}{$clave} // 0;
}
```

---

## Vista en la interfaz

La matriz se presenta como una tabla GTK3 donde:

- Las **filas** corresponden a los proveedores de la lista circular doblemente enlazada.
- Las **columnas** corresponden a los fabricantes detectados en las entregas.
- Las **celdas** muestran la cantidad total entregada (celdas vacías = sin relación comercial).

Si un proveedor está asociado a más de un fabricante, todas sus relaciones activas se muestran resaltadas en la misma fila.

Ejemplo de vista en tabla:

| Proveedor | LabFarma | MediSupplyGT | GenericLab | BuenaVidaGT |
|-----------|:--------:|:------------:|:----------:|:-----------:|
| Juanito proveedor | 5,000 | 75,000 | — | — |
| Benito proveedor | — | 20,000 | 5,500 | 40,000 |

---

## Llenado automático desde carga masiva

La matriz se actualiza automáticamente cada vez que:
1. Se realiza una **carga masiva de inventario** (JSON).
2. Se **registra una entrega manual** de proveedor.

En ambos casos, para cada ítem de la entrega se invoca `agregar_entrega($proveedor, $item->{fabricante}, $item->{cantidad})`.

---

## Reporte gráfico

Ver [Reporte Matriz Dispersa](../reportes/ReportesGraficos.md#reporte-matriz-dispersa).

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
