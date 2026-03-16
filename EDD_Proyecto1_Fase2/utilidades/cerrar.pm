#!/usr/bin/perl
package utilidades::cerrar;
use strict;
use warnings;

sub cerrar {
  print "Presione Enter para continuar..."; chomp(my $pausa = <STDIN>);
}

1;
