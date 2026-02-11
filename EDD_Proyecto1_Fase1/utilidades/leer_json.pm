#!/usr/bin/perl
package utilidades::leer_json;
use strict;
use warnings;
use JSON::PP;

sub parsear_json {
  my ($ruta) = @_;

  open my $fh, '<', $ruta
    or die "No se pudo abrir el archivo en $ruta \n";

  local $/;
  my $texto_en_json = <$fh>;
  close $fh;

  my $datos = decode_json($texto_en_json);
  return $datos;
}

sub parsear_json_posiblemente_vacio {
  my ($ruta) = @_;

  return [] unless -e $ruta; ## Hace una llamada al sistema para comprobar si el archivo existe.
  return [] if -z $ruta; ## Comprueba el tamaño del json solo consultando sus metadatos, si es 0 devuelve []

  open my $fh, '<', $ruta or return [];
  local $/;
  my $texto_en_json = <$fh>;
  close $fh;

  return [] unless defined $texto_en_json && $texto_en_json =~ /\S/;

  my $datos;
  eval {
    $datos = decode_json($texto_en_json);
  };

  if ( $@ || !defined $datos || ref $datos ne 'ARRAY' ) {
    return [];
  } # Doble comprobación, no debería permitir pasar un JSON vacío

  return $datos;
}

sub guardar_json {
  my ($ruta, $datos) = @_;

  my $aspecto = JSON::PP->new
                        ->utf8
                        ->pretty
                        ->canonical(1);

  open my $fh, '>', $ruta
    or die "No se pudo abrir el archvio en $ruta \n";

  print $fh $aspecto->encode($datos);
  close $fh;

  return 1;
}

1;
