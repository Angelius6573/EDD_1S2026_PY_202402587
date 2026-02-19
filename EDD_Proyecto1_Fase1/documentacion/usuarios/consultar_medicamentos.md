# Consultar Disponibilidad de Medicamentos
El usuario al llegar a este módulo deberá ingresar el código del medicamento que desea consultar, el sistema hará la búsqueda del código en el archivo ["inventario.json"](../../administrador/Inventario/inventario.json) usando la subrutina ["parsear_json_posiblemente_vacio"](../../utilidades/leer_json.pm) del lector de archivos JSON para identificar si la base de datos esta vacía y en caso contrario almacenar toda la información en memoria RAM.

Si la información es localizada se utilizará un "foreach" para segmentar e imprimir la información almacenada de la siguiente manera:
```parl
sub identificar_codigo_nombre_disponible {
  my ($validar) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';

  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento ( @$datos ) {
    if ( $medicamento->{codigo} eq $validar || $medicamento->{nombre} eq $validar ) {
      print " Nombre del medicamento: $medicamento->{nombre}\n";
      print " Cantidad disponible: $medicamento->{cantidad}\n";
      print " Tiempo de reabastecimiento: $medicamento->{tiempo_reabastecer}\n\n";
      return 1;
    }
  }
  print "La información solicitada no existe. Regresando al menú del usuario...\n\n";
  return 0;
}
```

---
### Regresar al menú de usuario
![<Regresar>](Usuarios.md)
