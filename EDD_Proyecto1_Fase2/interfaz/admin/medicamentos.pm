#!/usr/bin/perl
package interfaz::admin::medicamentos;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;
use utilidades::leer_json;

sub crear_tab {
    my ($ctx) = @_;
    my $lista = $ctx->{med};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my $store = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String', 'Glib::String'
    );
    _recargar_tabla( $store, $lista );

    my $view = interfaz::admin::common::crear_vista_generica(
        $store,
        [
            'Codigo',           'Nombre',
            'Principio Activo', 'Laboratorio/Fab.',
            'Cantidad',         'Vencimiento'
        ]
    );

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'automatic', 'automatic' );
    $scroll->set_vexpand(TRUE);
    $scroll->add($view);

    my $hbox       = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_reload = interfaz::admin::common::boton( 'Recargar desde JSON',
        'boton-secundario' );

    $btn_reload->signal_connect(
        clicked => sub {
            my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio(
                'datos/inventario.json');
            $ctx->{med} = gestion_datos::lista_doblemente_enlazada->nuevo();
            for my $d (@$datos) {
                $ctx->{med}->insertar_final($d);
            }
            _recargar_tabla( $store, $ctx->{med} );
        }
    );

    $hbox->pack_start( $btn_reload, FALSE, FALSE, 0 );
    $vbox->pack_start( $hbox,       FALSE, FALSE, 0 );
    $vbox->pack_start( $scroll,     TRUE,  TRUE,  0 );
    return $vbox;
}

sub _recargar_tabla {
    my ( $store, $lista ) = @_;
    $store->clear();
    my $datos = $lista->almacenar_array_simple();
    for my $d (@$datos) {
        my $iter = $store->append();
        $store->set(
            $iter, 0,
            $d->{codigo}           // '', 1,
            $d->{nombre}           // '', 2,
            $d->{principio_activo} // '', 3,
            $d->{laboratorio}      // $d->{fabricante} // '', 4,
            '' . ( $d->{cantidad} // 0 ), 5,
            $d->{fecha_vencimiento} // ''
        );
    }
}

1;
