# Carga Masiva de Inventario desde JSON

Esta función permite al administrador cargar múltiples productos al inventario en una sola operación seleccionando un archivo JSON desde el explorador de archivos de la interfaz GTK3.

---

## Estructura del archivo JSON

El archivo agrupa los ítems bajo uno o más objetos proveedor. Cada proveedor puede entregar productos de los tres tipos (`MEDICAMENTO`, `EQUIPO`, `SUMINISTRO`) en una misma entrega.

```json
{
  "proveedor": [
    {
      "nit": "98765432-1",
      "nombre": "Juanito proveedor",
      "telefono": "2245 6789",
      "direccion": "Zona 9, Ciudad de Guatemala",
      "fecha_entrega": "2026-03-15",
      "numero_factura": "FAC-2026-00145",
      "entrega": [
        {
          "tipo": "MEDICAMENTO",
          "codigo": "001",
          "nombre": "Tylenol",
          "principio_activo": "Paracetamol",
          "fabricante": "LabFarma",
          "precio_unitario": 2.50,
          "cantidad": 5000,
          "fecha_vencimiento": "2026-12-31",
          "nivel_minimo": 500
        },
        {
          "tipo": "EQUIPO",
          "codigo": "001",
          "nombre": "Tensiómetro Digital",
          "fabricante": "MediSupplyGT",
          "precio_unitario": 350.00,
          "cantidad": 25,
          "fecha_ingreso": "2026-03-15",
          "nivel_minimo": 5
        },
        {
          "tipo": "SUMINISTRO",
          "codigo": "001",
          "nombre": "Guantes de Nitrilo Talla M",
          "fabricante": "MediSupplyGT",
          "precio_unitario": 0.15,
          "cantidad": 50000,
          "fecha_vencimiento": "2028-01-01",
          "nivel_minimo": 5000
        }
      ]
    }
  ]
}
```

### Campos obligatorios por tipo

| Campo | MEDICAMENTO | EQUIPO | SUMINISTRO |
|-------|:-----------:|:------:|:----------:|
| `tipo` | ✓ | ✓ | ✓ |
| `codigo` | ✓ | ✓ | ✓ |
| `nombre` | ✓ | ✓ | ✓ |
| `fabricante` | ✓ | ✓ | ✓ |
| `precio_unitario` | ✓ | ✓ | ✓ |
| `cantidad` | ✓ | ✓ | ✓ |
| `nivel_minimo` | ✓ | ✓ | ✓ |
| `principio_activo` | ✓ | — | — |
| `fecha_vencimiento` | ✓ | — | Opcional |
| `fecha_ingreso` | — | ✓ | — |

---

## Flujo de procesamiento

```
Seleccionar archivo JSON
        │
        ▼
  Leer y parsear JSON
        │
        ▼
  Validar estructura
  (campos obligatorios,
   cantidades positivas,
   fechas con formato válido)
        │
   ┌────┴────┐
   │         │
Válido    Inválido → Mostrar advertencia con código del ítem
   │
   ▼
Enrutar por tipo:
  MEDICAMENTO → Lista Doblemente Enlazada (orden por código)
  EQUIPO      → Árbol BST                 (clave = código)
  SUMINISTRO  → Árbol B Orden 4           (clave = código)
        │
        ▼
Registrar proveedor en Lista Circular Doblemente Enlazada
+ agregar entrega al historial del proveedor
        │
        ▼
Actualizar Matriz Dispersa (proveedor ↔ fabricante)
```

---

## Validaciones aplicadas

- **Campos obligatorios presentes:** si falta algún campo requerido, el ítem se descarta con un mensaje de advertencia que indica el código del producto problemático.
- **Cantidades positivas:** `cantidad` y `nivel_minimo` deben ser enteros mayores que cero.
- **Formato de fecha:** se espera `YYYY-MM-DD`; cualquier otro formato provoca el descarte del ítem.
- **Tipo reconocido:** el valor de `"tipo"` debe ser exactamente `MEDICAMENTO`, `EQUIPO` o `SUMINISTRO` (sensible a mayúsculas).
- **Código de proveedor único por NIT:** si el NIT ya existe en la lista circular, se añade la entrega al historial del proveedor existente en lugar de duplicarlo.

---

## Implementación en Perl

La lectura del JSON se realiza con el módulo nativo `JSON` de Perl:

```perl
use JSON;

sub cargar_inventario_json {
    my ($ruta_archivo) = @_;
    open(my $fh, '<:encoding(UTF-8)', $ruta_archivo)
        or die "No se puede abrir $ruta_archivo: $!";
    local $/;
    my $contenido = <$fh>;
    close $fh;

    my $datos = decode_json($contenido);
    foreach my $proveedor (@{ $datos->{proveedor} }) {
        _registrar_proveedor($proveedor);
        foreach my $item (@{ $proveedor->{entrega} }) {
            _validar_y_enrutar($item, $proveedor);
        }
    }
}

sub _validar_y_enrutar {
    my ($item, $proveedor) = @_;
    return unless _es_valido($item);

    my $tipo = $item->{tipo};
    if    ($tipo eq 'MEDICAMENTO') { $lista_med->insertar_ordenado($item) }
    elsif ($tipo eq 'EQUIPO')      { $arbol_bst->insertar($item) }
    elsif ($tipo eq 'SUMINISTRO')  { $arbol_b->insertar($item) }

    # Actualizar matriz dispersa
    $matriz->set($proveedor->{nombre}, $item->{fabricante}, $item->{cantidad});
}
```

---

## Mensajes de error en la interfaz

Cuando un ítem no pasa la validación, se muestra un diálogo GTK3 con el siguiente formato:

```
⚠ Advertencia — Ítem descartado
Código: EQU-003
Motivo: El campo 'cantidad' debe ser un número positivo. Valor recibido: -10
```

La carga continúa con los ítems restantes; los errores no detienen el proceso completo.

---

### Regresar al panel de administración

[← Administrador](Administrador.md)
