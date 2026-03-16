#!/usr/bin/perl
package administrador::Ver_Inventario::modulos::mostrar_info;
use strict;
use warnings;

use administrador::Ver_Inventario::modulos::verificar_cantidad;
use administrador::Ver_Inventario::modulos::verificar_caducidad;

sub mostrar_info {
  my ($actual) = @_;

  while ($actual) {
    my $medicamento = $actual->{datos};

    ## Variables
    my $codigo = $medicamento->{codigo};
    my $nombre = $medicamento->{nombre};
    my $principio_activo = $medicamento->{principio_activo};
    my $cantidad_disponible = $medicamento->{cantidad};
    my $fecha_vencimiento = $medicamento->{fecha_vencimiento};
    my $cantidad_minima = $medicamento->{nivel_minimo};

    ## Verificar cantidades
    my $estado_cantidad = administrador::Ver_Inventario::modulos::verificar_cantidad::verificar_cantidad($cantidad_minima, $cantidad_disponible);
    ## Verificar caducidad
    my $caducidad = administrador::Ver_Inventario::modulos::verificar_caducidad::verificar_caducidad($fecha_vencimiento);
 
    printf("%-10s %-20s %-20s %-25s %-25s %-30s %-20s %-30s\n",
      $codigo, $nombre, $principio_activo, $cantidad_disponible, $cantidad_minima, $estado_cantidad, $fecha_vencimiento, $caducidad
    );
    $actual = $actual->{siguiente};
  }
}

  1;
