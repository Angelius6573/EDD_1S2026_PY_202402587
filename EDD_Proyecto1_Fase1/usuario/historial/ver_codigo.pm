#!/usr/bin/perl
package usuario::historial::ver_codigo;
use strict;
use warnings;

use interfaz_usuario::usuario;
use usuario::historial::comprobaciones;

sub ver_codigo {
  my ($usuario, $codigo_depto) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $bandera = 0;

  my $reabastecimiento_depto = usuario::historial::comprobaciones::comprobar_existencia($usuario, $codigo_depto);

  print "Código del medicamento: "; chomp(my $codigo = <STDIN>);

  foreach my $dato ( @$reabastecimiento_depto ) {
    $lista->insertar_final($dato);
  }

  my $datos = $lista->almacenar_array_simple();

  foreach my $solicitud (@$datos) {
    $bandera = 1;
    print "Waos si existen los datos";
  }
  if ( !$bandera ) {
    print "Datos no encontrados";
  }

  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
}

1;
