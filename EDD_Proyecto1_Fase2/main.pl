#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Encode qw(encode_utf8 decode_utf8);

use FindBin;
use lib $FindBin::Bin;

use Gtk3 '-init';
use Glib qw(TRUE FALSE);

use interfaz::estilos;
use interfaz::login;
use interfaz::ventana_admin;
use interfaz::ventana_usuario;

use gestion_datos::avl;
use gestion_datos::bst;
use gestion_datos::btree_orden4;
use gestion_datos::lista_doblemente_enlazada;
use gestion_datos::lista_circular_doblemente_enlazada;

use utilidades::leer_json;

use constant {
    RUTA_USUARIOS    => 'datos/usuarios.json',
    RUTA_EQUIPOS     => 'datos/equipos.json',
    RUTA_SUMINISTROS => 'datos/suministros.json',
    RUTA_INVENTARIO  => 'datos/inventario.json',
    RUTA_PROVEEDORES => 'datos/proveedores.json',
};

my ( $avl, $bst, $btree, $lista_med, $lista_prov );

sub cargar_estructuras {
    $avl = gestion_datos::avl->nuevo();
    my $usuarios =
      utilidades::leer_json::parsear_json_posiblemente_vacio(RUTA_USUARIOS);
    $avl->cargar_desde_array($usuarios);

    $bst = gestion_datos::bst->nuevo();
    my $equipos =
      utilidades::leer_json::parsear_json_posiblemente_vacio(RUTA_EQUIPOS);
    $bst->cargar_desde_array($equipos);

    $btree = gestion_datos::btree_orden4->nuevo();
    my $suministros =
      utilidades::leer_json::parsear_json_posiblemente_vacio(RUTA_SUMINISTROS);
    $btree->cargar_desde_array($suministros);

    $lista_med = gestion_datos::lista_doblemente_enlazada->nuevo();
    my $inventario =
      utilidades::leer_json::parsear_json_posiblemente_vacio(RUTA_INVENTARIO);
    for my $item (@$inventario) {
        $lista_med->insertar_final($item);
    }

    $lista_prov = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
    my $proveedores =
      utilidades::leer_json::parsear_json_posiblemente_vacio(RUTA_PROVEEDORES);
    for my $prov (@$proveedores) {
        $lista_prov->insertar_final($prov);
    }
}

sub mostrar_login {
    interfaz::login::mostrar( $avl, \&mostrar_admin, \&mostrar_usuario );
    Gtk3->main();
}

sub mostrar_admin {
    my ($info) = @_;
    my $win =
      interfaz::ventana_admin::mostrar( $info, $avl, $bst, $btree, $lista_med,
        $lista_prov, \&mostrar_login );
    Gtk3->main();
}

sub mostrar_usuario {
    my ($info) = @_;
    my $win = interfaz::ventana_usuario::mostrar( $info, $avl, $bst, $btree,
        $lista_med, \&mostrar_login );
    Gtk3->main();
}

interfaz::estilos::aplicar();
cargar_estructuras();
mostrar_login();
