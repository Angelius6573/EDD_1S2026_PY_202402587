#!/usr/bin/perl
package reportes::inventario_dots;
use strict;
use warnings;

sub generar_diagrama_inventario {
    my ($lista, $ruta_dot, $ruta_png, $ruta_svg) = @_;

    open my $fh, '>', $ruta_dot 
      or die "No se pudo abrir el archivo en $ruta_dot: $!";

    print $fh "digraph inventario {\n";
    print $fh "rankdir=LR;\n";          # De izquierda a derecha
    print $fh "node [shape=box, style=filled, width=2, height=1];\n";
    print $fh "graph [nodesep=0.5, ranksep=1, splines=true, overlap=false];\n";

    my $actual = $lista->{cabeza};
    my $contador = 0;
    my %nodos;

    while ($actual) {
        my $id = "n$contador";

        # Datos seleccionados para mostrar
        my $codigo = $actual->{datos}->{codigo} // '';
        my $nombre = $actual->{datos}->{nombre} // '';
        my $fecha = $actual->{datos}->{fecha_vencimiento} // '';
        my $cantidad = $actual->{datos}->{cantidad} // 0;
        my $nivel_minimo = $actual->{datos}->{nivel_minimo} // 0;

        ## Verde -> Stock suficiente
        ## Amarillo -> Stock entre 1 a 50, medianamente suficiente
        ## Rojo -> Stock insuficiente
        my $color = "green";
        if ($cantidad < $nivel_minimo) {
            $color = "red";
        } elsif ($cantidad <= $nivel_minimo + 50) {
            $color = "yellow";
        }

        my $label = "Código: $codigo\\nNombre: $nombre\\nVence: $fecha\\nStock: $cantidad";
        print $fh "$id [label=\"$label\", fillcolor=$color];\n";

        $nodos{$actual} = $id;
        $actual = $actual->{siguiente};
        $contador++;
    }

    # Conectar nodos
    $actual = $lista->{cabeza};
    while ($actual && $actual->{siguiente}) {
        my $from = $nodos{$actual};
        my $to = $nodos{$actual->{siguiente}};
        print $fh "$from -> $to;\n";        # siguiente
        print $fh "$to -> $from [style=dashed];\n";  # anterior
        $actual = $actual->{siguiente};
    }

    print $fh "}\n";
    close $fh;

    # Generar imágenes
    system("dot -Tpng $ruta_dot -o $ruta_png") == 0
      or warn "Falló en generación de reporte .png";
    system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
      or warn "Falló en generación de reporte .svg";
}

1;
