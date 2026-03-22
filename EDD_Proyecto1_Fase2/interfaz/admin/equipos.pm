#!/usr/bin/perl
package interfaz::admin::equipos;
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
    my $bst = $ctx->{bst};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my ( $hfilt, $entry_fab, $btn_filt, $btn_limpiar ) = _construir_filtros();
    my ( $store, $filter,    $view,     $f_fab_ref )   = _construir_tabla($bst);
    my $scroll = _construir_scroll($view);
    my $hbox =
      _construir_botones( $ctx, $store, $filter, $bst, $entry_fab, $btn_filt,
        $btn_limpiar, $f_fab_ref );

    $vbox->pack_start( $hfilt,  FALSE, FALSE, 0 );
    $vbox->pack_start( $hbox,   FALSE, FALSE, 4 );
    $vbox->pack_start( $scroll, TRUE,  TRUE,  0 );

    return $vbox;
}

sub _construir_filtros {
    my $hfilt = Gtk3::Box->new( 'horizontal', 8 );
    my $lf    = Gtk3::Label->new('Filtrar por fabricante:');
    $lf->get_style_context()->add_class('campo-label');

    my $entry_fab = Gtk3::Entry->new();
    $entry_fab->set_placeholder_text('Nombre del fabricante...');
    $entry_fab->set_hexpand(TRUE);

    my $btn_filt =
      interfaz::admin::common::boton( 'Aplicar filtro', 'boton-secundario' );
    my $btn_limpiar =
      interfaz::admin::common::boton( 'Limpiar', 'boton-secundario' );

    $hfilt->pack_start( $lf,          FALSE, FALSE, 0 );
    $hfilt->pack_start( $entry_fab,   TRUE,  TRUE,  0 );
    $hfilt->pack_start( $btn_filt,    FALSE, FALSE, 0 );
    $hfilt->pack_start( $btn_limpiar, FALSE, FALSE, 0 );

    return ( $hfilt, $entry_fab, $btn_filt, $btn_limpiar );
}

sub _construir_tabla {
    my ($bst) = @_;

    my $store = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String', 'Glib::String'
    );
    _recargar_tabla( $store, $bst );

    my $filter = Gtk3::TreeModelFilter->new( $store, undef );
    my $f_fab  = '';

    $filter->set_visible_func(
        sub {
            my ( $model, $iter ) = @_;
            return TRUE if !$f_fab;
            my $fab = $model->get_value( $iter, 2 ) // '';
            return index( lc($fab), lc($f_fab) ) != -1;
        }
    );

    my $view = interfaz::admin::common::crear_vista_generica(
        $filter,
        [
            'Codigo',   'Nombre', 'Fabricante', 'Precio',
            'Cantidad', 'Fecha Ingreso'
        ]
    );

    return ( $store, $filter, $view, \$f_fab );
}

sub _construir_scroll {
    my ($view) = @_;
    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'automatic', 'automatic' );
    $scroll->set_vexpand(TRUE);
    $scroll->add($view);
    return $scroll;
}

sub _construir_botones {
    my ( $ctx, $store, $filter, $bst, $entry_fab, $btn_filt, $btn_limpiar,
        $f_fab_ref )
      = @_;

    my $hbox = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_nuevo =
      interfaz::admin::common::boton( 'Registrar Equipo', 'boton-primario' );
    my $btn_buscar =
      interfaz::admin::common::boton( 'Buscar', 'boton-secundario' );
    my $btn_eliminar =
      interfaz::admin::common::boton( 'Eliminar', 'boton-peligro' );
    my $btn_reload =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );

    $hbox->pack_start( $_, FALSE, FALSE, 0 )
      for ( $btn_nuevo, $btn_buscar, $btn_eliminar, $btn_reload );

    if ( $btn_filt && $entry_fab && $f_fab_ref ) {
        $btn_filt->signal_connect(
            clicked => sub {
                $$f_fab_ref = $entry_fab->get_text();
                $filter->refilter();
            }
        );

        $btn_limpiar->signal_connect(
            clicked => sub {
                $entry_fab->set_text('');
                $$f_fab_ref = '';
                $filter->refilter();
            }
        );
    }

    $btn_nuevo->signal_connect(
        clicked => sub { _dialogo_registrar( $ctx, $store ) } );
    $btn_buscar->signal_connect( clicked => sub { _dialogo_buscar($ctx) } );
    $btn_eliminar->signal_connect(
        clicked => sub {
            my ( $model, $iter ) = $filter->get_selection()->get_selected();
            if ($iter) {
                my $biter = $filter->convert_iter_to_child_iter($iter);
                my $cod   = $store->get_value( $biter, 0 );
                interfaz::admin::common::confirmar_y_ejecutar(
                    "Eliminar equipo $cod?",
                    sub {
                        $bst->eliminar($cod);
                        _guardar_equipos($bst);
                        _recargar_tabla( $store, $bst );
                        $filter->refilter();
                    }
                );
            }
            else {
                interfaz::admin::common::msg_info("Seleccione un equipo.");
            }
        }
    );
    $btn_reload->signal_connect(
        clicked => sub {
            my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio(
                'datos/equipos.json');
            $bst->cargar_desde_array($datos);
            _recargar_tabla( $store, $bst );
            $filter->refilter();
        }
    );

    return $hbox;
}

