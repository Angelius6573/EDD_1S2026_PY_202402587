#!/usr/bin/perl
package utilidades::limite_entrada;
use strict;
use warnings;

sub comprobacion_menu {
  my ($inf_limit, $sup_limit) = @_;

  print "Ingrese el número de la acción que desea: ";
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

  if ( $ruta eq "\n" ) {
      print "Usando ruta por defecto...";
      $ruta = $ruta_d;
  } else {
    chomp $ruta;
  }
  return $ruta;
}

1;
