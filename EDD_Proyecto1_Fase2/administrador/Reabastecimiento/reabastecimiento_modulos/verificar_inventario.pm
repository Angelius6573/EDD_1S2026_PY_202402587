#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::verificar_inventario;
use strict;
use warnings;

use utilidades::leer_json;

sub validar_cantidad_disponible {
  my ($codigo, $cantidad_solicitada) = @_;
  my $ruta = "administrador/Inventario/inventario.json";

  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento ( @$datos ) {
    if ( $medicamento->{codigo} eq $codigo ) {
      return $medicamento->{cantidad} >= $cantidad_solicitada ? 1 : 0;
    }
  }
  return 0;
}

sub obtener_cantidad { 
# Se obtiene la cantidad solicitada y la existente, así como todos los datos del medicamento en función de su código
  my ($codigo) = @_;
  my $ruta = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";
  
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  my $cantidad_existente;

  foreach my $dato ( @$datos ) {
    if ( $dato->{codigo} eq $codigo ) {
      $cantidad_existente = $dato->{cantidad};
      return $cantidad_existente;
    }
  }
  return 0;
}

sub modificar_inventario { 
# Se guarda el archivo 'inventario.json' con la cantidad retirada

}

sub modificar_inventario_departamental { 
# Se guarda el archivo del inventario departamental con los datos originales y la cnatidad pedida

}

1;
