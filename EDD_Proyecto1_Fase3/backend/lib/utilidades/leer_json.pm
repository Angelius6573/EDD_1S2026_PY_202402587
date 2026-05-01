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

    if ($@) {
        warn "Error decodificando JSON en $ruta: $@";
        return [];
    }

    # Caso 1: array directo
    if ( ref($datos) eq 'ARRAY' ) {
        return $datos;
    }

    # Caso 2: hash con clave "usuarios"
    if (   ref($datos) eq 'HASH'
        && exists $datos->{usuarios}
        && ref( $datos->{usuarios} ) eq 'ARRAY' )
    {
        return $datos->{usuarios};
    }

    # Caso 3: estructura de proveedor (para inventario)
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

    # Otras claves
    for my $clave (qw(equipos suministros inventario)) {
        return $datos->{$clave} if ref( $datos->{$clave} ) eq 'ARRAY';
    }
    warn "No se pudo interpretar el archivo $ruta como array conocido";
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

    # Intentar como UTF-8 estricto
    eval { $texto = decode( 'UTF-8', $bytes, Encode::FB_CROAK ); };
    if ($@) {

        # Fallback: intentar como ISO-8859-1 (Latin1)
        eval { $texto = decode( 'ISO-8859-1', $bytes, Encode::FB_CROAK ); };
        if ($@) {

            # Último recurso: eliminar caracteres no ASCII
            $bytes =~ s/[^\x20-\x7E]//g;
            $texto = decode( 'UTF-8', $bytes, Encode::FB_DEFAULT );
        }
    }
    return $texto;
}

1;
