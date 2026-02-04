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

  my $datos = parsear_json($ruta);
  return [] unless defined $datos && ref $datos eq 'ARRAY'; ## Una mera formalidad para comprobar que los datos realmente existen, sino, se regenera el json
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

sub ver_nombre_usuario {
  my $datos = parsear_json('interfaz_usuario/usuarios.json');
  my $nombre_usuario;
  foreach my $element ( @$datos ) {
    $nombre_usuario = $element->{usuario};
  }

  return $nombre_usuario;
}

sub validar_usuario_normal {
  my ($nombre_usuario, $usuario_contrasena) = @_;

  my $datos = parsear_json('interfaz_usuario/usuarios.json');

  foreach my $element ( @$datos ) {
    if ( $element->{usuario} eq $nombre_usuario && $element->{contrasena} eq $usuario_contrasena ) {
      return 1;
    }
  }

  return 0;
}

sub validar_usuario_admin {
  my ($nombre_usuario, $usuario_contrasena, $tipo_usuario) = @_;

  my $datos = parsear_json('interfaz_usuario/usuarios.json');

  foreach my $element ( @$datos ) {
    if ( $element->{usuario} eq $nombre_usuario && $element->{contrasena} eq $usuario_contrasena && $element->{tipo} eq $tipo_usuario ) {
      return 1;
    }
  }

  return 0;
}

1;
