#!/usr/bin/perl
package administrador::Inventario::inventario;
use strict;
use warnings;

use interfaz_usuario::admin;
use utilidades::leer_json;
use utilidades::leer_csv;
use utilidades::fecha_regex;
use utilidades::validar_numeros;
use utilidades::copiar_contenido_json;
use gestion_datos::lista_doblemente_enlazada;
use reportes::inventario_dots;
use reportes::nombre_archivos;
use utilidades::comparar_cantidades;
use utilidades::cerrar;

sub registrar_medicamento { #Registro manual
  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo(); # Creación de la lista, no global, sin dupeos

  system("clear");
  print "Bienvenido administrador al registro unitario de medicamentos.\n";
  print "Por favor llene el siguiente formulario: \n";
  print " Código del medicamento: "; chomp(my $codigo_medicamento = <STDIN>);
  print " Nombre comercial: "; chomp(my $nombre_comercial = <STDIN>);
  print " Principio activo: "; chomp(my $principio_activo = <STDIN>);
  print " Laboratorio fabricante: "; chomp(my $lab_fabricante = <STDIN>);
  print " Precio del medicamento: "; chomp(my $precio = <STDIN>);
    while (!utilidades::validar_numeros::validar_float_positivo($precio)) {
      print "   Ingrese un formato de precio válido: "; chomp($precio = <STDIN>);
    }
  print " Cantidad a registrar: "; chomp(my $cantidad = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($cantidad)) {
      print "   Ingrese una cantidad válida (Número entero): "; chomp($cantidad = <STDIN>);
    }
  print " Fecha de vencimiento (Año/Mes/Día): "; chomp(my $fecha_vencimiento = <STDIN>);
    while (!utilidades::fecha_regex::validar_fecha($fecha_vencimiento)) {
      print "   Ingrese un formato de fecha válido (Año/Mes/Día): "; chomp($fecha_vencimiento = <STDIN>);
    }
  print " Cantidad mínima permitida en stock: "; chomp(my $cantidad_minima = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($cantidad_minima)) {
      print "   Ingrese una cantidad válida (Número entero): "; chomp($cantidad_minima = <STDIN>);
    }

  my $tiempo_reabastecimiento = utilidades::comparar_cantidades::comparar_cantidades($cantidad, $cantidad_minima);
  ## OJO: Si lo dejamos como estaba hasta las 7 am del 03/02, se sobreescribe todo
  # Derivado a que JSON no permite solo insertar al final, hay que hacer un backup de todo el inventario...
  # Esto en un caso real puede llegar a desbordar la memoria RAM, ya que tenemos que tomar en cuenta el consumo
  # de las listas y todo el berenjenal que es almacenar tantos bytes de pura información.
  # Para un caso real se tendrían que usar BDs o segmentar los JSON a modo de BDs.
  # En este caso y porque soy muy vago vamos a llenar la lista constantemente con los datos ya presentes y los nuevos
  # y los vamos a meter en un solo documento :D
  #
  # my $copia_inventario = [];
  # if (-e 'datos/inventario.json') {
  #   $copia_inventario = utilidades::leer_json::parsear_json_posiblemente_vacio('datos/inventario.json');
  # }
  # foreach my $element ( @$copia_inventario) {
  #   $lista->insertar_final($element);
  # }
  ## La siguiente implementación resume en un modulo lo previamente desarrollado, facilita el ingreso de los datos en 
  ## múltiples tipos de listas según el método que definas.
  my $copia_inventario = [];
  my $ruta = 'administrador/Inventario/inventario.json';
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_inventario, $ruta, $metodo, $lista);

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
    nivel_minimo => $cantidad_minima,
    tiempo_reabastecer => $tiempo_reabastecimiento
  });

  # Mandamos los datos al gestor de datos puesto en la lista
  # Y a continuación metemos tanto los datos previos como los nuevos al JSON 
  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('administrador/Inventario/inventario.json', $datos);

  ## Generación de imágenes con graphviz
  # Dado a que el .png es requerimiento, lo pongo, pero es mejor usar .svg, funciona bajo el mismo mecanismo
  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Inventario", "inventario");
  reportes::inventario_dots::generar_diagrama_inventario($lista, $nombre_dot, $nombre_png, $nombre_svg);

  print "Carga finalizada, regresando a interfaz de administrador...\n\n";
  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub registrar_medicamento_masivo { # Carga por archivos .csv
  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo(); # Creación de la lista, esta vez sin dupeos

  system("clear");
  my $ruta_d = 'administrador/Inventario/carga_masiva.csv';
  print "Bienvenido administrador, al entorno de carga masiva de datos por archivos .csv\n";
  print "Por favor ingrese la ruta local del archivo.\n";
  print "Si no ingresa nada se usará la ruta por defecto: \"$ruta_d\" \n";
  print " Ruta: "; my $ruta = <STDIN>;

    ## !Urgente: Añadir método para validar si la ruta ingresada es válida
    ## !Urgente: Añadir una salvaguarda en caso de no encontrar la ruta por default

    # Metodo para comprobar si la entrada $ruta es un string vacío o si de hecho cambio. 
    my $ruta_f = utilidades::limite_entrada::ruta($ruta, $ruta_d);

  # Proceso de lectura del archivo .csv usando librería externa pasando la ruta seleccionada
  my $medicamentos = utilidades::leer_csv::parsear_csv($ruta_f);

  ## Aquí, al igual que con la carga manual, hacemos un backup de todo el JSON original
  ## y luego metemos la info nueva
  # my $copia_inventario = [];
  # if (-e 'datos/inventario.json') {
  #   $copia_inventario = utilidades::leer_json::parsear_json_posiblemente_vacio('datos/inventario.json');
  # }
  # foreach my $element ( @$copia_inventario) {
  #   $lista->insertar_final($element);
  # }
  my $copia_inventario = [];
  $ruta = 'administrador/Inventario/inventario.json';
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_inventario, $ruta, $metodo, $lista);

  # Nuevos datos, solo que esta vez más automatico.
  # Validamos el tiempo de reabastecimiento para todos los datos del archivo CSV
  foreach my $medicamento ( @$medicamentos ) {
    my $tiempo_reabastecimiento = utilidades::comparar_cantidades::comparar_cantidades(
      $medicamento->{cantidad},
      $medicamento->{nivel_minimo}
    );
    $medicamento->{tiempo_reabastecer} = $tiempo_reabastecimiento;

    $lista->insertar_final($medicamento);
  } # Usar mismo proceso para validar usuarios

  # Cargamos en el JSON todo lo almacenado en la lista
  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('administrador/Inventario/inventario.json', $datos);

  ## Generación de graphviz, se genera un trío nuevo por cada nueva carga, para mantener un historial
  ## Muy apropiado para un hospital real en realidad :P
  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Inventario", "inventario");
  reportes::inventario_dots::generar_diagrama_inventario($lista, $nombre_dot, $nombre_png, $nombre_svg);

  print "Carga finalizada, regresando a interfaz de administrador...\n\n";
  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
