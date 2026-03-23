#!/usr/bin/perl
package interfaz::admin::reportes;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;
use reportes::nombre_archivos;
use reportes::avl_dots;
use reportes::bst_dots;
use reportes::btree_dots;
use reportes::matriz_dots;
use reportes::inventario_dots;
use reportes::proveedores_dots;
use interfaz::admin::proveedores_matriz;

sub crear_tab {
    my ($ctx) = @_;

    my $hpaned = Gtk3::Paned->new('horizontal');
    $hpaned->set_position(320);

    my $vbox_izq = Gtk3::Box->new( 'vertical', 10 );
    $vbox_izq->set_margin_start(12);
    $vbox_izq->set_margin_end(8);
    $vbox_izq->set_margin_top(12);
    $vbox_izq->set_margin_bottom(12);

    my $lbl_titulo = Gtk3::Label->new('Reportes Graphviz');
    $lbl_titulo->get_style_context()->add_class('tarjeta-titulo');
    $lbl_titulo->set_halign('start');
    $vbox_izq->pack_start( $lbl_titulo, FALSE, FALSE, 0 );

    my $vbox_der = Gtk3::Box->new( 'vertical', 0 );

    my $frame_visor = Gtk3::Frame->new('Vista Previa del Reporte');
    $frame_visor->set_shadow_type('etched-in');
    $frame_visor->set_vexpand(TRUE);
    $frame_visor->set_hexpand(TRUE);

    my $inner_visor = Gtk3::Box->new( 'vertical', 0 );
    $inner_visor->set_margin_start(4);
    $inner_visor->set_margin_end(4);
    $inner_visor->set_margin_top(4);
    $inner_visor->set_margin_bottom(4);

    my $scrolled = Gtk3::ScrolledWindow->new();
    $scrolled->set_policy( 'automatic', 'automatic' );
    $scrolled->set_vexpand(TRUE);
    $scrolled->set_hexpand(TRUE);

    my $viewport = Gtk3::Viewport->new( undef, undef );
    my $imagen   = Gtk3::Image->new();

    $viewport->add($imagen);
    $scrolled->add($viewport);

    my $lbl_info =
      Gtk3::Label->new('Seleccione un reporte y presione "Generar"');
    $lbl_info->get_style_context()->add_class('valor-label');
    $lbl_info->set_halign('center');
    $lbl_info->set_valign('center');

    $inner_visor->pack_start( $lbl_info, TRUE, TRUE, 0 );
    $inner_visor->pack_start( $scrolled, TRUE, TRUE, 0 );
    $frame_visor->add($inner_visor);
    $vbox_der->pack_start( $frame_visor, TRUE, TRUE, 0 );

    my @reportes = (
        [ 'Arbol AVL — Personal Medico',  sub { _generar_avl($ctx) } ],
        [ 'Arbol BST — Equipos Medicos',  sub { _generar_bst($ctx) } ],
        [ 'Arbol B — Suministros',        sub { _generar_btree($ctx) } ],
        [ 'Matriz Dispersa (Prov x Fab)', sub { _generar_matriz($ctx) } ],
        [ 'Medicamentos (Lista Doble)',   sub { _generar_inventario($ctx) } ],
        [
            'Proveedores (Lista Circ. Doble)',
            sub { _generar_proveedores($ctx) }
        ],
    );

    my $ruta_actual_svg = '';

    my $mostrar_imagen = sub {
        my ($ruta_svg) = @_;
        if ( $ruta_svg && -e $ruta_svg ) {
            eval {
                my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($ruta_svg);
                $imagen->set_from_pixbuf($pixbuf);
                $lbl_info->set_text('');
                $scrolled->show_all();
                $lbl_info->hide();
                $imagen->show();
            };
            if ($@) {
                $lbl_info->set_text(
"Error al cargar imagen: $@\nVerifique que el archivo SVG es valido."
                );
                $lbl_info->show();
                $imagen->hide();
            }
        }
        else {
            $lbl_info->set_text(
"No se pudo generar el reporte.\nVerifique que Graphviz (dot) este instalado."
            );
            $lbl_info->show();
            $imagen->hide();
        }
    };

    for my $r (@reportes) {
        my ( $nombre, $gen_cb ) = @$r;

        my $frame = Gtk3::Frame->new();
        $frame->set_shadow_type('etched-in');
        $frame->set_margin_bottom(6);

        my $hb = Gtk3::Box->new( 'horizontal', 8 );
        $hb->set_margin_start(12);
        $hb->set_margin_end(12);
        $hb->set_margin_top(8);
        $hb->set_margin_bottom(8);

        my $lbl_r = Gtk3::Label->new($nombre);
        $lbl_r->set_halign('start');
        $lbl_r->set_hexpand(TRUE);
        $lbl_r->get_style_context()->add_class('valor-label');

        my $btn_gen =
          interfaz::admin::common::boton( 'Generar', 'boton-primario' );
        $btn_gen->set_size_request( 90, 28 );

        $btn_gen->signal_connect(
            clicked => sub {
                my ( $png, $svg ) = $gen_cb->();
                if ( $svg && -e $svg ) {
                    $ruta_actual_svg = $svg;
                    $mostrar_imagen->($svg);
                }
                else {
                    $lbl_info->set_text(
"No se pudo generar el reporte.\nVerifique que Graphviz (dot) este instalado."
                    );
                    $lbl_info->show();
                    $imagen->hide();
                }
            }
        );

        $hb->pack_start( $lbl_r,   TRUE,  TRUE,  0 );
        $hb->pack_start( $btn_gen, FALSE, FALSE, 0 );
        $frame->add($hb);
        $vbox_izq->pack_start( $frame, FALSE, FALSE, 0 );
    }

    my $frame_ext = Gtk3::Frame->new();
    $frame_ext->set_shadow_type('etched-in');
    $frame_ext->set_margin_top(8);

    my $hb_ext = Gtk3::Box->new( 'horizontal', 8 );
    $hb_ext->set_margin_start(12);
    $hb_ext->set_margin_end(12);
    $hb_ext->set_margin_top(8);
    $hb_ext->set_margin_bottom(8);

    my $lbl_ext = Gtk3::Label->new('Abrir con Inkscape (edicion avanzada)');
    $lbl_ext->set_halign('start');
    $lbl_ext->set_hexpand(TRUE);
    $lbl_ext->get_style_context()->add_class('valor-label');

    my $btn_ext = interfaz::admin::common::boton( 'Abrir', 'boton-secundario' );
    $btn_ext->set_size_request( 90, 28 );

    $btn_ext->signal_connect(
        clicked => sub {
            if ( $ruta_actual_svg && -e $ruta_actual_svg ) {
                my $cmd       = "inkscape '$ruta_actual_svg' &";
                my $resultado = system($cmd);
                if ( $resultado != 0 ) {
                    system("xdg-open '$ruta_actual_svg' &");
                }
            }
            else {
                interfaz::admin::common::msg_info("Genere un reporte primero.");
            }
        }
    );

    $hb_ext->pack_start( $lbl_ext, TRUE,  TRUE,  0 );
    $hb_ext->pack_start( $btn_ext, FALSE, FALSE, 0 );
    $frame_ext->add($hb_ext);
    $vbox_izq->pack_start( $frame_ext, FALSE, FALSE, 0 );

    my $scroll_izq = Gtk3::ScrolledWindow->new();
    $scroll_izq->set_policy( 'never', 'automatic' );
    $scroll_izq->set_size_request( 350, -1 );
    $scroll_izq->add($vbox_izq);

    $hpaned->pack1( $scroll_izq, FALSE, FALSE );
    $hpaned->pack2( $vbox_der, TRUE, TRUE );
    return $hpaned;
}

