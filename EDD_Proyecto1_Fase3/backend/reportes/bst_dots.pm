#!/usr/bin/perl
package reportes::bst_dots;
use strict;
use warnings;
use utf8;

sub generar_diagrama_bst {
    my ($bst, $ruta_dot, $ruta_png, $ruta_svg) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
        or die "No se pudo abrir $ruta_dot: $!";

    print $fh "digraph BST_Equipos {\n";
    print $fh "  charset=\"UTF-8\";\n";
    print $fh "  node [shape=box, style=filled, fillcolor=\"#ede9fe\",";
    print $fh   " color=\"#6d28d9\", fontcolor=\"#1e1b4b\", fontsize=9, width=2];\n";
    print $fh "  edge [color=\"#7c3aed\", arrowsize=0.7];\n";
    print $fh "  graph [nodesep=0.6, ranksep=0.7];\n\n";

    if (!$bst->esta_vacio()) {
        _dot_nodo($bst->{raiz}, $fh, 1, $bst);
    } else {
        print $fh "  vacio [label=\"(vacío)\", fillcolor=\"#f3f4f6\"];\n";
    }

    print $fh "}\n";
    close($fh);
    _generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
}

sub _es_hoja {
    my ($nodo) = @_;
    return !defined $nodo->{izquierda} && !defined $nodo->{derecha};
}

sub _dot_nodo {
    my ($nodo, $fh, $es_raiz, $bst) = @_;
    return unless defined $nodo;

    my $id    = _id($nodo);
    my $cod   = _esc($nodo->{codigo}         // '');
    my $nom   = _esc($nodo->{nombre}         // '');
    my $fab   = _esc($nodo->{fabricante}     // '');
    my $cant  = $nodo->{cantidad}            // 0;
    my $nmin  = $nodo->{nivel_minimo}        // 0;

    my ($fill, $font, $bord);
    if ($es_raiz) {
        $fill = '"#4c1d95"'; $font = 'white'; $bord = '"#1e1b4b"';
    } elsif (_es_hoja($nodo)) {
        $fill = '"#c4b5fd"'; $font = '"#1e1b4b"'; $bord = '"#7c3aed"';
    } else {
        $fill = '"#ede9fe"'; $font = '"#1e1b4b"'; $bord = '"#6d28d9"';
    }

    my $extra = $es_raiz ? ' [RAÍZ]' : (_es_hoja($nodo) ? ' [hoja]' : '');
    my $alerta = ($cant < $nmin) ? "\\n⚠ STOCK BAJO" : '';

    my $label = "$cod$extra\\n$nom\\n$fab\\nStock: $cant$alerta";
    print $fh "  $id [label=\"$label\", fillcolor=$fill, fontcolor=$font, color=$bord];\n";

    if (defined $nodo->{izquierda}) {
        print $fh "  $id -> " . _id($nodo->{izquierda}) . " [label=\"<\"];\n";
        _dot_nodo($nodo->{izquierda}, $fh, 0, $bst);
    }
    if (defined $nodo->{derecha}) {
        print $fh "  $id -> " . _id($nodo->{derecha}) . " [label=\">\"];\n";
        _dot_nodo($nodo->{derecha}, $fh, 0, $bst);
    }
}

sub _id {
    my ($n) = @_;
    my $id = "$n";
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
