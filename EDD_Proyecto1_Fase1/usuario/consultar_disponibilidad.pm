#!/usr/bin/perl
package usuario::consultar_disponibilidad;
use strict;
use warnings;

use interfaz_usuario::usuario;
use administrador::Inventario::leer_inventario_json;

sub consulta_medicamento {
  my ($nombre_usuario, $codigo_depto) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';
  my $inventario = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  
  system("clear");
  print "Bienvenido $nombre_usuario al módulo de consulta de disponibilidad de medicamentos.\n";
  print "Por favor ingrese el código del médicamento que desea consultar.\n";
  print "Código: "; chomp(my $codigo = <STDIN>); 
      administrador::Inventario::leer_inventario_json::identificar_codigo_nombre_disponible($codigo);

  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($nombre_usuario, $codigo_depto);
}

1;
