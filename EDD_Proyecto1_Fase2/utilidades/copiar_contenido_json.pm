#!/usr/bin/perl
package utilidades::copiar_contenido_json;
use strict;
use warnings;

use utilidades::leer_json;

sub copiar {
  my ($contenido, $ruta, $sub_metodo, $lista) = @_;
  
  if (-e $ruta) {
    $contenido = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  }
  foreach my $element ( @$contenido) {
    $lista->$sub_metodo($element);
  }

  return $lista;
}

1;
