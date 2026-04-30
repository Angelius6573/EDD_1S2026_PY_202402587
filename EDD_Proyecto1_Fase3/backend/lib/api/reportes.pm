#!/usr/bin/perl
package api::reportes;
use strict;
use warnings;
use utf8;
use JSON::PP;
use File::Path qw(make_path);

# ------------------------------------------------------------
# Reporte: Grafo de Colaboraciones (no dirigido)
# ------------------------------------------------------------
sub grafo_colaboraciones {
    my ($ctx)   = @_;
    my $grafo   = $ctx->{grafo};
    my $nodos   = $grafo->todos_los_nodos();
    my $aristas = $grafo->obtener_aristas();

    my $dot = "graph G {\n";
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
        my $nombre = $info->{nombre};
        $nombre =~ s/"/\\"/g;
        $dot .=
          "  \"$nodo\" [label=\"$nodo\\n$nombre\", fillcolor=\"$color\"];\n";
    }

    for my $ar (@$aristas) {
        my ( $a, $b ) = @$ar;
        $dot .= "  \"$a\" -- \"$b\";\n";
    }
    $dot .= "}\n";

    make_path('reportes');
    my $ruta_dot = 'reportes/grafo_colaboracion.dot';
    my $ruta_png = 'reportes/grafo_colaboracion.png';
    open my $fh, '>:encoding(UTF-8)', $ruta_dot
      or die "No se pudo escribir $ruta_dot";
    print $fh $dot;
    close $fh;

    my $output =
      `dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>&1`;
    if ( $? != 0 ) {
        warn "Error generando PNG del grafo: $output";
        return { error => "No se pudo generar la imagen: $output" };
    }

    return { png => '/reportes/grafo_colaboracion.png' };
}

# ------------------------------------------------------------
# Reporte: Lista de Adyacencia (texto)
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Reporte: Tabla Hash (estadísticas)
# ------------------------------------------------------------
sub tabla_hash_estado {
    my ($ctx) = @_;
    my $stats = $ctx->{tabla_hash}->obtener_estadisticas();
    return { estadisticas => $stats };
}

