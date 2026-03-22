#!/usr/bin/perl
package interfaz::admin::proveedores_matriz;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;
use gestion_datos::matriz_dispersa;

sub crear_tab {
    my ($ctx) = @_;

    my $vbox = Gtk3::Box->new( 'vertical', 10 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my $lbl = Gtk3::Label->new('Matriz Dispersa: Proveedores x Fabricantes');
    $lbl->get_style_context()->add_class('tarjeta-titulo');
    $lbl->set_halign('start');

    my $texto = Gtk3::TextView->new();
    $texto->set_editable(FALSE);
    $texto->set_cursor_visible(FALSE);
    $texto->set_monospace(TRUE);

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'automatic', 'automatic' );
    $scroll->set_vexpand(TRUE);
    $scroll->add($texto);

    my $btn = interfaz::admin::common::boton( 'Mostrar Matriz Actual',
        'boton-primario' );
    $btn->signal_connect(
        clicked => sub {
            my $matriz = _construir_matriz($ctx);
            my $buf    = $texto->get_buffer();
            if ($matriz) {
                $buf->set_text( _texto_matriz($matriz) );
            }
            else {
                $buf->set_text(
                        "No hay datos de proveedores/fabricantes registrados.\n"
                      . "Use la Carga Masiva de inventario para registrar proveedores."
                );
            }
        }
    );

    $vbox->pack_start( $lbl,    FALSE, FALSE, 0 );
    $vbox->pack_start( $btn,    FALSE, FALSE, 0 );
    $vbox->pack_start( $scroll, TRUE,  TRUE,  0 );
    return $vbox;
}

sub _construir_matriz {
    my ($ctx) = @_;
    my $prov_arr = $ctx->{prov}->almacenar_array_simple();
    return undef unless @$prov_arr;

    my %fab_set;
    for my $p (@$prov_arr) {
        for my $e ( @{ $p->{entregas} // [] } ) {
            my $fab = $e->{fabricante} // 'N/A';
            $fab_set{$fab}++ if $fab;
        }
    }
    return undef unless %fab_set;

    my @fabs = sort keys %fab_set;
    my @noms = map { $_->{nombre} // 'Proveedor' } @$prov_arr;

    my $m = gestion_datos::matriz_dispersa->nuevo( scalar @noms, scalar @fabs );
    $m->nombre_filas(@noms);
    $m->nombre_columnas(@fabs);

    for my $i ( 0 .. $#$prov_arr ) {
        for my $e ( @{ $prov_arr->[$i]{entregas} // [] } ) {
            my $fab = $e->{fabricante} // 'N/A';
            my $j   = _idx( $fab, \@fabs );
            next unless defined $j;
            my $actual = $m->obtener( $i, $j );
            my $nueva_cant =
              ( $actual->{cantidad} // 0 ) + ( $e->{cantidad} // 0 );
            $m->insertar( $i, $j,
                $actual->{precio} // $e->{precio_unitario} // 0,
                $nueva_cant, 0 );
        }
    }
    return $m;
}

sub _idx {
    my ( $val, $arr ) = @_;
    for my $i ( 0 .. $#$arr ) { return $i if $arr->[$i] eq $val }
    return undef;
}

sub _texto_matriz {
    my ($m) = @_;
    my ( $nf, $nc ) = $m->obtener_dimensiones();
    my $fabs  = $m->{nombres_columnas} // [];
    my $proms = $m->{nombres_filas}    // [];

    my $sep = 22 + ( $nc * 18 );
    my $txt = sprintf( "%-20s", "Proveedor \\ Fab." );
    for my $j ( 0 .. $nc - 1 ) {
        $txt .= sprintf( " | %-15s", substr( $fabs->[$j] // '', 0, 15 ) );
    }
    $txt .= "\n" . "-" x $sep . "\n";

    for my $i ( 0 .. $nf - 1 ) {
        $txt .= sprintf( "%-20s", substr( $proms->[$i] // '', 0, 20 ) );
        for my $j ( 0 .. $nc - 1 ) {
            my $d = $m->obtener( $i, $j );
            if ( ( $d->{cantidad} // 0 ) > 0 ) {
                $txt .= sprintf( " | %-15s", "$d->{cantidad} uds." );
            }
            else {
                $txt .= sprintf( " | %-15s", "-" );
            }
        }
        $txt .= "\n";
    }
    return $txt;
}

1;
