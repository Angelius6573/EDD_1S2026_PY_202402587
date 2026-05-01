#!/usr/bin/perl
package api::reportes;
use strict;
use warnings;
use utf8;
use JSON::PP;
use File::Path qw(make_path);

sub grafo_colaboraciones {
    my ($ctx)   = @_;
    my $grafo   = $ctx->{grafo};
    my $nodos   = $grafo->todos_los_nodos();
    my $aristas = $grafo->obtener_aristas();
    my $dot     = "digraph G {\n";
    $dot .= "  node [shape=circle, style=filled];\n";
    for my $nodo (@$nodos) {
        my $info  = $grafo->obtener_nodo($nodo);
        my $color = '#c4b5fd';
        if ( $info->{departamento} ) {
            if    ( $info->{departamento} eq 'DEP-ADM' ) { $color = '#fca5a5'; }
            elsif ( $info->{departamento} eq 'DEP-MED' ) { $color = '#86efac'; }
            elsif ( $info->{departamento} eq 'DEP-CIR' ) { $color = '#7aa2f7'; }
            elsif ( $info->{departamento} eq 'DEP-LAB' ) { $color = '#fde047'; }
            elsif ( $info->{departamento} eq 'DEP-FAR' ) { $color = '#c084fc'; }
            else                                         { $color = '#9ca3af'; }
        }
        else {
            $color = '#9ca3af';
        }
        $dot .=
"  \"$nodo\" [label=\"$nodo\\n$info->{nombre}\", fillcolor=\"$color\"];\n";
    }
    for my $ar (@$aristas) {
        $dot .= "  \"$ar->[0]\" -- \"$ar->[1]\";\n";
    }
    $dot .= "}\n";
    my $ruta = "reportes/grafo_colaboracion.dot";
    make_path('reportes');
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir $ruta";
    print $fh $dot;
    close $fh;
    system("dot -Tpng '$ruta' -o 'reportes/grafo_colaboracion.png'");
    return { dot => $dot, png => '/reportes/grafo_colaboracion.png' };
}

sub lista_adyacencia {
    my ($ctx) = @_;
    my $grafo = $ctx->{grafo};
    my $nodos = $grafo->todos_los_nodos();
    my $texto = "";
    for my $nodo (@$nodos) {
        my $vecinos = $grafo->obtener_vecinos($nodo);
        $texto .= "$nodo: " . join( ', ', @$vecinos ) . "\n";
    }
    return { lista => $texto };
}

sub tabla_hash_estado {
    my ($ctx) = @_;
    my $stats = $ctx->{tabla_hash}->obtener_estadisticas();
    return { estadisticas => $stats };
}

sub reporte_compresion {
    my ($ctx)    = @_;
    my $dir      = 'datos/chats';
    my @archivos = ();
    if ( -d $dir ) {
        opendir( my $dh, $dir );
        @archivos = grep { /\.lzw$/ } readdir($dh);
        closedir($dh);
    }
    return { archivos => \@archivos };
}

1;
