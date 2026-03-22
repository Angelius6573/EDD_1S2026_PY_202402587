#!/usr/bin/perl
package interfaz::usuario::suministros;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib  qw(TRUE FALSE);
use POSIX qw(strftime);
use interfaz::usuario::common;

sub crear_tab {
    my ($ctx) = @_;
    my $btree = $ctx->{btree};

    my $vbox = Gtk3::Box->new( 'vertical', 6 );
    $vbox->set_margin_start(10);
    $vbox->set_margin_end(10);
    $vbox->set_margin_top(8);
    $vbox->set_margin_bottom(8);

    my $lbl_t =
      Gtk3::Label->new('Consulta de Disponibilidad — Suministros Medicos');
    $lbl_t->get_style_context()->add_class('tarjeta-titulo');
    $lbl_t->set_halign('start');
    $vbox->pack_start( $lbl_t, FALSE, FALSE, 0 );

    my $lbl_s =
      Gtk3::Label->new('Estructura: Arbol B Orden 4 | Recorrido In-Orden');
    $lbl_s->get_style_context()->add_class('login-subtitulo');
    $lbl_s->set_halign('start');
    $vbox->pack_start( $lbl_s, FALSE, FALSE, 2 );

    my $hb       = Gtk3::Box->new( 'horizontal', 8 );
    my $e_buscar = Gtk3::Entry->new();
    $e_buscar->set_placeholder_text(
        'Codigo (ej: SUM-001) o nombre del suministro...');
    $e_buscar->set_hexpand(TRUE);
    my $btn_buscar =
      interfaz::usuario::common::boton( 'Buscar', 'boton-secundario' );
    my $btn_todos =
      interfaz::usuario::common::boton( 'Ver Todos', 'boton-primario' );
    $hb->pack_start( $e_buscar,   TRUE,  TRUE,  0 );
    $hb->pack_start( $btn_buscar, FALSE, FALSE, 0 );
    $hb->pack_start( $btn_todos,  FALSE, FALSE, 0 );
    $vbox->pack_start( $hb, FALSE, FALSE, 0 );

    my $lbl_alerta = Gtk3::Label->new('');
    $lbl_alerta->get_style_context()->add_class('alerta-stock');
    $lbl_alerta->set_halign('start');
    $vbox->pack_start( $lbl_alerta, FALSE, FALSE, 2 );

    my $store = Gtk3::ListStore->new( ('Glib::String') x 8 );
    my $view  = interfaz::usuario::common::treeview_generico(
        $store,
        [
            'Codigo', 'Nombre',    'Fabricante',  'Precio Q',
            'Stock',  'Niv. Min.', 'Vencimiento', 'Estado'
        ],
        7
    );
    my $sc = Gtk3::ScrolledWindow->new();
    $sc->set_policy( 'automatic', 'automatic' );
    $sc->set_min_content_height(255);
    $sc->add($view);
    $vbox->pack_start( $sc, TRUE, TRUE, 0 );

    my $frame   = Gtk3::Frame->new('Detalle del Suministro');
    my $lbl_det = Gtk3::Label->new(
        'Selecciona un suministro o busca por codigo para ver su informacion.');
    $lbl_det->set_line_wrap(TRUE);
    $lbl_det->get_style_context()->add_class('valor-label');
    $lbl_det->set_margin_start(8);
    $lbl_det->set_margin_end(8);
    $lbl_det->set_margin_top(6);
    $lbl_det->set_margin_bottom(6);
    $lbl_det->set_halign('start');
    $frame->add($lbl_det);
    $vbox->pack_start( $frame, FALSE, FALSE, 0 );

    my $recargar = sub {
        my ($filtro) = @_;
        _load_store( $store, $btree, $filtro, $lbl_alerta, $lbl_det );
    };
    $recargar->('');

    my $do_buscar = sub {
        my $q = $e_buscar->get_text();
        return $recargar->('') unless $q;
        my $dato = $btree->buscar($q);
        if ( defined $dato ) {
            _detalle( $lbl_det, $dato );
            _load_store( $store, $btree, $q, $lbl_alerta, undef );
        }
        else {
            _load_store( $store, $btree, $q, $lbl_alerta, $lbl_det );
        }
    };

    $btn_buscar->signal_connect( clicked => $do_buscar );
    $e_buscar->signal_connect( activate => $do_buscar );
    $btn_todos->signal_connect(
        clicked => sub { $e_buscar->set_text(''); $recargar->('') } );

    $view->get_selection()->signal_connect(
        'changed' => sub {
            my ($sel) = @_;
            my ( $model, $iter ) = $sel->get_selected();
            return unless defined $iter;
            my $cod  = $model->get_value( $iter, 0 );
            my $dato = $btree->buscar($cod);
            _detalle( $lbl_det, $dato ) if defined $dato;
        }
    );

    return ( $vbox, $recargar );
}

