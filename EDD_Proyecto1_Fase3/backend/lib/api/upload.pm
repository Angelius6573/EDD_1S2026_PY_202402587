#!/usr/bin/perl
package api::upload;
use strict;
use warnings;
use utf8;
use JSON::PP;
use File::Temp qw(tempfile);
use File::Path qw(make_path);
use FindBin;
use lib "$FindBin::Bin/../lib";

use utilidades::carga_masiva_inventario;
use utilidades::carga_masiva_usuarios;
use utilidades::carga_masiva_relaciones;
use persistencia::relaciones;

sub procesar_inventario {
    my ( $c, $ctx ) = @_;

    # Obtener usuario directamente de la sesión de Mojolicious
    my $user = $c->session('user');

    # Depuración: imprimir el usuario para ver qué está pasando
    warn "DEBUG: Usuario en sesión: "
      . ( $user ? $user->{colegio} : 'NINGUNO' );

    unless ( $user && $user->{tipo} && $user->{tipo} eq 'ADMIN' ) {
        return {
            error => 'No autorizado. Se requieren permisos de administrador.' };
    }

    # Obtener archivo subido
    my $upload = $c->req->upload('file');
    unless ($upload) {
        return { error =>
'No se recibió ningún archivo. Por favor seleccione un archivo JSON.'
        };
    }

    # Verificar tipo de archivo
    my $filename = $upload->filename;
    unless ( $filename =~ /\.json$/i ) {
        return { error =>
              'Tipo de archivo inválido. Solo se aceptan archivos .json' };
    }

    # Crear directorio temporal si no existe
    my $temp_dir = 'datos/temp';
    make_path($temp_dir) unless -d $temp_dir;

    # Guardar archivo temporalmente
    my $temp_file = "$temp_dir/upload_inventario_$$.json";
    $upload->move_to($temp_file);

    unless ( -e $temp_file && -s $temp_file ) {
        return { error => 'Error al guardar el archivo temporal.' };
    }

    # Procesar el archivo
    my $resultado =
      utilidades::carga_masiva_inventario::procesar_archivo( $temp_file, $ctx );

    # Limpiar archivo temporal
    unlink $temp_file if -e $temp_file;

    return { success => 1, mensaje => $resultado };
}

sub procesar_usuarios {
    my ( $c, $ctx ) = @_;

    my $user = $c->session('user');
    warn "DEBUG: Usuario en sesión (usuarios): "
      . ( $user ? $user->{colegio} : 'NINGUNO' );

    unless ( $user && $user->{tipo} && $user->{tipo} eq 'ADMIN' ) {
        return {
            error => 'No autorizado. Se requieren permisos de administrador.' };
    }

    my $upload = $c->req->upload('file');
    unless ($upload) {
        return { error =>
'No se recibió ningún archivo. Por favor seleccione un archivo JSON.'
        };
    }

    my $filename = $upload->filename;
    unless ( $filename =~ /\.json$/i ) {
        return { error =>
              'Tipo de archivo inválido. Solo se aceptan archivos .json' };
    }

    my $temp_dir = 'datos/temp';
    make_path($temp_dir) unless -d $temp_dir;

    my $temp_file = "$temp_dir/upload_usuarios_$$.json";
    $upload->move_to($temp_file);

    unless ( -e $temp_file && -s $temp_file ) {
        return { error => 'Error al guardar el archivo temporal.' };
    }

    my $resultado =
      utilidades::carga_masiva_usuarios::procesar_archivo( $temp_file,
        $ctx->{avl} );

    # Reconstruir estructuras después de cargar usuarios
    $ctx->{tabla_hash}->reconstruir_desde_avl( $ctx->{avl} );
    persistencia::relaciones::inicializar_grafo_desde_relaciones( $ctx->{grafo},
        $ctx->{avl} );

    unlink $temp_file if -e $temp_file;

    return { success => 1, mensaje => $resultado };
}

sub procesar_relaciones {
    my ( $c, $ctx ) = @_;
    my $user = $c->session('user');
    return { error => 'No autorizado' }
      unless $user && $user->{tipo} eq 'ADMIN';
    my $upload = $c->req->upload('file')
      or return { error => 'No se recibió archivo' };
    my $temp_file = "datos/temp/relaciones_$$.json";
    $upload->move_to($temp_file);
    my $resultado =
      utilidades::carga_masiva_relaciones::procesar_archivo( $temp_file, $ctx );
    unlink $temp_file if -e $temp_file;
    return { success => 1, mensaje => $resultado };
}

1;
