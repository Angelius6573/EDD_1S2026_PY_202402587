#!/usr/bin/perl
package interfaz::usuario::medicamentos;
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
    my $lista = $ctx->{med};

    my $vbox = Gtk3::Box->new( 'vertical', 6 );
    $vbox->set_margin_start(10);
    $vbox->set_margin_end(10);
    $vbox->set_margin_top(8);
    $vbox->set_margin_bottom(8);

    my $lbl_t = Gtk3::Label->new('Consulta de Disponibilidad — Medicamentos');
    $lbl_t->get_style_context()->add_class('tarjeta-titulo');
    $lbl_t->set_halign('start');
    $vbox->pack_start( $lbl_t, FALSE, FALSE, 0 );

    my $lbl_s = Gtk3::Label->new(
        'Estructura: Lista Doblemente Enlazada | Busqueda por codigo o nombre');
    $lbl_s->get_style_context()->add_class('login-subtitulo');
    $lbl_s->set_halign('start');
    $vbox->pack_start( $lbl_s, FALSE, FALSE, 2 );

    my $hb       = Gtk3::Box->new( 'horizontal', 8 );
    my $e_buscar = Gtk3::Entry->new();
    $e_buscar->set_placeholder_text('Codigo (ej: MED-001) o nombre...');
    $e_buscar->set_hexpand(TRUE);
    my $btn_buscar = interfaz::usuario::common::boton( 'Buscar por Codigo',
        'boton-secundario' );
    my $btn_todos =
      interfaz::usuario::common::boton( 'Ver Todos', 'boton-primario' );
    $hb->pack_start( $e_buscar,   TRUE,  TRUE,  0 );
    $hb->pack_start( $btn_buscar, FALSE, FALSE, 0 );
    $hb->pack_start( $btn_todos,  FALSE, FALSE, 0 );
    $vbox->pack_start( $hb, FALSE, FALSE, 0 );

    my $lbl_alerta = Gtk3::Label->new('');
    $lbl_alerta->get_style_context()->add_class('alerta-stock');
    $lbl_alerta->set_line_wrap(TRUE);
    $lbl_alerta->set_halign('start');
    $vbox->pack_start( $lbl_alerta, FALSE, FALSE, 2 );

    my $store = Gtk3::ListStore->new( ('Glib::String') x 8 );
    my $view  = _treeview_med($store);
    my $sc    = Gtk3::ScrolledWindow->new();
    $sc->set_policy( 'automatic', 'automatic' );
    $sc->set_min_content_height(270);
    $sc->add($view);
    $vbox->pack_start( $sc, TRUE, TRUE, 0 );

    my $frame   = Gtk3::Frame->new('Detalle del Medicamento');
    my $lbl_det = Gtk3::Label->new(
        'Selecciona un medicamento para ver su informacion completa.');
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
        _load_store( $store, $lista, $filtro, $lbl_alerta, $lbl_det );
    };
    $recargar->('');

    $btn_buscar->signal_connect(
        clicked => sub { $recargar->( $e_buscar->get_text() ) } );
    $e_buscar->signal_connect(
        activate => sub { $recargar->( $e_buscar->get_text() ) } );
    $btn_todos->signal_connect(
        clicked => sub { $e_buscar->set_text(''); $recargar->('') } );

    $view->get_selection()->signal_connect(
        'changed' => sub {
            my ($sel) = @_;
            my ( $model, $iter ) = $sel->get_selected();
            return unless defined $iter;
            my $cod  = $model->get_value( $iter, 0 );
            my $dato = $lista->buscar_por_codigo($cod);
            _detalle( $lbl_det, $dato ) if defined $dato;
        }
    );

    return ( $vbox, $recargar );
}

