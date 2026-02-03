#!/usr/bin/perl
package datos::inventario;
use strict;
use warnings;

use interfaz_usuario::admin;
use utilidades::leer_json;
#use utilidades::leer_csv;
use gestion_datos::lista_doblemente_enlazada;

my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();

sub registrar_medicamento {
  print "Bienvenido administrador al registro unitario de medicamentos.\n";
  print "Por favor llene el siguiente formulario: \n";
  print "Código del medicamento: "; chomp(my $codigo_medicamento = <STDIN>);
  print "Nombre comercial: "; chomp(my $nombre_comercial = <STDIN>);
  print "Principio activo: "; chomp(my $principio_activo = <STDIN>);
  print "Laboratorio fabricante: "; chomp(my $lab_fabricante = <STDIN>);
  print "Precio del medicamento: "; chomp(my $precio = <STDIN>);
  print "Cantidad a registrar: "; chomp(my $cantidad = <STDIN>);
  print "Fecha de Vencimiento (01/01/2000): "; chomp(my $fecha_vencimiento = <STDIN>);
  print "Cantidad mínima permitida en stock: "; chomp(my $cantidad_minima = <STDIN>);

  ## OJO: Si lo dejamos como estaba hasta las 7 am, se sobreescribe todo
  # Derivado a que JSON no permite solo insertar al final, hay que hacer un backup de todo el inventario...
  # Esto en un caso real puede llegar a desbordar la memoria RAM, ya que tenemos que tomar en cuenta el consumo
  # de las listas y todo el berenjenal que es almacenar tantos bytes de pura información.
  # Para un caso real se tendrían que usar BDs o segmentar los JSON a modo de BDs.
  my $copia_inventario = [];
  if (-e 'datos/inventario.json') {
    $copia_inventario = utilidades::leer_json::parsear_json('datos/inventario.json');
  }
  foreach my $element ( @$copia_inventario) {
    $lista->insertar_final($element);
  }

  ## A partir de este punto ya se mantiene como antes.

  $lista->insertar_final({ 
      codigo => $codigo_medicamento, 
      nombre => $nombre_comercial, 
      principio_activo => $principio_activo,
      laboratorio => $lab_fabricante,
      precio_unitario => $precio,
      cantidad => $cantidad,
      fecha_vencimiento => $fecha_vencimiento,
      nivel_minimo => $cantidad_minima
    });

  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('datos/inventario.json', $datos);
  print "Carga finalizada, regresando a interfaz de administrador...";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub registrar_medicamento_masivo {
  print "hola";
}

1;