sub _recargar_tabla {
    my ( $store, $bst ) = @_;
    $store->clear();
    $bst->en_orden(
        sub {
            my ($n) = @_;
            my $iter = $store->append();
            $store->set(
                $iter, 0,
                $n->{codigo}     // '', 1,
                $n->{nombre}     // '', 2,
                $n->{fabricante} // '', 3,
                'Q' . ( $n->{precio_unitario} // 0 ), 4,
                '' .  ( $n->{cantidad}        // 0 ), 5,
                $n->{fecha_ingreso} // ''
            );
        }
    );
}

sub _guardar_equipos {
    my ($bst) = @_;
    utilidades::leer_json::guardar_json( 'datos/equipos.json',
        $bst->a_array_json() );
}

sub _dialogo_registrar {
    my ( $ctx, $store ) = @_;
    my $bst = $ctx->{bst};

    my $dlg = Gtk3::Dialog->new(
        'Registrar Equipo Medico', undef, 'modal',
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
        [ 'Codigo (EQU-XXX)',              'codigo' ],
        [ 'Nombre del Equipo',             'nombre' ],
        [ 'Fabricante',                    'fabricante' ],
        [ 'Precio Unitario (ej: 350.00)',  'precio_unitario' ],
        [ 'Cantidad',                      'cantidad' ],
        [ 'Fecha de Ingreso (AAAA-MM-DD)', 'fecha_ingreso' ],
        [ 'Nivel Minimo',                  'nivel_minimo' ],
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
        elsif ( $bst->buscar( $d{codigo} ) ) {
            interfaz::admin::common::msg_info(
                "El codigo '$d{codigo}' ya existe.");
        }
        else {
            $bst->insertar(%d);
            _guardar_equipos($bst);
            _recargar_tabla( $store, $bst );
            interfaz::admin::common::msg_info("Equipo $d{codigo} registrado.");
        }
    }
    $dlg->destroy();
}

sub _dialogo_buscar {
    my ($ctx) = @_;
    my $bst   = $ctx->{bst};
    my $dlg   = Gtk3::Dialog->new(
        'Buscar Equipo', undef, 'modal',
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
      interfaz::admin::common::campo_entry('Codigo del Equipo (EQU-XXX)');
    my $res = Gtk3::Label->new('');
    $res->set_line_wrap(TRUE);
    $vb->pack_start( $l,   FALSE, FALSE, 0 );
    $vb->pack_start( $e,   FALSE, FALSE, 0 );
    $vb->pack_start( $res, FALSE, FALSE, 4 );
    $area->pack_start( $vb, TRUE, TRUE, 0 );
    $dlg->show_all();

    while (1) {
        last unless $dlg->run() eq 'accept';
        my $cod  = $e->get_text();
        my $nodo = $bst->buscar($cod);
        if ($nodo) {
            my $alerta =
              ( $nodo->{cantidad} < $nodo->{nivel_minimo} )
              ? "\nSTOCK BAJO"
              : '';
            $res->set_text(
                    "Nombre: $nodo->{nombre}\nFabricante: $nodo->{fabricante}\n"
                  . "Precio: Q$nodo->{precio_unitario}\nCantidad: $nodo->{cantidad}\n"
                  . "Ingreso: $nodo->{fecha_ingreso}$alerta" );
        }
        else {
            $res->set_text("Equipo '$cod' no encontrado.");
        }
    }
    $dlg->destroy();
}

1;
