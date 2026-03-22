#!/usr/bin/perl
package interfaz::admin::header;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::estilos;

sub construir {
    my ($callback_volver) = @_;

    my $header = Gtk3::Box->new( 'horizontal', 16 );
    interfaz::estilos::agregar_clase( $header, 'barra-titulo' );
    $header->set_margin_start(16);
    $header->set_margin_end(16);
    $header->set_margin_top(8);
    $header->set_margin_bottom(8);

    my $lbl_app  = Gtk3::Label->new('EDD MEDTRACK');
    my $lbl_user = Gtk3::Label->new('Bienvenido, Administrador');
    $lbl_user->get_style_context()->add_class('bienvenida-label');

    my $btn_cerrar_sesion = Gtk3::Button->new('Cerrar Sesion');
    interfaz::estilos::agregar_clase( $btn_cerrar_sesion, 'boton-peligro' );
    $btn_cerrar_sesion->set_size_request( 120, 30 );

    my $spacer_h = Gtk3::Label->new('');
    $header->pack_start( $lbl_app,           FALSE, FALSE, 0 );
    $header->pack_start( $spacer_h,          TRUE,  TRUE,  0 );
    $header->pack_start( $lbl_user,          FALSE, FALSE, 0 );
    $header->pack_start( $btn_cerrar_sesion, FALSE, FALSE, 10 );

    if ($callback_volver) {
        $btn_cerrar_sesion->signal_connect( clicked => $callback_volver );
    }
    else {
        $btn_cerrar_sesion->signal_connect(
            clicked => sub { Gtk3->main_quit } );
    }

    return $header;
}

1;