sub _load_store {
    my ( $store, $btree, $filtro, $lbl_alerta, $lbl_det ) = @_;
    $store->clear();
    my ( $criticos, $venc_pronto ) = ( 0, 0 );
    my $hoy      = interfaz::usuario::common::fecha_hoy();
    my $lim_venc = interfaz::usuario::common::fecha_limite_vencimiento();

    $btree->en_orden(
        sub {
            my ($d) = @_;
            if ( $filtro && $filtro ne '' ) {
                return
                  unless ( ( $d->{codigo} // '' ) =~ /\Q$filtro\E/i )
                  || ( ( $d->{nombre} // '' ) =~ /\Q$filtro\E/i );
            }
            my $cant   = $d->{cantidad}          // 0;
            my $min    = $d->{nivel_minimo}      // 0;
            my $venc   = $d->{fecha_vencimiento} // '';
            my $estado = 'OK';

            if ( $cant < $min ) {
                $estado = 'BAJO STOCK';
                $criticos++;
            }
            elsif ( $venc ne '' && $venc ge $hoy && $venc le $lim_venc ) {
                $estado = 'VENCE PRONTO';
                $venc_pronto++;
            }

            my $iter = $store->append();
            $store->set(
                $iter, 0,
                $d->{codigo}     // '', 1,
                $d->{nombre}     // '', 2,
                $d->{fabricante} // '', 3,
                'Q' . ( $d->{precio_unitario} // '0.00' ), 4,
                "$cant",                                   5,
                "$min",                                    6,
                $venc,                                     7,
                $estado
            );
        }
    );

    if ($lbl_alerta) {
        my @msgs;
        push @msgs, "$criticos suministro(s) con STOCK BAJO" if $criticos;
        push @msgs, "$venc_pronto suministro(s) proximo(s) a vencer"
          if $venc_pronto;
        $lbl_alerta->set_text( @msgs ? 'ALERTA: ' . join( ' | ', @msgs ) : '' );
    }
    $lbl_det->set_text(
        'Selecciona un suministro o busca por codigo para ver su informacion.')
      if $lbl_det;
}

sub _detalle {
    my ( $lbl, $d ) = @_;
    my $cant = $d->{cantidad}     // 0;
    my $min  = $d->{nivel_minimo} // 0;
    my $s =
      ( $cant < $min )
      ? "ALERTA - STOCK BAJO: $cant uds. (minimo: $min)"
      : "Stock OK: $cant uds. (minimo: $min)";
    $lbl->set_text( "Codigo:            "
          . ( $d->{codigo} // '' ) . "\n"
          . "Nombre:            "
          . ( $d->{nombre} // '' ) . "\n"
          . "Fabricante:        "
          . ( $d->{fabricante} // '' ) . "\n"
          . "Precio unitario:   Q"
          . ( $d->{precio_unitario} // '0.00' ) . "\n"
          . "Stock:             $s\n"
          . "Fecha vencimiento: "
          . ( $d->{fecha_vencimiento} // 'No aplica' ) );
}

1;
