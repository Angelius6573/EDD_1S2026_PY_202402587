#!/usr/bin/perl
package datos::Proveedores::proveedores;
use strict;
use warnings;

use utilidades::leer_json;
use utilidades::copiar_contenido_json;
use utilidades::validar_numeros;
use interfaz_usuario::admin;
use gestion_datos::lista_circular_simple;
use gestion_datos::lista_simple;

my $lista_circular = gestion_datos::lista_circular_simple->nuevo();

sub gestionar_proveedor {
  print "Bienvenido administrador al registro de proveedores\n";
  print "Por favor llene el siguiente formulario: \n";
  leer_json_proveedores();
  formulario_nuevo_proveedor();
  print "Funciono \n";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub registrar_entrega {
  ## Primero verificar si el archivo "proveedores.json" esta vacío, sino, no opera hasta que se actualice
  ## en "gestionar_proveedor"
  my $ruta = 'datos/Proveedores/proveedores.json';
  my $verificar_ruta = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if ( !@$verificar_ruta ) {
    print "No hay proveedores registrados, por favor, use el registro de proveedores previamente.\n";
    gestionar_proveedor();
  } else {
    print "why?\n";
  }
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub formulario_nuevo_proveedor {
  print "Ingrese el número del NIT: "; chomp(my $nit = <STDIN>);
  print "Ingrese el nombre de la empresa: "; chomp(my $nombre_empresa = <STDIN>);
  print "Ingrese el contacto principal: "; chomp(my $contacto_principal = <STDIN>);
  print "Ingrese el número de teléfono: "; chomp(my $telefono_num = <STDIN>);
    while ( !utilidades::validar_numeros::validar_int_positivo($telefono_num) || length($telefono_num) != 8 ) {
      print "Ingrese un número de teléfono válido (12345678): "; chomp($telefono_num = <STDIN>);
    }
  print "Ingrese la dirección: "; chomp(my $direccion = <STDIN>);

  ## METER LO ANTERIOR A LA LISTA CIRCULAR
  # Por eso se valoriza si es interesante mantener utilidades::copiar_contenido_json
  # No resulto ser buena idea para este caso, no se formateaba correctamente el contenido en el JSON

  $lista_circular->insertar_nuevo({
    NIT => $nit,
    Empresa => $nombre_empresa,
    Contacto => $contacto_principal,
    Telefono => $telefono_num,
    Direccion => $direccion
  });

  my $proveedor_instancia = $lista_circular->almacenar_array_simple(); # No hace falta poner la ruta completa aparentemente
  utilidades::leer_json::guardar_json('datos/Proveedores/proveedores.json', $proveedor_instancia);
}

sub leer_json_proveedores {
  my $ruta = 'datos/Proveedores/proveedores.json';
  my $proveedores = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  $lista_circular->limpiar();

  foreach my $proveedor ( @$proveedores ) {
    $lista_circular->insertar_nuevo($proveedor);
  }
}

1;
