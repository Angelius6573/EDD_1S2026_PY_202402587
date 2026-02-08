#!/usr/bin/perl
package utilidades::validar_usuarios;
use strict;
use warnings;

use utilidades::leer_json;
use interfaz_usuario::admin;
use interfaz_usuario::inicio;
use interfaz_usuario::usuario;

sub ver_nombre_usuario {
  my $datos = utilidades::leer_json::parsear_json('interfaz_usuario/usuarios.json');
  my $nombre_usuario;
  foreach my $element ( @$datos ) {
    $nombre_usuario = $element->{usuario};
  }
  return $nombre_usuario;
}

sub validar_usuario {
  my ($nombre_usuario, $usuario_contrasena) = @_;

  my $usuarios = utilidades::leer_json::parsear_json('interfaz_usuario/usuarios.json');

  foreach my $usuario ( @$usuarios ) {
    if ( $usuario->{usuario} eq $nombre_usuario && $usuario->{contrasena} eq $usuario_contrasena && $usuario->{tipo} eq "admin" ) {
      return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
    }
    if ( $usuario->{usuario} eq $nombre_usuario && $usuario->{contrasena} eq $usuario_contrasena && $usuario->{tipo} eq "usuario" ) {
      print "Acceso concedido \n";
      return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso();
    }
  }
  return 0;
}

1;
