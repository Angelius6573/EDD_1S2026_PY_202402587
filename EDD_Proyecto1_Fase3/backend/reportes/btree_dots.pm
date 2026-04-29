#!/usr/bin/perl
package reportes::btree_dots;
use strict;
use warnings;
use utf8;

sub generar_diagrama_btree {
    my ($btree, $ruta_dot, $ruta_png, $ruta_svg) = @_;

    open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
        or die "No se pudo abrir $ruta_dot: $!";

    print $fh "digraph BTree_Suministros {\n";
    print $fh "  charset=\"UTF-8\";\n";
    print $fh "  node [shape=record, style=filled, fontsize=9,";
    print $fh   " color=\"#6d28d9\", fontcolor=\"#1e1b4b\"];\n";
    print $fh "  edge [color=\"#7c3aed\", arrowsize=0.7];\n";
    print $fh "  graph [nodesep=0.5, ranksep=0.8];\n\n";

    if (!$btree->esta_vacio()) {
        my $contador = 0;
        _dot_nodo($btree->{raiz}, $fh, \$contador);
    } else {
        print $fh "  vacio [label=\"(vacío)\", fillcolor=\"#f3f4f6\"];\n";
    }

    print $fh "}\n";
    close($fh);
    _generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
}

sub _dot_nodo {
    my ($nodo, $fh, $contador) = @_;
    return unless defined $nodo;

    my $id = "btnode_$$contador";
    $$contador++;

    # Color: amarillo si lleno (3 claves = MAX), verde si tiene espacio
    use constant MAX => 3;
    my $fill = ($nodo->{num} == MAX) ? '"#fef08a"' : '"#bbf7d0"';
    my $bord = ($nodo->{num} == MAX) ? '"#ca8a04"' : '"#15803d"';

    # Construir label tipo record: <p0> | cod1 | <p1> | cod2 | <p2> | ... | <pN>
    my $label = "<p0>";
    for my $i (1 .. $nodo->{num}) {
        my $cod  = _esc($nodo->{val}[$i]{codigo}   // "?");
        my $nom  = _esc($nodo->{val}[$i]{nombre}   // "");
        my $cant = $nodo->{val}[$i]{cantidad}       // 0;
        $label .= " | $cod\\n$nom\\nStock:$cant | <p$i>";
    }
    # Indicador de ocupación
    my $ocupacion = $nodo->{num} . "/" . MAX;

    print $fh "  $id [label=\"{$label}\", fillcolor=$fill, color=$bord];\n";
    print $fh "  # Ocupación: $ocupacion\n";

    # Generar IDs para hijos y conectar
    for my $i (0 .. $nodo->{num}) {
        if (defined $nodo->{link}[$i]) {
            my $hijo_id = "btnode_$$contador";
            print $fh "  $id:p$i -> $hijo_id;\n";
            _dot_nodo($nodo->{link}[$i], $fh, $contador);
        }
    }
}

sub _esc {
    my ($t) = @_;
    return '' unless defined $t;
    $t =~ s/\\/\\\\/g;
    $t =~ s/"/\\"/g;
    $t =~ s/\n/\\n/g;
    $t =~ s/[<>{}|]/_/g;  # caracteres especiales de record
    return $t;
}

sub _generar_imagenes {
    my ($dot, $png, $svg) = @_;
    system("dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$dot' -o '$png' 2>/dev/null");
    system("dot -Tsvg -Gcharset=UTF-8 '$dot' -o '$svg' 2>/dev/null");
}

1;
