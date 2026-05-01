#!/usr/bin/perl
package reportes::grafo_colaboracion_dots;
use strict;
use warnings;
use utf8;
use File::Path qw(make_path);

sub generar_reporte {
    my ( $grafo, $ruta_dot, $ruta_png, $ruta_svg ) = @_;
    my $nodos   = $grafo->todos_los_nodos();
    my $aristas = $grafo->obtener_aristas();
    open( my $fh, '>:encoding(UTF-8)', $ruta_dot )
      or die "No se pudo abrir $ruta_dot: $!";
    print $fh "graph G {\n";
    print $fh "  charset=\"UTF-8\";\n";
    print $fh
"  node [shape=circle, style=filled, fontcolor=white, fontname=\"Arial\"];\n";
    print $fh "  edge [color=\"#7c3aed\", penwidth=1.5];\n";

    for my $nodo (@$nodos) {
        my $info  = $grafo->obtener_nodo($nodo);
        my $color = '#9ca3af';
        my $dep   = $info->{departamento} // '';
        if    ( $dep eq 'DEP-ADM' ) { $color = '#ef4444'; }
        elsif ( $dep eq 'DEP-MED' ) { $color = '#22c55e'; }
        elsif ( $dep eq 'DEP-CIR' ) { $color = '#3b82f6'; }
        elsif ( $dep eq 'DEP-LAB' ) { $color = '#facc15'; }
        elsif ( $dep eq 'DEP-FAR' ) { $color = '#a855f7'; }
        elsif ( $dep eq 'SIN-DEP' ) { $color = '#6b7280'; }
        my $nombre = $info->{nombre};
        $nombre =~ s/"/\\"/g;
        my $label = "$nodo\\n$nombre";
        print $fh "  \"$nodo\" [label=\"$label\", fillcolor=\"$color\"];\n";
    }
    for my $ar (@$aristas) {
        print $fh "  \"$ar->[0]\" -- \"$ar->[1]\";\n";
    }
    print $fh "}\n";
    close($fh);
    _generar_imagenes( $ruta_dot, $ruta_png, $ruta_svg );
}

sub _generar_imagenes {
    my ( $dot, $png, $svg ) = @_;
    system("dot -Tpng -Gdpi=150 '$dot' -o '$png' 2>/dev/null");
    system("dot -Tsvg '$dot' -o '$svg' 2>/dev/null");
}

1;
