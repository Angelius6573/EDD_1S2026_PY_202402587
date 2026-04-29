#!/usr/bin/perl
package utilidades::leer_json;
use strict;
use warnings;
use JSON::PP;
use Encode qw(decode);

sub parsear_json {
    my ($ruta) = @_;
    open my $fh, '<:raw', $ruta
      or die "No se pudo abrir el archivo '$ruta': $!\n";
    local $/;
    my $bytes = <$fh>;
    close $fh;
    my $texto = _decodificar_utf8($bytes);
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
    my $texto = _decodificar_utf8($bytes);
    my $datos;
    eval { $datos = decode_json($texto) };
    return [] if $@;

    if ( ref($datos) eq 'ARRAY' ) {
        return $datos;
    }
    if ( ref($datos) eq 'HASH' && ref( $datos->{proveedor} ) eq 'ARRAY' ) {
        my @medicamentos;
        for my $prov ( @{ $datos->{proveedor} } ) {
            for my $item ( @{ $prov->{entrega} // [] } ) {
                if ( $item->{tipo} eq 'MEDICAMENTO' ) {
                    push @medicamentos, $item;
                }
            }
        }
        return \@medicamentos;
    }
    for my $clave (qw(usuarios equipos suministros inventario)) {
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

sub _decodificar_utf8 {
    my ($bytes) = @_;
    if ( $bytes =~ /^\xEF\xBB\xBF/ ) {
        substr( $bytes, 0, 3 ) = '';
    }
    my $texto;
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_CROAK ); };
    if ($@) {
        eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT ); };
        if ($@) {
            $bytes =~ s/[^\x09\x0A\x0D\x20-\x7E\xA0-\xFF]//g;
            $texto = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
        }
    }
    return $texto;
}

1;
