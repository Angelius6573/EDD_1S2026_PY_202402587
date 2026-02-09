#!/usr/bin/perl
package administrador::Proveedores::formulario_entrega;
use strict;
use warnings;

use POSIX qw(strftime);

use utilidades::fecha_regex;
use utilidades::validar_numeros;
use utilidades::copiar_contenido_json;
use gestion_datos::lista_simple;
use reportes::proveedores_dots;
use reportes::proveedores_entregas_dots;
use administrador::Inventario::leer_inventario_json;

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

  my $ruta = 'administrador/Proveedores/proveedores.json';
  my $lista_simple_entregas = gestion_datos::lista_simple->nuevo();

  print "Código del medicamento: "; chomp(my $codigo_medicamento = <STDIN>);
    administrador::Inventario::leer_inventario_json::identificar_codigo($codigo_medicamento, "administrador"); #Codigo identificado, a la espera de modificar la cantidad
  print "Fecha de entrega (Año/Mes/Días): "; chomp(my $fecha_entrega = <STDIN>);
    while (!utilidades::fecha_regex::validar_fecha($fecha_entrega)) {
      print "Ingrese un formato de fecha válido (Año/Mes/Día): "; chomp($fecha_entrega = <STDIN>);
    }
  print "Número de factura (Número Entero): "; chomp(my $factura = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($factura) ||
           !administrador::Proveedores::comprobaciones::validar_factura($factura)) {
      print "El número de factura ya existe o no es válido. Ingreselo nuevamente: "; chomp($factura = <STDIN>);
    }
  ## SI el código ingresado y la fecha de vencimiento coinciden con un elemento de "inventario.json" se suma a lo ya existente.
  # por motivos de realismo, no puedes tener como unidad a medicina que caduca en fechas distintas, se pueden confundir y 
  # entregar medicina caducada.
  ## SI solo coincide el código, se crea una nueva instancia con los datos de lo existente en el inventario pero modificando la caducidad.
  ## SI no coincide el código simplemente se rechaza la entrega ¿?
  # Decido mejor no considerar la fecha de vencimiento, como no lo piden, y es más trabajo innecesario, pues así se queda
  print "Cantidad a ingresar: "; chomp(my $cantidad = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($cantidad)) {
      print "Ingrese una cantidad válida: "; chomp($cantidad = <STDIN>);
    }
  administrador::Inventario::leer_inventario_json::agregar_cantidad($codigo_medicamento, $cantidad);

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

  my $nombre_tiempo = time();

  my $fecha = strftime("%Y-%m-%d", localtime);
  my $dot_provs = "reportes/archivos_dots/Proveedores/proveedores_$fecha-$nombre_tiempo.dot";
  my $png_provs = "reportes/imagenes/Proveedores/PNG/proveedores_$fecha-$nombre_tiempo.png";
  my $svg_provs = "reportes/imagenes/Proveedores/SVG/proveedores_$fecha-$nombre_tiempo.svg"; 
  reportes::proveedores_dots::generar_diagrama_proveedores($lista_circular, $dot_provs, $png_provs, $svg_provs);

  my $nit = $proveedor->{NIT};
  my $dot_entrega = "reportes/archivos_dots/Entrega_Proveedor/entregas_$nit-$nombre_tiempo.dot";
  my $png_entrega = "reportes/imagenes/Entrega_Proveedor/PNG/entregas_$nit-$nombre_tiempo.png";
  my $svg_entrega = "reportes/imagenes/Entrega_Proveedor/SVG/entregas_$nit-$nombre_tiempo.svg"; 
  reportes::proveedores_entregas_dots::generar_diagrama_entregas($proveedor, $dot_entrega, $png_entrega, $svg_entrega);
}

1;
