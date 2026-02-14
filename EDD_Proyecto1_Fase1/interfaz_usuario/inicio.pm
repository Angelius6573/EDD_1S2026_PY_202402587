#!/usr/bin/perl
package interfaz_usuario::inicio;
use strict;
use warnings;
use feature qw(say switch);

use interfaz_usuario::admin;

use utilidades::leer_json;
use utilidades::limite_entrada;
use utilidades::validar_usuarios;
use administrador::Gestion_Usuarios::cambio_contrasena;
use administrador::Gestion_Usuarios::nuevo_usuario;

sub consultar_usuario {
  print "Bienvenido al servicio de gestión de datos EDD MEDTRACK \n";
  print "Diganos, ¿Qué desea hacer?";
  print "
  1. Iniciar sesión
  2. Crear usuario
  3. Recuperar contraseña
  4. Salir 
  5. Admin \n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 5);
  system("clear");
  comprobar_entrada($consulta);
}

sub comprobar_entrada {
  my ($consulta) = @_;

  given ($consulta) {
    when (1) {say inicio_sesion()}
    when (2) {say crear_usuario()}
    when (3) {say recuperar_contrasenia()}
    when (4) {say exit 0}
    when (5) {say interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

sub inicio_sesion {
  print "Inicio de Sesión\n";
    print "Usuario: "; chomp(my $usuario = <STDIN>);
    print "Contraseña: "; chomp(my $contrasena = <STDIN>);
    print "Código Departamental: "; chomp(my $codigo_departamental = <STDIN>);
  utilidades::validar_usuarios::validar_usuario($usuario, $contrasena, $codigo_departamental);
    print "Usuario no identificado. Volviendo a inicio...\n";
  consultar_usuario();
}

sub crear_usuario {
  print "Servicio de creación de cuentas de usuario \n";
    print "Nombre de usuario: "; chomp(my $nombre = <STDIN>);
    print "Correo: "; chomp(my $correo = <STDIN>);
    print "Nueva Contraseña: "; chomp(my $contrasena = <STDIN>);
    my $confirmar_contrasena;
    do {
      print "Confirme su contraseña por favor: "; chomp($confirmar_contrasena = <STDIN>);
    } while ( $contrasena ne $confirmar_contrasena );
    print "Mensaje para el administrador: "; chomp(my $mensaje = <STDIN>);
  administrador::Gestion_Usuarios::nuevo_usuario::nuevo_usuario($nombre, $correo, $contrasena, $mensaje);
  print "Su solicitud ha sido procesada, un administrador la confirmará pronto, gracias.\n";
  consultar_usuario();
}

sub recuperar_contrasenia {
  print "Bienvenido al servicio de recuperación de contraseñas\n";
  print "Por favor, llene el siguiente formulario: \n";
    print "Nombre de usuario: "; chomp(my $nombre = <STDIN>);
    print "Correo asociado: "; chomp(my $correo = <STDIN>);
  if ( administrador::Gestion_Usuarios::cambio_contrasena::validar_nueva_contrasena($nombre, $correo) ) {
    administrador::Gestion_Usuarios::cambio_contrasena::cambio_contrasena_exitoso($nombre, $correo);
    print "Cambio de contraseña exitoso. Regresando a inicio...\n";
    consultar_usuario();
  } else {
    print "Datos incorrectos, volviendo a inicio...\n";
    consultar_usuario();
  }
}

1;
