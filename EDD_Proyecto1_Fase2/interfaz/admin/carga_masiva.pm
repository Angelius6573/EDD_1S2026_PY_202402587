#!/usr/bin/perl
package interfaz::admin::carga_masiva;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;
use utilidades::carga_masiva_inventario;
use utilidades::carga_masiva_usuarios;

sub crear_tab {
    my ($ctx) = @_;

    my $vbox = Gtk3::Box->new( 'vertical', 16 );
    $vbox->set_margin_start(20);
    $vbox->set_margin_end(20);
    $vbox->set_margin_top(20);
    $vbox->set_margin_bottom(20);

    my $titulo = Gtk3::Label->new('Carga Masiva desde Archivo JSON');
    $titulo->get_style_context()->add_class('tarjeta-titulo');
    $titulo->set_halign('start');

    my $sec1 = _seccion_carga(
        '1. Cargar Inventario (Medicamentos, Equipos, Suministros)',
        'Seleccionar JSON de Inventario',
        sub { _cargar_inventario( $ctx, @_ ) }
    );
    my $sec2 = _seccion_carga(
        '2. Cargar Personal Medico (Usuarios Departamentales)',
        'Seleccionar JSON de Usuarios',
        sub { _cargar_usuarios_masivo( $ctx, @_ ) }
    );

    $vbox->pack_start( $titulo, FALSE, FALSE, 0 );
    $vbox->pack_start( $sec1,   FALSE, FALSE, 0 );
    $vbox->pack_start( $sec2,   FALSE, FALSE, 0 );
    return $vbox;
}

sub _seccion_carga {
    my ( $titulo_txt, $btn_txt, $cb ) = @_;
    my $frame = Gtk3::Frame->new($titulo_txt);
    my $vb    = Gtk3::Box->new( 'vertical', 8 );
    $vb->set_margin_start(12);
    $vb->set_margin_end(12);
    $vb->set_margin_top(8);
    $vb->set_margin_bottom(8);

    my $hb    = Gtk3::Box->new( 'horizontal', 8 );
    my $entry = Gtk3::Entry->new();
    $entry->set_editable(FALSE);
    $entry->set_hexpand(TRUE);
    my $btn_sel =
      interfaz::admin::common::boton( "$btn_txt", 'boton-secundario' );
    my $btn_car = interfaz::admin::common::boton( 'Cargar', 'boton-primario' );

    my $tv_log = Gtk3::TextView->new();
    $tv_log->set_editable(FALSE);
    $tv_log->set_monospace(TRUE);
    $tv_log->set_wrap_mode('word');
    my $sc_log = Gtk3::ScrolledWindow->new();
    $sc_log->set_policy( 'automatic', 'automatic' );
    $sc_log->set_min_content_height(80);
    $sc_log->add($tv_log);

    $btn_sel->signal_connect(
        clicked => sub {
            my $dlg = Gtk3::FileChooserDialog->new( 'Seleccionar archivo JSON',
                undef, 'open', '_Cancelar', 'cancel', '_Abrir', 'accept' );
            my $f = Gtk3::FileFilter->new();
            $f->set_name('Archivos JSON');
            $f->add_pattern('*.json');
            $dlg->add_filter($f);
            $entry->set_text( $dlg->get_filename() ) if $dlg->run() eq 'accept';
            $dlg->destroy();
        }
    );

    $btn_car->signal_connect(
        clicked => sub {
            my $ruta = $entry->get_text();
            if ( !$ruta || !-e $ruta ) {
                $tv_log->get_buffer()
                  ->set_text("Error: seleccione un archivo valido.");
                return;
            }
            my $resultado = $cb->($ruta);
            $tv_log->get_buffer()->set_text($resultado);
        }
    );

    $hb->pack_start( $entry,   TRUE,  TRUE,  0 );
    $hb->pack_start( $btn_sel, FALSE, FALSE, 0 );
    $vb->pack_start( $hb,      FALSE, FALSE, 0 );
    $vb->pack_start( $btn_car, FALSE, FALSE, 0 );
    $vb->pack_start( $sc_log,  FALSE, FALSE, 0 );
    $frame->add($vb);
    return $frame;
}

sub _cargar_inventario {
    my ( $ctx, $ruta ) = @_;
    return utilidades::carga_masiva_inventario::procesar_archivo( $ruta, $ctx );
}

sub _cargar_usuarios_masivo {
    my ( $ctx, $ruta ) = @_;
    return utilidades::carga_masiva_usuarios::procesar_archivo( $ruta,
        $ctx->{avl} );
}

1;
