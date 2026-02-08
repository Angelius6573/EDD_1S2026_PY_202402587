#!/usr/bin/perl
package interfaz_usuario::inicio;
use strict;
use warnings;

use utilidades::leer_json;
use utilidades::limite_entrada;
use interfaz_usuario::admin;
use interfaz_usuario::usuario;
use utilidades::validar_usuarios;

## Variables globales
# my $usuario_admin = $interfaz_usuario::admin::nombre_admin;
# my $contrasena_admin = $interfaz_usuario::admin::contrasenia_admin;
my $tipo = "admin";

sub consultar_usuario {
  print "Bienvenido al servicio de gestión de datos EDD MEDTRACK \n";
  print "Diganos, ¿Qué desea hacer?";
  print "
  1. Iniciar sesión
  2. Crear usuario
  3. Recuperar contraseña
  4. Salir \n";
  #print "Ingrese el número de la acción que desea: ";
  #my $consulta = <STDIN>;
  
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 4);

  #while ( $consulta !~ /^[1-4]$/ ) {
  #print "Ingrese una opciór válida. (1~4): ";
  # $consulta = <STDIN>;

  # last unless defined $consulta;
  # chomp $consulta;
  #} 
  comprobar_entrada($consulta);
}

sub comprobar_entrada {
  my ($consulta) = @_;

  if ( $consulta == 1 ) {
    print "Inicio de Sesión\n";
    print "Usuario: "; chomp(my $usuario = <STDIN>);
    print "Contraseña: "; chomp(my $contrasena = <STDIN>);
    utilidades::validar_usuarios::validar_usuario($usuario, $contrasena);
    print "Usuario no identificado. Volviendo a inicio...\n";
    return consultar_usuario();
  } elsif ( $consulta == 2 ) {
    print "Servicio de creación de cuentas de usuario \n";
    print "Nombre de usuario: ";
      my $nombre = <STDIN>;
      chomp $nombre;
    print "Correo: ";
      my $correo = <STDIN>;
      chomp $correo;
    print "Contraseña: ";
      my $contrasena = <STDIN>;
      chomp $contrasena;
      my $confirmar_contrasena;
      do {
        print "Confirme su contraseña por favor: ";
        $confirmar_contrasena = <STDIN>;
        chomp $confirmar_contrasena;
      } while ( $contrasena ne $confirmar_contrasena );
    print "Mensaje para el administrador: ";
      my $mensaje = <STDIN>;
      chomp $mensaje;

    interfaz_usuario::admin::nuevo_usuario($nombre, $correo, $contrasena, $mensaje);
    print "Su solicitud ha sido procesada, un administrador la confirmará pronto, gracias.\n";
    return consultar_usuario();

  } elsif ( $consulta == 3 ) {
    print "Servicio de recuperación de contraseña \n";
    my $intentos = 0;

    if ( $intentos < 3 ) {
      do {
        print "Ingrese su nombre: ";
          my $nombre = <STDIN>;
          chomp $nombre;
        print "Ingrese su correo: ";
          my $correo = <STDIN>;
          chomp $correo;

        if ( interfaz_usuario::admin::validar_nueva_contrasena($nombre, $correo) ) {
          interfaz_usuario::admin::cambio_contrasena_exitoso($nombre, $correo);
          print "Cambio de contraseña exitoso. Regresando a inicio...\n";
          return consultar_usuario();
        } else {
          print "Usuario o correo no encontrados, vuelva a intentarlo.\n";
          $intentos += 1;
        }
      } while ( $intentos < 3 );
      if ( $intentos >= 3 ) {
        print "Informando inconvenientes al administrador.\n";
        print "Cerrando sesión...\n";
        exit 0;
      }
      return consultar_usuario();
    }
  } else {
    print "Saliendo...\n";
    exit 0;
  }

}

1;
