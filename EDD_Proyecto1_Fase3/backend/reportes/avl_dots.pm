#!/usr/bin/perl
package reportes::avl_dots;
use strict;
use warnings;
use utf8;

sub generar_diagrama_avl {
    my ($avl, $ruta_dot, $ruta_png, $ruta_svg) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
        or die "No se pudo abrir $ruta_dot: $!";

    print $fh "digraph AVL_PersonalMedico {\n";
    print $fh "  charset=\"UTF-8\";\n";
    print $fh "  node [shape=circle, style=filled, fillcolor=\"#ede9fe\",";
    print $fh   " color=\"#6d28d9\", fontcolor=\"#1e1b4b\", fontsize=10];\n";
    print $fh "  edge [color=\"#7c3aed\", arrowsize=0.7];\n";
    print $fh "  graph [nodesep=0.5, ranksep=0.8];\n\n";

    if (!$avl->esta_vacio()) {
        _dot_nodo($avl->{raiz}, $fh, 1);
    } else {
        print $fh "  vacio [label=\"(vacío)\", fillcolor=\"#f3f4f6\"];\n";
    }

    print $fh "}\n";
    close($fh);
    _generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
}

sub _dot_nodo {
    my ($nodo, $fh, $es_raiz) = @_;
    return unless defined $nodo;

    my $id    = _id_nodo($nodo);
    my $col   = _esc($nodo->{colegio}      // '');
    my $nom   = _esc($nodo->{nombre}       // '');
    my $tipo  = _esc($nodo->{tipo}         // '');
    my $depto = _esc($nodo->{departamento} // '');

    my $color = $es_raiz ? '"#7c3aed"' : '"#ede9fe"';
    my $fcolor = $es_raiz ? 'white'    : '"#1e1b4b"';
    my $bcolor = $es_raiz ? '"#4c1d95"' : '"#6d28d9"';

    print $fh "  $id [label=\"$col\\n$nom\\n$tipo\\n$depto\",";
    print $fh    " fillcolor=$color, fontcolor=$fcolor, color=$bcolor];\n";

    if (defined $nodo->{izquierda}) {
        my $id_izq = _id_nodo($nodo->{izquierda});
        print $fh "  $id -> $id_izq [label=\"I\"];\n";
        _dot_nodo($nodo->{izquierda}, $fh, 0);
    }
    if (defined $nodo->{derecha}) {
        my $id_der = _id_nodo($nodo->{derecha});
        print $fh "  $id -> $id_der [label=\"D\"];\n";
        _dot_nodo($nodo->{derecha}, $fh, 0);
    }
}

sub _id_nodo {
    my ($nodo) = @_;
    my $id = "$nodo";
    $id =~ s/\W/_/g;
    return "n$id";
}

sub _esc {
    my ($t) = @_;
    return '' unless defined $t;
    $t =~ s/\\/\\\\/g;
    $t =~ s/"/\\"/g;
    $t =~ s/\n/\\n/g;
    return $t;
}

sub _generar_imagenes {
    my ($dot, $png, $svg) = @_;
    system("dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$dot' -o '$png' 2>/dev/null");
    system("dot -Tsvg -Gcharset=UTF-8 '$dot' -o '$svg' 2>/dev/null");
}

1;
