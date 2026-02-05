#!/usr/bin/perl
package datos::Proveedores::formulario_proveedores;
use strict;
use warnings;

use utilidades::validar_numeros;
use utilidades::leer_json;

sub formulario_nuevo_proveedor {
  my ($lista_circular) = @_;

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
  my ($lista_circular) = @_;

  my $ruta = 'datos/Proveedores/proveedores.json';
  my $proveedores = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  $lista_circular->limpiar();

  foreach my $proveedor ( @$proveedores ) {
    $lista_circular->insertar_nuevo($proveedor);
  }
}

1;
