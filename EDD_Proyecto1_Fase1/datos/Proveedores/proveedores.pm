#!/usr/bin/perl
package datos::Proveedores::proveedores;
use strict;
use warnings;

use utilidades::leer_json;
use interfaz_usuario::admin;
use gestion_datos::lista_circular_simple;
use gestion_datos::lista_simple;
use datos::Proveedores::formulario_proveedores;

## Variables globales
my $lista_circular = gestion_datos::lista_circular_simple->nuevo();
my $lista_simple = gestion_datos::lista_simple->nuevo();
my $regresar_menu_admin = interfaz_usuario::admin::inicio_sesion_admin_exitoso();

sub gestionar_proveedor {
  print "Bienvenido administrador al registro de proveedores\n";
  print "Por favor llene el siguiente formulario: \n";
  datos::Proveedores::formulario_proveedores::leer_json_proveedores($lista_circular);
  datos::Proveedores::formulario_proveedores::formulario_nuevo_proveedor($lista_circular);
  print "Proveedor registrado correctamente.\n";
  return $regresar_menu_admin; 
}

sub registrar_entrega {
  ## Primero verificar si el archivo "proveedores.json" esta vacío, sino, no opera hasta que se actualice en "gestionar_proveedor"
  my $ruta = 'datos/Proveedores/proveedores.json';
  my $verificar_ruta = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if ( !@$verificar_ruta ) {
    print "No hay proveedores registrados, por favor, use el registro de proveedores previamente.\n";
    gestionar_proveedor();
  } else {
    print "why?\n";
  }
  return $regresar_menu_admin;
}


1;
