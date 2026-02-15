#!/usr/bin/perl
package administrador::Ver_Inventario::modulos::ordenar_inventario;
use strict;
use warnings;

use gestion_datos::lista_doblemente_enlazada;
use administrador::Inventario::buscar_medicamento_codigo;

sub ordenar_inventario {
  my ($ruta) = @_;
  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();

  $lista = administrador::Inventario::buscar_medicamento_codigo::en_general_lista($ruta, $lista, "insertar_final");
  $lista->ordenar_por_campo("codigo");

  return $lista;
}

1;
