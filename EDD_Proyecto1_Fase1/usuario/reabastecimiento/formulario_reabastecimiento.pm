#!/usr/bin/perl
package usuario::reabastecimiento::formulario_reabastecimiento;
use strict;
use warnings;

use utilidades::validar_numeros;
use utilidades::limite_entrada;

sub formulario {
  print "Cantidad requerida: "; chomp(my $cantidad = <STDIN>);
    while (!utilidades::validar_numeros::validar_int_positivo($cantidad)) {
      print "Ingrese una cantidad válida: "; chomp($cantidad = <STDIN>);
    }

  print "Prioridad:
  1. Urgente
  2. Alta
  3. Media
  4. Baja \n";
  my $p_menu = utilidades::limite_entrada::comprobacion_menu(1, 4);
  my $prioridad = clave_valor($p_menu);

  print "Razón de la solicitud: "; chomp(my $razon = <STDIN>);

  return ($cantidad, $prioridad, $razon);
}

sub clave_valor {
  my ($clave) = @_;
  my @valores = (
    {clave => 1, valor => "Urgente"},
    {clave => 2, valor => "Alta"},
    {clave => 3, valor => "Media"},
    {clave => 4, valor => "Baja"}
  );
  
  foreach my $valor ( @valores ) {
    if ( $clave == $valor->{clave} ) {
      return $valor->{valor}
    }
  }
}

1;
