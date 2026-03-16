#!/usr/bin/perl
package utilidades::validar_usuarios;
use strict;
use warnings;

use utilidades::leer_json;
use interfaz_usuario::admin;
use interfaz_usuario::inicio;
use interfaz_usuario::usuario;

sub validar_usuario {
  my ($usuario_nombre, $contrasenia, $codigo_depto) = @_;
  my $ruta_user = 'interfaz_usuario/usuarios.json';
  my $usuarios = utilidades::leer_json::parsear_json($ruta_user);

  foreach my $usuario (@$usuarios) {
    if ( $usuario->{usuario} eq $usuario_nombre &&
         $usuario->{contrasena} eq $contrasenia &&
         $usuario->{codigo_departamental} eq $codigo_depto ) {
      if ( $usuario->{tipo} eq "admin" ) {
        print "Acceso concedido.\n";
        return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
      }
      if ( $usuario->{tipo} eq "usuario" ) {
        print "Acceso concedido.\n";
        return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso(
          $usuario->{usuario},
          $usuario->{codigo_departamental}
        ); 
      }
    }
  }
  return 0;
}

1;
