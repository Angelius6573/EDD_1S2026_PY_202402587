#!/usr/bin/perl
package administrador::Gestion_Usuarios::nuevo_usuario;
use warnings;
use strict;
use feature qw(say switch);

use utilidades::limite_entrada;
use interfaz_usuario::admin;

sub nuevo_usuario {
  system("clear");
  my $ruta = "interfaz_usuario/nuevo_usuario.json";
  my $pendientes = administrador::Inventario::buscar_medicamento_codigo::contar_pendientes_usuarios($ruta);

  print "Bienvenido administrador al modulo de gestión para nuevos usuarios\n";
  print "Hay un total de $pendientes solicitudes de nuevo usuario pendientes.\n";
  if ( $pendientes > 0 ) {
    my $datos = administrador::Inventario::buscar_medicamento_codigo::ver_primero($ruta);

    my $nombre = $datos->{nombre};
    my $correo = $datos->{correo};
    my $contrasenia = $datos->{contrasenia};
    my $depto = $datos->{codigo_departamental};

    my $consulta = ver($nombre, $correo, $depto);
    consulta($consulta, $nombre, $correo, $depto, $contrasenia);
  } else {
    print "\nNo hay solicitudes pendientes\n";
    print "Regresando al menú del administrador\n\n";
    utilidades::cerrar::cerrar();
    interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  }
}

sub usuario_aprobado {
  my ($nombre, $correo, $depto, $contrasena) = @_;

  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();

  my $copia_usuarios = [];
  my $ruta = "interfaz_usuario/usuarios.json";
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_usuarios, $ruta, $metodo, $lista);

  $lista->$metodo({
    nombre => $nombre,
    correo => $correo,
    contrasena => $contrasena,
    codigo_departamental => $depto,
    tipo => "usuario"
  });

  my $datos = $lista->almacenar_array_simple();
  utilidades::leer_json::guardar_json($ruta, $datos);

  print "Lista de usuarios actualizada\n";
  print "Volviendo al menú de administrador\n\n";

  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub usuario_desaprobado {
  my ($nombre, $correo, $depto, $contrasenia) = @_;
  my $ruta = "interfaz_usuario/nuevo_usuario.json";
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();
  foreach my $instancia ( @$datos ) {
    $lista->insertar_final($instancia);
  }

  my %parametros = (
    nombre => $nombre,
    correo => $correo,
    contrasenia => $contrasenia,
    codigo_departamental => $depto
  );

  if ($lista->eliminar_multi_parametro(\%parametros)) {
    my $datos_actualizados = $lista->almacenar_array_simple();
    utilidades::leer_json::guardar_json($ruta, $datos_actualizados);
    print "\nSolicitud procesada correctamente, retirando de la lista...\n\n";
  } else {
    print "\nNo se encontró solicitud con los criterios especificados.\n\n";
  }

  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub ver {
  my ($nombre, $correo, $depto) = @_;

  my $mensaje = "¿Desea ver la consulta? (Y/N): ";
  my $consulta = utilidades::limite_entrada::comprobacion_y_n($mensaje);

  if ( $consulta eq "Y" ) {
    print " Nombre: $nombre\n";
    print " Correo: $correo\n";
    print " Código Departamental: $depto\n";
      $consulta = utilidades::limite_entrada::comprobacion_y_n("¿Desea aprobar al nuevo usuario? (Y/N): ")
  } else {
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  }
}

sub consulta {
  my ($consulta, $nombre, $correo, $depto, $contrasenia) = @_;
  given ($consulta) {
    when ("Y") {say usuario_aprobado($nombre, $correo, $depto, $contrasenia)}
    when ("N") {say usuario_desaprobado($nombre, $correo, $depto, $contrasenia)}
  }
}

1;
