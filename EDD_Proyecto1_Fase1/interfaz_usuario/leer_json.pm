#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;
package interfaz_usuario::leer_json;

sub cargar_usuario {
  my ($ruta) = @_;

  open my $fh, '<', $ruta
    or die "No se pudo abrir el archivo en $ruta \n";

  local $/;
  my $texto_en_json = <$fh>;
  close $fh;

  my $datos = decode_json($texto_en_json);
  return $datos;
}

sub validar_usuario {
  my ($nombre_usuario, $usuario_contrasena) = @_;

  my $datos = cargar_usuario('../interfaz_usuario/usuarios.json');

  return 0
    unless $nombre_usuario eq $datos->{usuario} && $usuario_contrasena eq $datos->{contrasena};

  return 1;
}

1;
