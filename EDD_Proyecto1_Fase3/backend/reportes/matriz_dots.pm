#!/usr/bin/perl
package reportes::matriz_dots;
use strict;
use warnings;
use utf8;

sub generar_diagrama_matriz {
    my ( $matriz, $ruta_dot, $ruta_png, $ruta_svg ) = @_;

    open( my $fh, '>:encoding(UTF-8)', $ruta_dot )
      or die "No se pudo abrir $ruta_dot: $!";

    print $fh "digraph MatrizProveedoresFabricantes {\n";
    print $fh "charset=\"UTF-8\";\n";
    print $fh "node [shape=plaintext];\n";
    print $fh "graph [nodesep=0.5, ranksep=0.8];\n\n";

    print $fh "matriz [label=<\n";
    print $fh
"<TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\">\n";

    my ( $filas, $columnas ) = $matriz->obtener_dimensiones();

    # Encabezado con nombres de fabricantes
    print $fh "<TR>\n";
    print $fh
"<TD BGCOLOR=\"#4a1d6d\"><FONT COLOR=\"white\"><B>Proveedor / Fabricante</B></FONT></TD>\n";

    for my $j ( 0 .. $columnas - 1 ) {
        my $fab = _escapar_html( $matriz->{nombres_columnas}[$j] // "Fab $j" );
        print $fh
"<TD BGCOLOR=\"#9b4dff\"><FONT COLOR=\"white\"><B>$fab</B></FONT></TD>\n";
    }
    print $fh "</TR>\n";

    # Filas de datos
    for my $i ( 0 .. $filas - 1 ) {
        print $fh "<TR>\n";
        my $proveedor =
          _escapar_html( $matriz->{nombres_filas}[$i] // "Prov $i" );
        print $fh "<TD BGCOLOR=\"#ede9fe\"><B>$proveedor</B></TD>\n";

        for my $j ( 0 .. $columnas - 1 ) {
            my $datos           = $matriz->obtener( $i, $j );
            my $precio          = $datos->{precio}          // 0;
            my $cantidad        = $datos->{cantidad}        // 0;
            my $cantidad_minima = $datos->{cantidad_minima} // 1;

            if ( $precio > 0 || $cantidad > 0 ) {
                my $precio_formateado = sprintf( "%.2f", $precio );
                my $color = _color_por_cantidad( $cantidad, $cantidad_minima );
                print $fh "<TD BGCOLOR=\"$color\">";
                print $fh "Q $precio_formateado<BR/>";
                print $fh "$cantidad uds.";
                print $fh "</TD>\n";
            }
            else {
                print $fh "<TD BGCOLOR=\"#f3f4f6\">-</TD>\n";
            }
        }
        print $fh "</TR>\n";
    }

    print $fh "</TABLE>\n";
    print $fh ">];\n";
    print $fh "}\n";
    close($fh);

    _generar_imagenes( $ruta_dot, $ruta_png, $ruta_svg );
}

sub _escapar_html {
    my ($texto) = @_;
    return '' unless defined $texto;
    $texto =~ s/&/&amp;/g;
    $texto =~ s/</&lt;/g;
    $texto =~ s/>/&gt;/g;
    $texto =~ s/"/&quot;/g;
    return $texto;
}

sub _color_por_cantidad {
    my ( $cantidad, $cantidad_minima ) = @_;

    if ( $cantidad_minima == 0 ) {
        return "#fee2e2";
    }

    my $factor = $cantidad / $cantidad_minima;

    if ( $factor < 0.5 ) {
        return "#dc2626";
    }
    elsif ( $factor < 0.8 ) {
        return "#d97706";
    }
    elsif ( $factor < 1.2 ) {
        return "#eab308";
    }
    elsif ( $factor < 2 ) {
        return "#84cc16";
    }
    else {
        return "#10b981";
    }
}

sub _generar_imagenes {
    my ( $dot, $png, $svg ) = @_;
    system("dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$dot' -o '$png' 2>/dev/null");
    system("dot -Tsvg -Gcharset=UTF-8 '$dot' -o '$svg' 2>/dev/null");
}

1;
