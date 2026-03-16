#!/usr/bin/perl
package usuario::historial::comprobaciones;
use strict;
use warnings;

use interfaz_usuario::usuario;
use gestion_datos::lista_circular_doblemente_enlazada;
use utilidades::leer_json;
use utilidades::cerrar;

sub comprobar_existencia {
  my ($usuario, $codigo_depto) = @_;
  my $ruta = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";

  if ( !-e $ruta ) {
    print "Su departamento no ha procesado solicitudes.\n";
    utilidades::cerrar::cerrar();
    return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
  }

  my $reabastecimiento_depto = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if ( ref($reabastecimiento_depto) eq 'ARRAY' && @$reabastecimiento_depto == 0 ) {
    print "Su departamento no ha procesado solicitudes.\n";
    utilidades::cerrar::cerrar();
    return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
  }
  return $reabastecimiento_depto;
}

1;
