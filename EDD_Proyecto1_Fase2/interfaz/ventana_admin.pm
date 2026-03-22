#!/usr/bin/perl
package interfaz::ventana_admin;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::estilos;
use utilidades::leer_json;
use utilidades::carga_masiva_inventario;
use utilidades::carga_masiva_usuarios;
use gestion_datos::avl;
use gestion_datos::bst;
use gestion_datos::btree_orden4;
use gestion_datos::lista_doblemente_enlazada;
use gestion_datos::lista_circular_doblemente_enlazada;
use gestion_datos::matriz_dispersa;

# Módulos de interfaz por tab
use interfaz::admin::header;
use interfaz::admin::personal_medico;
use interfaz::admin::equipos;
use interfaz::admin::suministros;
use interfaz::admin::medicamentos;
use interfaz::admin::carga_masiva;
use interfaz::admin::proveedores_matriz;
use interfaz::admin::recorridos;
use interfaz::admin::reportes;
use interfaz::admin::solicitudes;

sub mostrar {
    my ( $info_admin, $avl_in, $bst_in, $btree_in, $lista_med_in,
        $lista_prov_in )
      = @_;

    my $avl       = $avl_in   // gestion_datos::avl->nuevo();
    my $bst       = $bst_in   // gestion_datos::bst->nuevo();
    my $btree     = $btree_in // gestion_datos::btree_orden4->nuevo();
    my $lista_med = $lista_med_in
      // gestion_datos::lista_doblemente_enlazada->nuevo();
    my $lista_prov = $lista_prov_in
      // gestion_datos::lista_circular_doblemente_enlazada->nuevo();

    my $win = Gtk3::Window->new('toplevel');
    $win->set_title('EDD MedTrack — Panel de Administrador');
    $win->set_default_size( 1280, 800 );
    $win->set_position('center');
    $win->signal_connect( destroy => sub { Gtk3->main_quit } );

    my %ctx = (
        avl   => $avl,
        bst   => $bst,
        btree => $btree,
        med   => $lista_med,
        prov  => $lista_prov,
        win   => \$win,
    );

    my $vbox   = Gtk3::Box->new( 'vertical', 0 );
    my $header = interfaz::admin::header::construir(undef);

    my $nb = Gtk3::Notebook->new();
    $nb->set_tab_pos('top');

    my @tabs = (
        [
            'Personal Médico',
            sub { interfaz::admin::personal_medico::crear_tab( \%ctx ) }
        ],
        [
            'Equipos (BST)',
            sub { interfaz::admin::equipos::crear_tab( \%ctx ) }
        ],
        [
            'Suministros (Árbol B)',
            sub { interfaz::admin::suministros::crear_tab( \%ctx ) }
        ],
        [
            'Medicamentos',
            sub { interfaz::admin::medicamentos::crear_tab( \%ctx ) }
        ],
        [
            'Carga Masiva',
            sub { interfaz::admin::carga_masiva::crear_tab( \%ctx ) }
        ],
        [
            'Proveedores/Matriz',
            sub { interfaz::admin::proveedores_matriz::crear_tab( \%ctx ) }
        ],
        [
            'Recorridos',
            sub { interfaz::admin::recorridos::crear_tab( \%ctx ) }
        ],
        [ 'Reportes', sub { interfaz::admin::reportes::crear_tab( \%ctx ) } ],
        [
            'Solicitudes y Pedidos',
            sub { interfaz::admin::solicitudes::crear_tab( \%ctx ) }
        ],
    );

    for my $tab (@tabs) {
        my ( $nombre, $cb ) = @$tab;
        $nb->append_page( $cb->(), Gtk3::Label->new($nombre) );
    }

    $vbox->pack_start( $header, FALSE, FALSE, 0 );
    $vbox->pack_start( $nb,     TRUE,  TRUE,  0 );
    $win->add($vbox);
    $win->show_all();
    return $win;
}

1;
