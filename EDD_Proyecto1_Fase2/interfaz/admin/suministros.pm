#!/usr/bin/perl
package interfaz::admin::suministros;
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
    my $btree = $ctx->{btree};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my $store = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String', 'Glib::String'
    );
    _recargar_tabla( $store, $btree );

    my $view = interfaz::admin::common::crear_vista_generica(
        $store,
        [
            'Codigo',   'Nombre', 'Fabricante', 'Precio',
            'Cantidad', 'Vencimiento'
        ]
    );

    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'automatic', 'automatic' );
    $scroll->set_vexpand(TRUE);
    $scroll->add($view);

    my $hbox      = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_nuevo = interfaz::admin::common::boton( 'Registrar Suministro',
        'boton-primario' );
    my $btn_buscar =
      interfaz::admin::common::boton( 'Buscar', 'boton-secundario' );
    my $btn_eliminar =
      interfaz::admin::common::boton( 'Eliminar', 'boton-peligro' );
    my $btn_reload =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );

    $hbox->pack_start( $_, FALSE, FALSE, 0 )
      for ( $btn_nuevo, $btn_buscar, $btn_eliminar, $btn_reload );

    $btn_nuevo->signal_connect(
        clicked => sub { _dialogo_registrar( $ctx, $store ) } );
    $btn_buscar->signal_connect( clicked => sub { _dialogo_buscar($ctx) } );
    $btn_eliminar->signal_connect(
        clicked => sub {
            my ( $model, $iter ) = $view->get_selection()->get_selected();
            if ($iter) {
                my $cod = $model->get_value( $iter, 0 );
                interfaz::admin::common::confirmar_y_ejecutar(
                    "Eliminar suministro $cod?",
                    sub {
                        $btree->eliminar($cod);
                        _guardar_suministros($btree);
                        _recargar_tabla( $store, $btree );
                    }
                );
            }
            else {
                interfaz::admin::common::msg_info("Seleccione un suministro.");
            }
        }
    );
    $btn_reload->signal_connect(
        clicked => sub {
            my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio(
                'datos/suministros.json');
            $btree->cargar_desde_array($datos);
            _recargar_tabla( $store, $btree );
        }
    );

    $vbox->pack_start( $hbox,   FALSE, FALSE, 0 );
    $vbox->pack_start( $scroll, TRUE,  TRUE,  0 );
    return $vbox;
}

sub _recargar_tabla {
    my ( $store, $btree ) = @_;
    $store->clear();
    $btree->en_orden(
        sub {
            my ($d) = @_;
            return unless defined $d;
            my $iter = $store->append();
            $store->set(
                $iter, 0,
                $d->{codigo}     // '', 1,
                $d->{nombre}     // '', 2,
                $d->{fabricante} // '', 3,
                'Q' . ( $d->{precio_unitario} // 0 ), 4,
                '' .  ( $d->{cantidad}        // 0 ), 5,
                $d->{fecha_vencimiento} // ''
            );
        }
    );
}

sub _guardar_suministros {
    my ($btree) = @_;
    utilidades::leer_json::guardar_json( 'datos/suministros.json',
        $btree->a_array_json() );
}

sub _dialogo_registrar {
    my ( $ctx, $store ) = @_;
    my $btree = $ctx->{btree};
    my $dlg   = Gtk3::Dialog->new(
        'Registrar Suministro', undef, 'modal',
        '_Cancelar' => 'cancel',
        '_Guardar'  => 'accept'
    );
    $dlg->set_default_size( 400, 440 );
    my $area = $dlg->get_content_area();
    my $vb   = Gtk3::Box->new( 'vertical', 8 );
    $vb->set_margin_start(20);
    $vb->set_margin_end(20);
    $vb->set_margin_top(12);

    my @campos = (
        [ 'Codigo (SUM-XXX)',               'codigo' ],
        [ 'Nombre del Suministro',          'nombre' ],
        [ 'Fabricante',                     'fabricante' ],
        [ 'Precio Unitario',                'precio_unitario' ],
        [ 'Cantidad',                       'cantidad' ],
        [ 'Fecha Vencimiento (AAAA-MM-DD)', 'fecha_vencimiento' ],
        [ 'Nivel Minimo',                   'nivel_minimo' ],
    );
    my %entries;

    for my $c (@campos) {
        my ( $txt, $key ) = @$c;
        my ( $e,   $l )   = interfaz::admin::common::campo_entry($txt);
        $entries{$key} = $e;
        $vb->pack_start( $l, FALSE, FALSE, 0 );
        $vb->pack_start( $e, FALSE, FALSE, 0 );
    }
    $area->pack_start( $vb, TRUE, TRUE, 0 );
    $dlg->show_all();

    if ( $dlg->run() eq 'accept' ) {
        my %d = map { $_ => $entries{$_}->get_text() } keys %entries;
        if ( !$d{codigo} || !$d{nombre} ) {
            interfaz::admin::common::msg_info(
                'Codigo y nombre son obligatorios.');
        }
        elsif ( $btree->buscar( $d{codigo} ) ) {
            interfaz::admin::common::msg_info(
                "El codigo '$d{codigo}' ya existe.");
        }
        else {
            $btree->insertar(%d);
            _guardar_suministros($btree);
            _recargar_tabla( $store, $btree );
            interfaz::admin::common::msg_info(
                "Suministro $d{codigo} registrado.");
        }
    }
    $dlg->destroy();
}

sub _dialogo_buscar {
    my ($ctx) = @_;
    my $btree = $ctx->{btree};
    my $dlg   = Gtk3::Dialog->new(
        'Buscar Suministro', undef, 'modal',
        '_Cerrar' => 'close',
        '_Buscar' => 'accept'
    );
    $dlg->set_default_size( 400, 230 );
    my $area = $dlg->get_content_area();
    my $vb   = Gtk3::Box->new( 'vertical', 10 );
    $vb->set_margin_start(20);
    $vb->set_margin_end(20);
    $vb->set_margin_top(12);

    my ( $e, $l ) =
      interfaz::admin::common::campo_entry('Codigo del Suministro (SUM-XXX)');
    my $res = Gtk3::Label->new('');
    $res->set_line_wrap(TRUE);
    $vb->pack_start( $l,   FALSE, FALSE, 0 );
    $vb->pack_start( $e,   FALSE, FALSE, 0 );
    $vb->pack_start( $res, FALSE, FALSE, 4 );
    $area->pack_start( $vb, TRUE, TRUE, 0 );
    $dlg->show_all();

    while (1) {
        last unless $dlg->run() eq 'accept';
        my $cod = $e->get_text();
        my $d   = $btree->buscar($cod);
        if ($d) {
            my $alerta =
              ( $d->{cantidad} < $d->{nivel_minimo} ) ? "\nSTOCK BAJO" : '';
            $res->set_text(
                    "Nombre: $d->{nombre}\nFabricante: $d->{fabricante}\n"
                  . "Precio: Q$d->{precio_unitario}\nCantidad: $d->{cantidad}\n"
                  . "Vence: $d->{fecha_vencimiento}$alerta" );
        }
        else {
            $res->set_text("Suministro '$cod' no encontrado.");
        }
    }
    $dlg->destroy();
}

1;
