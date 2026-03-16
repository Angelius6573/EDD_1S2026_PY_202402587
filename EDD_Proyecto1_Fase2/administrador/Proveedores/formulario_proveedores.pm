#!/usr/bin/perl
package administrador::Proveedores::formulario_proveedores;
use strict;
use warnings;

use interfaz_usuario::admin;
use utilidades::validar_numeros;
use utilidades::leer_json;
use administrador::Proveedores::comprobaciones;
use reportes::nombre_archivos;

sub formulario_nuevo_proveedor {
  my ($lista_circular) = @_;

  print " Ingrese el NIT del proveedor: "; chomp(my $nit = <STDIN>);
    while (!administrador::Proveedores::comprobaciones::validar_nit($lista_circular, $nit)) {
      print "   NIT ya registrado, ingrese uno distinto ó escriba la palabra \"Cancelar\" para volver al menú del administrador: "; chomp($nit = <STDIN>);
      if ( $nit eq 'Cancelar' ) {
        return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
      }
    }
  print " Ingrese el nombre de la empresa: "; chomp(my $nombre_empresa = <STDIN>);
  print " Ingrese el contacto principal: "; chomp(my $contacto_principal = <STDIN>);
  print " Ingrese el número de teléfono (12345678): "; chomp(my $telefono_num = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($telefono_num) ||
           !administrador::Proveedores::comprobaciones::validar_telefono($lista_circular, $telefono_num) ||
           length($telefono_num) != 8) {
      print "   Ingrese un número de teléfono válido (12345678). Si ingreso un número de teléfono ya registrado y es correcto. Vuelva a ingresarlo: "; chomp($telefono_num = <STDIN>);
    }
  print " Ingrese la dirección: "; chomp(my $direccion = <STDIN>);

  ## METER LO ANTERIOR A LA LISTA CIRCULAR
  # Por eso se valoriza si es interesante mantener utilidades::copiar_contenido_json
  # No resulto ser buena idea para este caso, no se formateaba correctamente el contenido en el JSON

  $lista_circular->insertar_nuevo({
    NIT => $nit,
    Empresa => $nombre_empresa,
    Contacto => $contacto_principal,
    Telefono => $telefono_num,
    Direccion => $direccion,
    Entregas => []
  });

  my $proveedor_instancia = $lista_circular->almacenar_array_simple(); # No hace falta poner la ruta completa aparentemente
  utilidades::leer_json::guardar_json('administrador/Proveedores/proveedores.json', $proveedor_instancia);

  my ($dot_name, $png_name, $svg_name) = reportes::nombre_archivos::nombre("Proveedores", "proveedores");
  reportes::proveedores_dots::generar_diagrama_proveedores($lista_circular, $dot_name, $png_name, $svg_name);
}

sub leer_json_proveedores {
  my ($lista_circular) = @_;

  my $ruta = 'administrador/Proveedores/proveedores.json';
  my $proveedores = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  $lista_circular->limpiar();

  foreach my $proveedor ( @$proveedores ) {
    $lista_circular->insertar_nuevo($proveedor);
  }
}

1;
