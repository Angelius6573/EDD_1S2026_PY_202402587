#!/usr/bin/perl
package usuario::solicitar_reabastecimiento;
use strict;
use warnings;

use interfaz_usuario::usuario;
use administrador::Inventario::leer_inventario_json;
use usuario::reabastecimiento::formulario_reabastecimiento;
use usuario::reabastecimiento::operar_lista_cde;

sub solicitud_medicamentos {
  my ($nombre_usuario, $codigo_depto) = @_;
  system("clear");
  print "Bienvenido $nombre_usuario al módulo para solicitar reabastecimiento de medicamentos.\n";
  print "Llene el siguiente formulario: \n";
  print "Código del medicamento: "; chomp(my $codigo = <STDIN>);

  administrador::Inventario::leer_inventario_json::identificar_codigo_reabastecimiento($codigo, $nombre_usuario, $codigo_depto);
  
  my ($cantidad, $prioridad, $razon) = usuario::reabastecimiento::formulario_reabastecimiento::formulario();

  usuario::reabastecimiento::operar_lista_cde::agregar($codigo, $cantidad, $prioridad, $razon, $codigo_depto);

  print "Datos guardados, a la espera de aprovación por administrador.\n";
  print "Volviendo al menú del usuario...\n";
  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($nombre_usuario, $codigo_depto);
}

1;