sub _generar_avl {
    my ($ctx) = @_;
    my ( $dot, $png, $svg ) = reportes::nombre_archivos::nombre( 'AVL', 'avl' );
    reportes::avl_dots::generar_diagrama_avl( $ctx->{avl}, $dot, $png, $svg );
    return ( $png, $svg );
}

sub _generar_bst {
    my ($ctx) = @_;
    my ( $dot, $png, $svg ) = reportes::nombre_archivos::nombre( 'BST', 'bst' );
    reportes::bst_dots::generar_diagrama_bst( $ctx->{bst}, $dot, $png, $svg );
    return ( $png, $svg );
}

sub _generar_btree {
    my ($ctx) = @_;
    my ( $dot, $png, $svg ) =
      reportes::nombre_archivos::nombre( 'BTree', 'btree' );
    reportes::btree_dots::generar_diagrama_btree( $ctx->{btree},
        $dot, $png, $svg );
    return ( $png, $svg );
}

sub _generar_matriz {
    my ($ctx) = @_;
    my $m = interfaz::admin::proveedores_matriz::_construir_matriz($ctx);
    unless ($m) {
        interfaz::admin::common::msg_info(
            "Sin datos en la matriz dispersa.\nCargue inventario primero.");
        return ( undef, undef );
    }
    my ( $dot, $png, $svg ) =
      reportes::nombre_archivos::nombre( 'Matriz', 'matriz' );
    reportes::matriz_dots::generar_diagrama_matriz( $m, $dot, $png, $svg );
    return ( $png, $svg );
}

sub _generar_inventario {
    my ($ctx) = @_;
    my ( $dot, $png, $svg ) =
      reportes::nombre_archivos::nombre( 'Inventario', 'inventario' );
    reportes::inventario_dots::generar_diagrama_inventario( $ctx->{med},
        $dot, $png, $svg );
    return ( $png, $svg );
}

sub _generar_proveedores {
    my ($ctx) = @_;
    my ( $dot, $png, $svg ) =
      reportes::nombre_archivos::nombre( 'Proveedores', 'proveedores' );
    reportes::proveedores_dots::generar_diagrama_proveedores( $ctx->{prov},
        $dot, $png, $svg );
    return ( $png, $svg );
}

1;
