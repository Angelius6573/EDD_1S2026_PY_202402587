#!/usr/bin/perl
package utilidades::limite_entrada;
use strict;
use warnings;

use interfaz_usuario::admin;

sub comprobacion_menu {
  my ($inf_limit, $sup_limit) = @_;

  print "Ingrese el número de la opción que desea: ";
  my $consulta = <STDIN>;
  chomp $consulta;

  while ( $consulta !~ /^\d+$/ || $consulta < $inf_limit || $consulta > $sup_limit ) {
    print "Ingrese una opción válida. ($inf_limit~$sup_limit): ";
    $consulta = <STDIN>;

    last unless defined $consulta;
    chomp $consulta;
  }
  return $consulta; 
}

sub ruta {
  my ($ruta, $ruta_d) = @_;
  chomp $ruta if defined $ruta;

  if ( $ruta eq '' ) {
    return $ruta_d;
  }
  if ( !defined $ruta || !-e $ruta ) {
    print "La ruta ingresada no es válida.\n";
    print "Regresando al menú de usuario...\n";
    interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  }

  print "Ruta válidada correctamente, procediendo...\n";
  return $ruta;
}

1;
