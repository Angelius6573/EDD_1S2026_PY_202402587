#!/usr/bin/perl
package reportes::lista_adyacencia_dots;
use strict;
use warnings;
use utf8;

sub generar_reporte {
    my ( $grafo, $ruta_txt ) = @_;
    my $nodos = $grafo->todos_los_nodos();
    open( my $fh, '>:encoding(UTF-8)', $ruta_txt )
      or die "No se pudo abrir $ruta_txt: $!";
    for my $nodo (@$nodos) {
        my $vecinos = $grafo->obtener_vecinos($nodo);
        my $lista   = join( ', ', @$vecinos );
        print $fh "$nodo: $lista\n";
    }
    close($fh);
}

1;
