#!/usr/bin/perl
package datos::inventario;
use strict;
use warnings;

use interfaz_usuario::admin;
use utilidades::leer_json;
use utilidades::leer_csv;
use gestion_datos::lista_doblemente_enlazada;
use reportes::inventario_dots;

my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();

sub registrar_medicamento { #Registro manual
  print "Bienvenido administrador al registro unitario de medicamentos.\n";
  print "Por favor llene el siguiente formulario: \n";
  print "Código del medicamento: "; chomp(my $codigo_medicamento = <STDIN>);
  print "Nombre comercial: "; chomp(my $nombre_comercial = <STDIN>);
  print "Principio activo: "; chomp(my $principio_activo = <STDIN>);
  print "Laboratorio fabricante: "; chomp(my $lab_fabricante = <STDIN>);
  print "Precio del medicamento: "; chomp(my $precio = <STDIN>);
  print "Cantidad a registrar: "; chomp(my $cantidad = <STDIN>);
  print "Fecha de Vencimiento (01/01/2028): "; chomp(my $fecha_vencimiento = <STDIN>);
    
  print "Cantidad mínima permitida en stock: "; chomp(my $cantidad_minima = <STDIN>);

  ## OJO: Si lo dejamos como estaba hasta las 7 am del 03/02, se sobreescribe todo
  # Derivado a que JSON no permite solo insertar al final, hay que hacer un backup de todo el inventario...
  # Esto en un caso real puede llegar a desbordar la memoria RAM, ya que tenemos que tomar en cuenta el consumo
  # de las listas y todo el berenjenal que es almacenar tantos bytes de pura información.
  # Para un caso real se tendrían que usar BDs o segmentar los JSON a modo de BDs.
  # En este caso y porque soy muy vago vamos a llenar la lista constantemente con los datos ya presentes y los nuevos
  # y los vamos a meter en un solo documento :D
  my $copia_inventario = [];
  if (-e 'datos/inventario.json') {
    $copia_inventario = utilidades::leer_json::parsear_json('datos/inventario.json');
  }
  foreach my $element ( @$copia_inventario) {
    $lista->insertar_final($element);
  }

  ## A partir de este punto ya se mantiene como antes.
  # Llenar la lista con los datos previamente ingresados
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

  # Mandamos los datos al gestor de datos puesto en la lista
  # Y a continuación metemos tanto los datos previos como los nuevos al JSON 
  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('datos/inventario.json', $datos);

  ## Generación de imágenes con graphviz
  # Dado a que el .png es requerimiento, lo pongo, pero es mejor usar .svg, funciona bajo el mismo mecanismo
  my $nombre_tiempo = time();
  reportes::inventario_dots::generar_diagrama_inventario($lista, "reportes/imagenes/inventario_$nombre_tiempo.dot", "reportes/imagenes/inventario_$nombre_tiempo.png", "reportes/imagenes/inventario_$nombre_tiempo.svg");

  print "Carga finalizada, regresando a interfaz de administrador...";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub registrar_medicamento_masivo { # Carga por archivos .csv
  my $ruta_d = 'datos/carga_masiva.csv';
  print "Bienvenido administrador, al entorno de carga masiva de datos por archivos .csv\n";
  print "Por favor ingrese la ruta local del archivo, si no ingresa nada se usa la ruta \"$ruta_d\": ";
    my $ruta = <STDIN>;

    # Metodo para comprobar si la entrada $ruta es un string vacío o si de hecho cambio. 
    my $ruta_f = utilidades::limite_entrada::ruta($ruta, $ruta_d);

  # Proceso de lectura del archivo .csv usando librería externa pasando la ruta seleccionada
  my $medicamentos = utilidades::leer_csv::parsear_csv($ruta_f);

  ## Aquí, al igual que con la carga manual, hacemos un backup de todo el JSON original
  ## y luego metemos la info nueva
  my $copia_inventario = [];
  if (-e 'datos/inventario.json') {
    $copia_inventario = utilidades::leer_json::parsear_json('datos/inventario.json');
  }
  foreach my $element ( @$copia_inventario) {
    $lista->insertar_final($element);
  }

  # Nuevos datos
  foreach my $element ( @$medicamentos ) {
    $lista->insertar_final($element);
  }

  # Cargamos en el JSON todo lo almacenado en la lista
  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('datos/inventario.json', $datos);

  ## Generación de graphviz, se genera un trío nuevo por cada nueva carga, para mantener un historial
  ## Muy apropiado para un hospital real en realidad :P
  my $nombre_tiempo = time();
  reportes::inventario_dots::generar_diagrama_inventario($lista, "reportes/imagenes/inventario_$nombre_tiempo.dot", "reportes/imagenes/inventario_$nombre_tiempo.png", "reportes/imagenes/inventario_$nombre_tiempo.svg");

  print "Carga finalizada, regresando a interfaz de administrador...";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
