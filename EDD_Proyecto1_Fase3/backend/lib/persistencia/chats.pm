#!/usr/bin/perl
package persistencia::chats;
use strict;
use warnings;
use utf8;
use File::Path qw(make_path);
use JSON::PP;
use utilidades::lzw;

my $DIR_CHATS = 'datos/chats';

sub _asegurar_directorio {
    my $dir = shift;
    unless ( -d $dir ) {
        make_path($dir);
    }
}

sub _ruta_usuario {
    my ($colegio) = @_;
    return "$DIR_CHATS/$colegio.lzw";
}

sub guardar_chats {
    my ( $colegio, $conversaciones ) = @_;
    _asegurar_directorio($DIR_CHATS);
    my $json  = JSON::PP->new->utf8->canonical;
    my $texto = $json->encode($conversaciones);
    my $ruta  = _ruta_usuario($colegio);
    return utilidades::lzw::comprimir_archivo( \$texto, $ruta );
}

sub cargar_chats {
    my ($colegio) = @_;
    my $ruta = _ruta_usuario($colegio);
    return {} unless -e $ruta;
    my $texto;
    my $ok = utilidades::lzw::descomprimir_archivo( $ruta, \$texto );
    return {} unless $ok;
    my $json = JSON::PP->new->utf8;
    eval { return $json->decode($texto); };

    if ($@) {
        warn "Error al decodificar JSON de chats para $colegio: $@";
        return {};
    }
    return $json->decode($texto);
}

sub agregar_mensaje {
    my ( $colegio, $conversacion, $mensaje ) = @_;
    my $chats = cargar_chats($colegio);
    push @{ $chats->{$conversacion} }, $mensaje;
    guardar_chats( $colegio, $chats );
    return 1;
}

sub obtener_conversacion {
    my ( $colegio, $conversacion ) = @_;
    my $chats = cargar_chats($colegio);
    return $chats->{$conversacion} // [];
}

1;