sub _treeview_med {
    my ($store) = @_;
    my $view = Gtk3::TreeView->new($store);
    $view->get_selection()->set_mode('single');
    $view->set_rules_hint(TRUE);
    my @h = (
        'Codigo', 'Nombre',    'Principio Activo', 'Fabricante',
        'Stock',  'Niv. Min.', 'Vencimiento',      'Estado'
    );
    for my $i ( 0 .. $#h ) {
        my $r = Gtk3::CellRendererText->new();
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $h[$i], $r, text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(70);
        if ( $i == 7 ) {
            $col->set_cell_data_func(
                $r,
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, 7 );
                    if ( $e =~ /BAJO/ ) {
                        $r2->set( foreground => '#dc2626' );
                    }
                    elsif ( $e =~ /VENCE/ ) {
                        $r2->set( foreground => '#d97706' );
                    }
                    elsif ( $e =~ /VENC/ ) {
                        $r2->set( foreground => '#b91c1c' );
                    }
                    else {
                        $r2->set( foreground => '#15803d' );
                    }
                }
            );
        }
        $view->append_column($col);
    }
    return $view;
}

sub _load_store {
    my ( $store, $lista, $filtro, $lbl_alerta, $lbl_det ) = @_;
    $store->clear();
    my ( $criticos, $venc_pronto ) = ( 0, 0 );
    my $hoy      = interfaz::usuario::common::fecha_hoy();
    my $lim_venc = interfaz::usuario::common::fecha_limite_vencimiento();
    my $datos    = $lista->almacenar_array_simple();

    for my $d (@$datos) {
        if ( $filtro && $filtro ne '' ) {
            next
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
        if ( $venc ne '' && $venc ge $hoy && $venc le $lim_venc ) {
            $estado = 'VENCE PRONTO';
            $venc_pronto++;
        }
        elsif ( $venc ne '' && $venc lt $hoy ) {
            $estado = 'VENCIDO';
        }

        my $iter = $store->append();
        $store->set(
            $iter, 0,
            $d->{codigo}           // '', 1,
            $d->{nombre}           // '', 2,
            $d->{principio_activo} // '', 3,
            $d->{laboratorio}      // $d->{fabricante} // '', 4,
            "$cant", 5,
            "$min",  6,
            $venc,   7,
            $estado
        );
    }

    if ($lbl_alerta) {
        my @msgs;
        push @msgs, "$criticos medicamento(s) con STOCK BAJO" if $criticos;
        push @msgs, "$venc_pronto medicamento(s) proximo(s) a vencer"
          if $venc_pronto;
        $lbl_alerta->set_text( @msgs ? 'ALERTA: ' . join( ' | ', @msgs ) : '' );
    }
    if ($lbl_det) {
        $lbl_det->set_text(
            'Selecciona un medicamento para ver su informacion completa.');
    }
}

sub _detalle {
    my ( $lbl, $d ) = @_;
    my $cant   = $d->{cantidad}     // 0;
    my $min    = $d->{nivel_minimo} // 0;
    my $hoy    = interfaz::usuario::common::fecha_hoy();
    my $venc   = $d->{fecha_vencimiento} // 'No especificada';
    my $s_venc = '';
    $s_venc = ' (VENCIDO)' if $venc ne 'No especificada' && $venc lt $hoy;

    my $s_stock =
      ( $cant < $min )
      ? "ALERTA - BAJO STOCK: $cant uds. disponibles (minimo: $min)"
      : "Stock OK: $cant uds. disponibles (minimo: $min)";

    $lbl->set_text( "Codigo:           "
          . ( $d->{codigo} // '' ) . "\n"
          . "Nombre:           "
          . ( $d->{nombre} // '' ) . "\n"
          . "Principio Activo: "
          . ( $d->{principio_activo} // '' ) . "\n"
          . "Fabricante:       "
          . ( $d->{laboratorio} // $d->{fabricante} // '' ) . "\n"
          . "Stock:            $s_stock\n"
          . "Vencimiento:      $venc$s_venc\n"
          . "Precio unitario:  Q"
          . ( $d->{precio_unitario} // '0.00' ) );
}

1;
