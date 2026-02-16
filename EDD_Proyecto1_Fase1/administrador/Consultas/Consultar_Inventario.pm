#!/usr/bin/perl
package administrador::Consultas::Consultar_Inventario;
use strict;
use warnings;

use administrador::Inventario::buscar_medicamento_codigo;
use administrador::Consultas::modulos::obtener_f_c;
use gestion_datos::matriz_dispersa;
use administrador::Consultas::modulos::llenar_matriz;
use administrador::Consultas::modulos::opciones;
use interfaz_usuario::admin;

sub inicio {
  system("clear");

  my $ruta = "administrador/Inventario/inventario.json";
  my ($nombres, $laboratorios) = administrador::Inventario::buscar_medicamento_codigo::obtener_lab_name($ruta); 

  my ($n_cantidad, $l_cantidad) = administrador::Consultas::modulos::obtener_f_c::limites($nombres, $laboratorios);

  my $matrix = gestion_datos::matriz_dispersa->nuevo($n_cantidad, $l_cantidad);

  $matrix->nombre_filas(@$nombres);
  $matrix->nombre_columnas(@$laboratorios);

  administrador::Consultas::modulos::llenar_matriz::llenar($matrix, $ruta);

  administrador::Consultas::modulos::opciones::opciones($matrix);

  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
