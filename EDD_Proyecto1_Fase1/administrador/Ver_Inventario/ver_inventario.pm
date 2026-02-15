#!/usr/bin/perl
package administrador::Ver_Inventario::ver_inventario;
use strict;
use warnings;

use interfaz_usuario::admin;
use administrador::Ver_Inventario::modulos::ordenar_inventario;
use administrador::Ver_Inventario::modulos::verificar_cantidad;
use administrador::Ver_Inventario::modulos::mostrar_info;
use utilidades::leer_json;

sub ver_inventario {
  system("clear");
  my $ruta_inventario = "administrador/Inventario/inventario.json";

  ## Ordenar inventario ordenado y mantener en RAM
  my $lista = administrador::Ver_Inventario::modulos::ordenar_inventario::ordenar_inventario($ruta_inventario);

  my $actual = $lista->{cabeza};
  printf("%-10s %-20s %-20s %-25s %-25s %-30s %-20s %-30s\n", 
      "Código", "Nombre", "Principio Activo", "Cantidad Disponible", "Cantidad Mínima", "Nivel de Cantidad Disponible", "Vencimiento", "Estado Caducidad"
    );
  print "-" x 180 . "\n";
  administrador::Ver_Inventario::modulos::mostrar_info::mostrar_info($actual);
    
  print "\n";
  print "Presione ENTER para continuar...";
  my $pausa = <STDIN>;

  print "Waos\n";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
