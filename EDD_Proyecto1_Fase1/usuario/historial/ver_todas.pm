#!/usr/bin/perl
package usuario::historial::ver_todas;
use strict;
use warnings;

use interfaz_usuario::usuario;
use usuario::historial::comprobaciones;
use usuario::historial::ver_codigo;
use utilidades::cerrar;

sub ver_todas {
  my ($usuario, $codigo_depto, $reabastecimiento_depto) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $Solicitud = 1;

  foreach my $dato ( @$reabastecimiento_depto ) {
    my $estado = $dato->{estado};
    $estado = usuario::historial::ver_codigo::ver_color($estado);

    my $nombre = $dato->{nombre};
    my $cantidad = $dato->{cantidad};
    my $fecha_solicitud = $dato->{fecha_solicitud};

    print "Solicitud número $Solicitud\n";
      print " Medicamento solicitado: $nombre\n";
      print " Cantidad solicitada: $cantidad\n";
      print " Estado: $estado\n";
      print " Fecha de solicitud: $fecha_solicitud\n\n";

    $Solicitud++;
  }

  utilidades::cerrar::cerrar();
  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
}

1;
