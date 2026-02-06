#!/usr/bin/perl
package datos::Proveedores::formulario_entrega;
use strict;
use warnings;

use POSIX qw(strftime);

use utilidades::fecha_regex;
use utilidades::validar_numeros;
use utilidades::copiar_contenido_json;
use gestion_datos::lista_simple;
use gestion_datos::lista_circular_simple;
use reportes::proveedores_dots;
use reportes::proveedores_entregas_dots;

sub buscar_proveedor_por_nit {
  my ($lista_circular, $comprobar_nit) = @_;

  return undef unless defined $lista_circular->{ultimo_nodo};

  my $inicio = $lista_circular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  do {
    if ( $actual->{datos}->{NIT} eq $comprobar_nit ) {
      return $actual->{datos};
    }
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  return undef;
}

sub formulario_nueva_entrega {
  my ($proveedor, $lista_circular) = @_;
  my $ruta = 'datos/Proveedores/proveedores.json';

  my $lista_circular_entregas = gestion_datos::lista_circular_simple->nuevo();
  my $lista_simple_entregas = gestion_datos::lista_simple->nuevo();

  print "Código del medicamento: "; chomp(my $codigo_medicamento = <STDIN>);
  print "Cantidad a ingresar: "; chomp(my $cantidad = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($cantidad)) {
      print "Ingrese una cantidad válida: "; chomp($cantidad = <STDIN>);
    }
  print "Fecha de entrega (2028/12/31): "; chomp(my $fecha_entrega = <STDIN>);
    while (!utilidades::fecha_regex::validar_fecha($fecha_entrega)) {
      print "Ingrese un formato de fecha válido (Año/Mes/Día): "; chomp($fecha_entrega = <STDIN>);
    }
  print "Fecha de vencimiento (2028/12/31): "; chomp(my $fecha_vencimiento = <STDIN>);
    while (!utilidades::fecha_regex::validar_fecha($fecha_vencimiento)) {
      print "Ingrese un formato de fecha válido (Año/Mes/Día): "; chomp($fecha_vencimiento = <STDIN>);
    }
  print "Número de factura: "; chomp(my $factura = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($factura)) {
      print "Ingrese un número entero válido: "; chomp($factura = <STDIN>);
    }
  ## SI el código ingresado y la fecha de vencimiento coinciden con un elemento de "inventario.json" se suma a lo ya existente.
  # por motivos de realismo, no puedes tener como unidad a medicina que caduca en fechas distintas, se pueden confundir y 
  # entregar medicina caducada.
  ## SI solo coincide el código, se crea una nueva instancia con los datos de lo existente en el inventario pero modificando la caducidad.
  ## SI no coincide el código simplemente se rechaza la entrega ¿?

  if ( exists $proveedor->{Entregas} ) {
    foreach my $entrega ( @{$proveedor->{Entregas}} ) {
      $lista_simple_entregas->insertar_nuevo($entrega);
    }
  }

  $lista_simple_entregas->insertar_nuevo({
    Codigo => $codigo_medicamento,
    Cantidad => $cantidad,
    FechaDeEntrega => $fecha_entrega,
    Factura => $factura
  }); 

  $proveedor->{Entregas} = $lista_simple_entregas->almacenar_array_simple();

  my $fecha = strftime("%Y-%m-%d", localtime);
  my $t = time();
  my $nit = $proveedor->{NIT};
  reportes::proveedores_dots::generar_diagrama_proveedores(
    $lista_circular,
    "reportes/imagenes/Proveedores/proveedores_$fecha-$t.dot",
    "reportes/imagenes/Proveedores/proveedores_$fecha-$t.png",
    "reportes/imagenes/Proveedores/proveedores_$fecha-$t.svg"
  );

  reportes::proveedores_entregas_dots::generar_diagrama_entregas(
    $proveedor,
    "reportes/imagenes/Proveedores/entregas_$nit-$t.dot",
    "reportes/imagenes/Proveedores/entregas_$nit-$t.png",
    "reportes/imagenes/Proveedores/entregas_$nit-$t.svg"
  );

}

1;
