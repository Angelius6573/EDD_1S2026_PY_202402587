package reportes::matriz_dots;
use strict;
use warnings;
use utf8;
use File::Path qw(make_path);

sub generar_diagrama_matriz {
    my ( $matriz, $ruta_dot, $ruta_png, $ruta_svg ) = @_;

    open( my $fh, '>:encoding(UTF-8)', $ruta_dot )
      or die "No se pudo abrir $ruta_dot: $!";

    print $fh "digraph MatrizProveedoresFabricantes {\n";
    print $fh "  charset=\"UTF-8\";\n";
    print $fh "  node [shape=plaintext];\n";
    print $fh "  graph [nodesep=0.5, ranksep=0.8];\n\n";

    print $fh "  matriz [label=<\n";
    print $fh
"    <TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\">\n";

    my ( $filas, $columnas ) = $matriz->obtener_dimensiones();

    # Encabezado
    print $fh "      <TR>\n";
    print $fh
"        <TD BGCOLOR=\"#4a1d6d\"><FONT COLOR=\"white\"><B>Proveedor / Fabricante</B></FONT></TD>\n";
    for my $j ( 0 .. $columnas - 1 ) {
        my $fab = _escapar_html( $matriz->{nombres_columnas}[$j] // "Fab $j" );
        print $fh
"        <TD BGCOLOR=\"#9b4dff\"><FONT COLOR=\"white\"><B>$fab</B></FONT></TD>\n";
    }
    print $fh "      </TR>\n";

    # Filas de datos
    for my $i ( 0 .. $filas - 1 ) {
        print $fh "      <TR>\n";
        my $proveedor =
          _escapar_html( $matriz->{nombres_filas}[$i] // "Prov $i" );
        print $fh "        <TD BGCOLOR=\"#ede9fe\"><B>$proveedor</B></TD>\n";
        for my $j ( 0 .. $columnas - 1 ) {
            my $datos    = $matriz->obtener( $i, $j );
            my $cantidad = $datos->{cantidad} // 0;
            if ( $cantidad > 0 ) {
                my $color = _color_por_cantidad($cantidad);
                print $fh "        <TD BGCOLOR=\"$color\">$cantidad</TD>\n";
            }
            else {
                print $fh "        <TD BGCOLOR=\"#f3f4f6\">-</TD>\n";
            }
        }
        print $fh "      </TR>\n";
    }

    print $fh "    </TABLE>\n";
    print $fh "  >];\n";
    print $fh "}\n";

    close($fh);

    # Generar imágenes
    system(
"dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>/dev/null"
    );
    system("dot -Tsvg -Gcharset=UTF-8 '$ruta_dot' -o '$ruta_svg' 2>/dev/null");
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
    my ($cantidad) = @_;

    # Simplemente un degradado de verde según la cantidad
    if ( $cantidad < 1000 )  { return "#dc2626"; }    # rojo
    if ( $cantidad < 5000 )  { return "#d97706"; }    # naranja
    if ( $cantidad < 20000 ) { return "#eab308"; }    # amarillo
    if ( $cantidad < 50000 ) { return "#84cc16"; }    # verde claro
    return "#10b981";                                 # verde intenso
}

1;
