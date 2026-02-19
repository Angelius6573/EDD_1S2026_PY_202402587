#!/usr/bin/perl
package interfaz_usuario::nuevo_usuario;
use strict;
use warnings;

use gestion_datos::lista_doblemente_enlazada;
use utilidades::leer_json;
use utilidades::copiar_contenido_json;

sub nuevo_usuario {
  my ($nombre, $correo, $contrasena, $depto) = @_;
  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();
  
  my $copia_usuarios = [];
  my $ruta = "interfaz_usuario/nuevo_usuario.json";
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_usuarios, $ruta, $metodo, $lista);

  $lista->$metodo({
    nombre => $nombre,
    correo => $correo,
    contrasenia => $contrasena,
    codigo_departamental => $depto
  });

  my $datos = $lista->almacenar_array_simple();
  utilidades::leer_json::guardar_json($ruta, $datos);
}

1;
