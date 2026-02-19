#!/usr/bin/perl
package administrador::Consultas::modulos::llenar_matriz;
use strict;
use warnings;

sub llenar {
  my ($matrix, $ruta_inv) = @_;
  my $inventario = utilidades::leer_json::parsear_json($ruta_inv);

  my $filas = $matrix->{nombres_filas};
  my $columnas = $matrix->{nombres_columnas};

  foreach my $medicamento ( @$inventario ) {
    my $nombre = $medicamento->{nombre};
    my $laboratorio = $medicamento->{laboratorio};
    my $cantidad = $medicamento->{cantidad};
    my $precio = $medicamento->{precio_unitario};
    my $cantidad_minima = $medicamento->{nivel_minimo};

    my $idx_f = buscar_idx($nombre, $filas);
    my $idx_c = buscar_idx($laboratorio, $columnas);

    if ( defined $idx_f && defined $idx_c ) {
      $matrix->insertar($idx_f, $idx_c, $precio, $cantidad, $cantidad_minima);
    } else {
      warn "No se pudo insertar datos en la matriz dispersa...\n";
    }
  }
  return $matrix;
}

sub buscar_idx {
  my ($parametro, $fc) = @_;

  for my $idx (0 .. $#{$fc}) {
    return $idx if $fc->[$idx] eq $parametro;
  }

  return undef;
}

1;
