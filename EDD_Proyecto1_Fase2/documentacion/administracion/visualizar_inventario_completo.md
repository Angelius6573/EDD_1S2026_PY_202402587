# Visualizar Inventario Completo
El administrador al elegir la opción 6 será llevado a un panel de información donde se mostrará la información almaceanada en ["inventario.json"](../../administrador/Inventario/inventario.json) de la siguiente manera:
| Código | Nombre | Principio Activo | Cantidad Disponible | Cantidad Mínima | Nivel de Cantidad Disponible | Vencimiento | Estado Caducidad |
| - | - | - | - | - | - | - | - |
| String | String | String | Int | Int | String | YYYY-MM-DD | String |

## Ordenamiento de los datos
Se emplea una lista doblemente enlazada en la subrutina ["ordenar_inventario"](../../administrador/Ver_Inventario/modulos/ordenar_inventario.pm) usando el método "**ordenar_por_campo**" de la lista para ordenar los datos usando el código del medicamento como referencia.
El sistema de ordenamiento es una implementación del método de ordenación "Bubble Sort", este método tiene una complejidad "***O(n²)***" por lo que, para este tipo de proyectos es asumible el costo computacional a cambio de la facilidad de implementación. ¿Qué es Bubble Sort o Ordenamiento de Burbuja? Es un método de ordenamiento que compara pares adyacentes, los intercambia entre ellos si están en orden incorrecto y repite hasta que no haya cambios.
```perl
sub ordenar_por_campo {
  my ($self, $campo) = @_;

  return if !$self->{cabeza};  # Lista vacía

  my $intercambiado;
  do {
    $intercambiado = 0;
    my $actual = $self->{cabeza};

    while ($actual && $actual->{siguiente}) {
      # Comparar el campo del nodo actual con el siguiente
      if ($actual->{datos}->{$campo} gt $actual->{siguiente}->{datos}->{$campo}) {
        # Intercambiar los datos completos
        my $temp = $actual->{datos};
        $actual->{datos} = $actual->{siguiente}->{datos};
        $actual->{siguiente}->{datos} = $temp;
        $intercambiado = 1;
      }
      $actual = $actual->{siguiente};
    }
  } while ($intercambiado);  # Repetir hasta que no haya intercambios
}
```

## Comprobaciones
### Existencias
El sistema compara la cantidad en existencias del inventario con la cantidad mínima permitida, usando el método ["verificar_cantidad"](../../administrador/Ver_Inventario/modulos/verificar_cantidad.pm) usando el concepto "**Clave-Valor**" para referenciar una cantidad con un estado de la siguiente manera:
```perl
  my @rangos = (
    { factor => 0.2 , estado => "<= 20% requerido"},
    { factor => 0.5 , estado => "<= 50% requerido"},
    { factor => 1 ,   estado => "Mínimo requerido"},
    { factor => 1.5 , estado => "Mínima asegurada"},
    { factor => 2 ,   estado => "Media asegurada"},
    { factor => 3 ,   estado => "Alta asegurada"},
    { factor => 4 ,   estado => "Suficiente"}
  );
```
Los puntos clave es la relación del porcentaje de cantidad con respecto a la cantidad mínima, por ejemplo, si la cantidad es 3 veces la cantidad mínima, entonces el sistema le asigna "Alta asegurada", y si la cantidad es un 20% de la cantidad mínima se considera un escenario crítico en el que el administrador debe realizar una solicitud de medicamentos a los proveedores.

### Caducidad
En este apartado se utiliza el concepto clave-valor también, se relaciona el número de días que faltan con respecto a la fecha de ejecución del proyecto para identificar si ya ha caducado (quedan 0 días), o si aun faltan unos cuantos días, meses o más de seis meses.
Se utilizan expresiones regulares para formatear las fechas del inventario que están en formato "**YYYY/MM/DD**" a un formato "**YYYY-MM-DD**" por requerimientos del proyecto:
```perl
  eval {
    if ($fecha_vencimiento =~ m|^(\d{4})-(\d{2})-(\d{2})$|) {
      # Comprobamos que el formato sea: YYYY-MM-DD
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%Y-%m-%d");
    } elsif ($fecha_vencimiento =~ m|^(\d{4})/(\d{2})/(\d{2})$|) {
      # Formato manual: YYYY/MM/DD
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%Y/%m/%d");
    } elsif ($fecha_vencimiento =~ m|^(\d{2})/(\d{2})/(\d{4})$|) {
      # Formateamos a: DD/MM/YYYY
      $fecha_venc = Time::Piece->strptime($fecha_vencimiento, "%d/%m/%Y");
    } else {
      return "Formato de fecha inválido";
    }
  };
```

## Ver el inventario
Si las comprobaciones anteriores fueron terminadas, el sistema utiliza la lista ciclada en un bucle "while", mientras existan nodos en `$actual` abrá información y podrá seguir mostrandola usando `printf`:
```perl
    printf("%-10s %-20s %-20s %-25s %-25s %-30s %-20s %-30s\n",
      $codigo, $nombre, $principio_activo, $cantidad_disponible,
      $cantidad_minima, $estado_cantidad, $fecha_vencimiento, $caducidad
    );
```

---
### Regresar al menú de administración
![<Regresar>](Administrador.md)
