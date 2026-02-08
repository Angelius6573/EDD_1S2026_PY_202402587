#!/usr/bin/perl
package administrador::Proveedores::proveedores;
use strict;
use warnings;

use utilidades::leer_json;
use interfaz_usuario::admin;
use gestion_datos::lista_circular_simple;
use gestion_datos::lista_simple;
use administrador::Proveedores::formulario_proveedores;
use administrador::Proveedores::formulario_entrega;

## Variables globales
my $lista_circular = gestion_datos::lista_circular_simple->nuevo();
my $lista_simple = gestion_datos::lista_simple->nuevo();

sub gestionar_proveedor {
  print "Bienvenido administrador al registro de proveedores\n";
  print "Por favor llene el siguiente formulario: \n";
  administrador::Proveedores::formulario_proveedores::leer_json_proveedores($lista_circular);
  administrador::Proveedores::formulario_proveedores::formulario_nuevo_proveedor($lista_circular);
  print "Proveedor registrado correctamente.\n";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub registrar_entrega {
  ## Primero verificar si el archivo "proveedores.json" esta vacío, sino, no opera hasta que se actualice en "gestionar_proveedor"
  my $ruta = 'administrador/Proveedores/proveedores.json';
  my $verificar_ruta = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if ( !@$verificar_ruta ) {
    print "No hay proveedores registrados, por favor, use el registro de proveedores previamente.\n";
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  } else {
    print "Bienvenido administrador al área de registro de entregas.\n";
    print "Por favor, ingrese el NIT del proveedor que va a gestionar: "; chomp(my $nit_comprobar = <STDIN>);
    
    administrador::Proveedores::formulario_proveedores::leer_json_proveedores($lista_circular); ## Leer el archivo proveedores.json
    my $proveedor = administrador::Proveedores::formulario_entrega::buscar_proveedor_por_nit($lista_circular, $nit_comprobar);

    if ( $proveedor ) {
      print "NIT válidado correctamente, por favor, llene el siguiente formulario: \n";
      administrador::Proveedores::formulario_entrega::formulario_nueva_entrega($proveedor, $lista_circular); 
      ## Solicita el formulario y actualiza el archivo JSON con las entregas validadas.

      my $json_proveedores_actualizado = $lista_circular->almacenar_array_simple();
      utilidades::leer_json::guardar_json($ruta, $json_proveedores_actualizado);

      while ( 1 ) {
        print "Datos guardados, ¿Desea registrar otra entrega? (Y/N): ";
        chomp(my $consulta = <STDIN>);

        return registrar_entrega() if $consulta eq "Y";
        return interfaz_usuario::admin::inicio_sesion_admin_exitoso() if $consulta eq "N";
        print "Inválido, ingrese Y ó N\n";
      }
    } else {
      print "El NIT que ingreso no existe.\n";
    }
  }
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
