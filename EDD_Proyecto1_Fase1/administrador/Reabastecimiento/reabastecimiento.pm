#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento;
use strict;
use warnings;
use feature qw(say switch);

use interfaz_usuario::admin;
use administrador::Inventario::buscar_medicamento_codigo;
use gestion_datos::lista_circular_doblemente_enlazada;

sub procesar_solicitud {
  system("clear");
  my $ruta = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";
  my $datos = administrador::Inventario::buscar_medicamento_codigo::ver_primero($ruta); ## 1, 2 y 3

  if ( !defined $datos ) {
    print "Los datos no son válidos.\n";
    return verificacion();
  }

  my $codigo = $datos->{codigo};

  my $prioridad = $datos->{prioridad};
  my $codigo_depto = $datos->{codigo_departamental};
  my $nombre_med = $datos->{nombre};
  my $cantidad = $datos->{cantidad};
  my $fecha_solicitud = $datos->{fecha_solicitud};
  
  ## 4. Imprimir los datos
  if ( defined $datos ) {
    print "Solicitud de nivel: $prioridad \n";
    print "Departamento solicitante: $codigo_depto \n";
    print "Medicamento requerido: $nombre_med \n";
    print "Cantidad requerida: $cantidad \n";
    print "Fecha de solicitud: $fecha_solicitud \n\n";
  }

  ## 5. Solicitar confirmación
  my $confirmacion = utilidades::limite_entrada::comprobacion_y_n();
  print "$confirmacion";

  given ($confirmacion) {
    when ("Y") {say aprobado($codigo, $codigo_depto)}
    when ("N") {say desaprobado($codigo_depto)}
  }
}

sub verificacion {
  system("clear");
  print "Bienvenido administrador al módulo de aceptación de solicitudes de reabastecimiento\n";
  while ( 1 ) {
    print "¿Desea procesar la primera solicitud? (Y/N): "; chomp(my $consulta = <STDIN>);

    return procesar_solicitud() if $consulta eq "Y";
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso() if $consulta eq "N";
    print "Inválido, ingrese Y ó N\n";
  }
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub aprobado {
  my ($codigo, $codigo_depto) = @_;
  my $lista_depto = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $ruta_admin = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";
  my $ruta_inv = "administrador/Inventario/inventario.json";

  my $stock = administrador::Inventario::buscar_medicamento_codigo::en_general($ruta_inv);

  cambiar_estado($codigo_depto, "Aprobado");

  return verificacion();
}

sub desaprobado {
  my ($codigo_depto) = @_;
  cambiar_estado($codigo_depto, "Desaprobado");
  return verificacion();
}

sub cambiar_estado {
  my ($codigo_depto, $estado) = @_;

  my $lista_depto = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $ruta_depto = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";

  $lista_depto = administrador::Inventario::buscar_medicamento_codigo::en_general_lista($ruta_depto, $lista_depto, "insertar_final");

  if ( $lista_depto->modificar_general("codigo_departamental", $codigo_depto, "estado", $estado) ) {
    my $datos_depto_nuevos = $lista_depto->almacenar_array_simple();
    utilidades::leer_json::guardar_json($ruta_depto, $datos_depto_nuevos);
    return 1;
  } else {
    print "Datos no encontrados...\n";
    return verificacion();
  }
}

sub eliminar_nodo {
  my ($codigo, $codigo_depto) = @_;
}

1;
