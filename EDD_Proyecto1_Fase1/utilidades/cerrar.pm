#!/usr/bin/perl
package utilidades::cerrar;
use strict;
use warnings;

sub cerrar {
  print "Presione Enter para continuar...\n"; chomp(my $pausa = <STDIN>);
}

1;
