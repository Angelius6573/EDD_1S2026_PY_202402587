#!/usr/bin/perl
use strict;
use warnings;
package interfaz_usuario::inicio;

use interfaz_usuario::admin;
use interfaz_usuario::leer_json;

## Variables globales
my $usuario_admin = $interfaz_usuario::admin::nombre_admin;
my $contrasena_admin = $interfaz_usuario::admin::contrasenia_admin;

sub consultar_usuario {
  print "Bienvenido al servicio de gestión de datos EDD MEDTRACK \n";
  print "Diganos, ¿Qué desea hacer?";
  print "
  1. Iniciar sesión
  2. Crear usuario
  3. Recuperar contraseña
  4. Salir \n";
  print "Ingrese el número de la acción que desea: ";
  my $consulta = <STDIN>;

  while ( $consulta !~ /^[1-4]$/ ) {
    print "Ingrese una opciór válida. (1~4): ";
    $consulta = <STDIN>;

    last unless defined $consulta;
    chomp $consulta;
  } 
  comprobar_entrada($consulta);
}

sub comprobar_entrada {
  my ($consulta) = @_;

  if ( $consulta == 1 ) {
    print "Inicio de Sesión \n";
    print "Usuario: ";
      my $usuario = <STDIN>;
      chomp $usuario;
      print "Contraseña: ";
      my $contrasena = <STDIN>;
      chomp $contrasena;

    if ( $usuario eq $usuario_admin && $contrasena eq $contrasena_admin ) {
      print interfaz_usuario::admin::inicio_sesion_admin_exitoso();
    } else {
      if ( interfaz_usuario::leer_json::validar_usuario($usuario, $contrasena) ) {
        print "Acceso concedido \n";
      } else {
        print "Usuario no identificado \n";
      }
    }
  } elsif ( $consulta == 2 ) {
    print "2";
  } elsif ( $consulta == 3 ) {
    print "3";
  } else {
    print "Saliendo...\n";
    exit 0;
  }

}

1;
