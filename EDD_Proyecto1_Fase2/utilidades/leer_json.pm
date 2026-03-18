#!/usr/bin/perl
package utilidades::leer_json;
use strict;
use warnings;
use JSON::PP;
use Encode qw(decode encode);

sub parsear_json {
    my ($ruta) = @_;
    open my $fh, '<:raw', $ruta
      or die "No se pudo abrir el archivo '$ruta': $!\n";
    local $/;
    my $bytes = <$fh>;
    close $fh;

    # Intentar decodificar como UTF-8, si falla, asumir Latin-1
    my $texto;
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_CROAK ); };
    if ($@) {

        # Si falla UTF-8, intentar con Latin-1
        $texto = decode( 'ISO-8859-1', $bytes );
    }

    my $datos = decode_json($texto);
    return $datos;
}

sub parsear_json_posiblemente_vacio {
    my ($ruta) = @_;

    return [] unless -e $ruta;
    return [] if -z $ruta;

    open my $fh, '<:raw', $ruta or return [];
    local $/;
    my $bytes = <$fh>;
    close $fh;

    return [] unless defined $bytes && $bytes =~ /\S/;

    my $texto;
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_CROAK ); };
    if ($@) {
        $texto = decode( 'ISO-8859-1', $bytes );
    }

    my $datos;
    eval { $datos = decode_json($texto) };
    return [] if $@;

    if ( ref($datos) eq 'ARRAY' ) {
        return $datos;
    }

    for my $clave (qw(usuarios proveedor equipos suministros inventario)) {
        return $datos->{$clave} if ref( $datos->{$clave} ) eq 'ARRAY';
    }

    return [];
}

sub guardar_json {
    my ( $ruta, $datos ) = @_;

    ( my $dir = $ruta ) =~ s|/[^/]+$||;
    if ( $dir && !-d $dir ) {
        require File::Path;
        File::Path::make_path($dir);
    }

    my $json = JSON::PP->new->utf8->pretty->canonical(1);

    open my $fh, '>:encoding(UTF-8)', $ruta
      or die "No se pudo escribir '$ruta': $!\n";
    print $fh $json->encode($datos);
    close $fh;
    return 1;
}

# Función auxiliar para convertir un archivo a UTF-8 si es necesario
sub asegurar_utf8 {
    my ($ruta) = @_;
    return unless -e $ruta;

    open my $fh, '<:raw', $ruta or return;
    local $/;
    my $bytes = <$fh>;
    close $fh;

    my $texto;
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_CROAK ); };
    if ($@) {

        # No es UTF-8, convertir
        $texto = decode( 'ISO-8859-1', $bytes );
        open my $fh2, '>:encoding(UTF-8)', $ruta or return;
        print $fh2 $texto;
        close $fh2;
        return 1;
    }
    return 0;
}

1;
