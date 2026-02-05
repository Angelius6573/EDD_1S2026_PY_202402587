#!/usr/bin/perl
package interfaz_usuario::admin;
use strict;
use warnings;
use feature qw(say switch);

use utilidades::limite_entrada;
use utilidades::leer_json;
use datos::Inventario::inventario;
use datos::Proveedores::proveedores;

#our $nombre_admin = 'admin';
#our $contrasenia_admin = '1234';

sub inicio_sesion_admin_exitoso {
  print "Bienvenido nuevamente administrador \n";
  print "¿Qué haremos hoy?";
  print "
  1. Registrar medicamento
  2. Carga masiva de medicamentos
  3. Gestionar proveedores
  4. Registrar engrega de proveedor
  5. Procesar solicitudes de reabastecimiento
  6. Visualizar inventario
  7. Consultar inventario 󰘍
  8. Gestionar usuarios 󰘍
  9. Cerrar sesión
  ";

  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 9);
  return seleccion($consulta);
}

sub seleccion {
  my ($opcion_seleccionada) = @_;

  given ($opcion_seleccionada) {
    when (1) {say datos::Inventario::inventario::registrar_medicamento()}
    when (2) {say datos::Inventario::inventario::registrar_medicamento_masivo()}
    when (3) {say datos::Proveedores::proveedores::gestionar_proveedor()}
    when (4) {say datos::Proveedores::proveedores::registrar_entrega()}
    when (9) {say print interfaz_usuario::inicio::consultar_usuario()}
  }
}

sub nuevo_usuario {
  my ($nombre, $contrasenia, $correo, $ticket) = @_;
}

sub validar_nueva_contrasena {
  my ($usuario_nombre, $usuario_correo) = @_;

  my $datos = utilidades::leer_json::parsear_json('interfaz_usuario/usuarios.json');

  foreach my $element ( @$datos ) {
    if ( $element->{usuario} eq $usuario_nombre && $element->{correo} eq $usuario_correo ) {
      return 1;
    }
  }

  return 0;
}

sub cambio_contrasena_exitoso {
  my ($nombre_usuario, $correo_usuario) = @_;
  my $ruta = 'interfaz_usuario/usuarios.json';
  my $datos = utilidades::leer_json::parsear_json($ruta);

  print "Ingrese una nueva contraseña: ";
    my $nueva_contrasena = <STDIN>;
    chomp $nueva_contrasena;

    my $confirmar_contrasena;
      do {
        print "Confirme su nueva contraseña por favor: ";
        $confirmar_contrasena = <STDIN>;
        chomp $confirmar_contrasena;
      } while ( $nueva_contrasena ne $confirmar_contrasena );


  foreach my $element ( @$datos ) {
    if ( $element->{usuario} eq $nombre_usuario && $element->{correo} eq $correo_usuario ) {
      $element->{contrasena} = $nueva_contrasena;
      utilidades::leer_json::guardar_json($ruta, $datos);
      return 1;
    }
  }
  print "Salvaguarda, error, el usuario no ha sido encontrado.";
  return 0;
}

1;

