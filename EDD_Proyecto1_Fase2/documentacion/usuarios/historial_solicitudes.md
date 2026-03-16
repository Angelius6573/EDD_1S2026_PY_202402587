# Historial de Solicitudes
Cuando el usuario llega a este apartado, el sistema recupera automáticamente el registro histórico de todas las solicitudes de reabastecimiento asociadas a su departamento, mostrando el estado actual de cada una con colores indicativos.

## Comprobación de Existencia
Antes de mostrar cualquier dato, el módulo `comprobaciones` verifica que exista información disponible para el departamento del usuario. Para ello construye la ruta del archivo JSON correspondiente y realiza dos validaciones:

| Condición | Resultado |
| - | - |
| El archivo JSON no existe | Se informa al usuario y se regresa al menú |
| El archivo existe pero está vacío | Se informa al usuario y se regresa al menú |
| El archivo contiene solicitudes | Se retornan los datos para su visualización |

```perl
my $ruta = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";
if ( !-e $ruta ) {
  print "Su departamento no ha procesado solicitudes.\n";
  utilidades::cerrar::cerrar();
  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
}
```

## Codificación por Color del Estado
Para facilitar la lectura del historial, el módulo `ver_codigo` aplica color al campo estado de cada solicitud usando `Term::ANSIColor`, asociando cada posible valor a un color distinto:

| Estado | Color |
| - | - |
| Pendiente | Amarillo |
| Aprobado | Verde |
| Desaprobado | Rojo |

```perl
sub ver_color {
  my ($estado) = @_;
  my %colores = (
    "Pendiente"   => 'yellow',
    "Aprobado"    => 'green',
    "Desaprobado" => 'red'
  );
  return exists $colores{$estado} ? colored($estado, $colores{$estado}) : $estado;
}
```

Si el estado no coincide con ninguna clave del hash, se retorna el valor original sin ningún formato aplicado.

## Visualización del Historial
Una vez confirmada la existencia de los datos y coloreados los estados, el módulo `ver_todas` itera sobre cada solicitud del array recuperado del JSON e imprime en consola la siguiente información:

| Campo | Descripción |
| - | - |
| Número de solicitud | Contador secuencial iniciando en 1 |
| Medicamento solicitado | Nombre del medicamento |
| Cantidad solicitada | Unidades requeridas |
| Estado | Estado actual con color aplicado |
| Fecha de solicitud | Fecha en que se generó la solicitud |

```perl
foreach my $dato ( @$reabastecimiento_depto ) {
  my $estado = usuario::historial::ver_codigo::ver_color($dato->{estado});
  print "Solicitud número $Solicitud\n";
  print " Medicamento solicitado: $dato->{nombre}\n";
  print " Cantidad solicitada: $dato->{cantidad}\n";
  print " Estado: $estado\n";
  print " Fecha de solicitud: $dato->{fecha_solicitud}\n\n";
  $Solicitud++;
}
```

Al finalizar la impresión de todas las solicitudes, se invoca `utilidades::cerrar::cerrar()` para pausar la ejecución y luego se regresa al menú principal del usuario.

---
### Regresar al menú de usuario
![<Regresar>](Usuarios.md)