# ------------------------------------------------------------
# Reporte: Archivos comprimidos LZW (solo listado)
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Reporte: Matriz Dispersa (tabla HTML dentro de DOT)
# ------------------------------------------------------------
sub matriz_dispersa {
    my ($ctx)        = @_;
    my $proveedores  = $ctx->{prov}->almacenar_array_simple();
    my $medicamentos = $ctx->{med}->almacenar_array_simple();

    my %fabricantes;
    for my $med (@$medicamentos) {
        my $fab = $med->{fabricante} // '';
        $fabricantes{$fab} = 1 if $fab;
    }
    my @fabricantes = sort keys %fabricantes;

    my %matriz_datos;
    for my $prov (@$proveedores) {
        my $prov_nombre = $prov->{nombre};
        for my $entrega ( @{ $prov->{entregas} // [] } ) {
            my $fab = $entrega->{fabricante} // '';
            next unless $fab;
            $matriz_datos{$prov_nombre}{$fab} += $entrega->{cantidad};
        }
    }

    my $dot = "digraph MatrizProveedoresFabricantes {\n";
    $dot .= "  charset=\"UTF-8\";\n";
    $dot .= "  node [shape=plaintext];\n";
    $dot .= "  graph [nodesep=0.5, ranksep=0.8];\n\n";
    $dot .= "  matriz [label=<\n";
    $dot .=
"    <TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"4\">\n";
    $dot .= "      <TR>\n";
    $dot .=
"        <TD BGCOLOR=\"#4a1d6d\"><FONT COLOR=\"white\"><B>Proveedor / Fabricante</B></FONT></TD>\n";

    for my $fab (@fabricantes) {
        my $fab_esc = _escapar_html($fab);
        $dot .=
"        <TD BGCOLOR=\"#9b4dff\"><FONT COLOR=\"white\"><B>$fab_esc</B></FONT></TD>\n";
    }
    $dot .= "      </TR>\n";

    for my $prov_nombre ( sort keys %matriz_datos ) {
        my $prov_esc = _escapar_html($prov_nombre);
        $dot .= "      <TR>\n";
        $dot .= "        <TD BGCOLOR=\"#ede9fe\"><B>$prov_esc</B></TD>\n";
        for my $fab (@fabricantes) {
            my $cantidad = $matriz_datos{$prov_nombre}{$fab} // 0;
            if ($cantidad) {
                my $color = _color_por_cantidad($cantidad);
                $dot .= "        <TD BGCOLOR=\"$color\">$cantidad</TD>\n";
            }
            else {
                $dot .= "        <TD BGCOLOR=\"#f3f4f6\">-</TD>\n";
            }
        }
        $dot .= "      </TR>\n";
    }
    $dot .= "    </TABLE>\n";
    $dot .= "  >];\n";
    $dot .= "}\n";

    make_path('reportes');
    my $ruta_dot = 'reportes/matriz_dispersa.dot';
    my $ruta_png = 'reportes/matriz_dispersa.png';
    open my $fh, '>:encoding(UTF-8)', $ruta_dot
      or die "No se pudo escribir $ruta_dot";
    print $fh $dot;
    close $fh;
    system(
"dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>/dev/null"
    );

    return { png => '/reportes/matriz_dispersa.png' };
}

# ------------------------------------------------------------
# Reporte: Árbol de Merkle (hash raíz + integridad + diagrama)
# ------------------------------------------------------------
sub merkle_tree {
    my ($ctx) = @_;

    require gestion_datos::merkle;
    require persistencia::chats;

    # Obtener mensajes del administrador
    my $chats = persistencia::chats::cargar_chats('AdminHospital');
    my @mensajes;
    for my $conv ( values %$chats ) {
        push @mensajes, @$conv;
    }

    if ( !@mensajes ) {
        @mensajes = (
            {
                remitente => 'AdminHospital',
                receptor  => 'COL-10001',
                contenido => 'Hola',
                timestamp => time()
            },
            {
                remitente => 'COL-10001',
                receptor  => 'AdminHospital',
                contenido => 'Hola admin',
                timestamp => time()
            }
        );
    }

    my $merkle     = gestion_datos::merkle->nuevo();
    my $raiz       = $merkle->construir_desde_mensajes( \@mensajes );
    my $verificado = $merkle->verificar_integridad();

    # Generar DOT para el árbol
    my $dot = "digraph MerkleTree {\n";
    $dot .= "  node [shape=box, fontname=Courier];\n";
    $dot .= _gen_merkle_dot( $merkle->{raiz}, 0 );
    $dot .= "}\n";

    make_path('reportes');
    my $ruta_dot = 'reportes/merkle.dot';
    my $ruta_png = 'reportes/merkle.png';
    open my $fh, '>:encoding(UTF-8)', $ruta_dot
      or die "No se pudo escribir $ruta_dot";
    print $fh $dot;
    close $fh;

    system(
"dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>/dev/null"
    );

    return {
        raiz         => $raiz,
        integridad   => $verificado ? 'Válida' : 'Corrupta',
        num_mensajes => scalar(@mensajes),
        png          => '/reportes/merkle.png'
    };
}

# ------------------------------------------------------------
# Funciones auxiliares
# ------------------------------------------------------------
sub _gen_merkle_dot {
    my ( $nodo, $id ) = @_;
    return '' unless $nodo;
    my $hash = substr( $nodo->{hash}, 0, 16 );
    my $dot  = "  node$id [label=\"$hash\"];\n";
    if ( $nodo->{izquierda} ) {
        $dot .= _gen_merkle_dot( $nodo->{izquierda}, $id * 2 + 1 );
        $dot .= "  node$id -> node" . ( $id * 2 + 1 ) . ";\n";
    }
    if ( $nodo->{derecha} ) {
        $dot .= _gen_merkle_dot( $nodo->{derecha}, $id * 2 + 2 );
        $dot .= "  node$id -> node" . ( $id * 2 + 2 ) . ";\n";
    }
    return $dot;
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
    if ( $cantidad < 1000 )  { return "#dc2626"; }
    if ( $cantidad < 5000 )  { return "#d97706"; }
    if ( $cantidad < 20000 ) { return "#eab308"; }
    if ( $cantidad < 50000 ) { return "#84cc16"; }
    return "#10b981";
}

1;
