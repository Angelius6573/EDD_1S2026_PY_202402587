#!/usr/bin/perl
package utilidades::lzw;
use strict;
use warnings;
use utf8;

sub comprimir {
    my ($texto) = @_;
    my %diccionario;
    my $tamanio_diccionario = 256;
    for my $i ( 0 .. 255 ) {
        $diccionario{ chr($i) } = $i;
    }
    my $w = '';
    my @resultado;
    my @caracteres = split //, $texto;
    for my $c (@caracteres) {
        my $wc = $w . $c;
        if ( exists $diccionario{$wc} ) {
            $w = $wc;
        }
        else {
            push @resultado, $diccionario{$w};
            $diccionario{$wc} = $tamanio_diccionario++;
            $w = $c;
        }
    }
    if ( $w ne '' ) {
        push @resultado, $diccionario{$w};
    }
    return \@resultado;
}

sub descomprimir {
    my ($codigos_ref) = @_;
    my @codigos = @$codigos_ref;
    my %diccionario;
    my $tamanio_diccionario = 256;
    for my $i ( 0 .. 255 ) {
        $diccionario{$i} = chr($i);
    }
    my $w         = chr( $codigos[0] );
    my $resultado = $w;
    for my $i ( 1 .. $#codigos ) {
        my $k = $codigos[$i];
        my $entrada;
        if ( exists $diccionario{$k} ) {
            $entrada = $diccionario{$k};
        }
        elsif ( $k == $tamanio_diccionario ) {
            $entrada = $w . substr( $w, 0, 1 );
        }
        else {
            next;
        }
        $resultado .= $entrada;
        $diccionario{ $tamanio_diccionario++ } = $w . substr( $entrada, 0, 1 );
        $w = $entrada;
    }
    return $resultado;
}

sub comprimir_archivo {
    my ( $ruta_origen, $ruta_destino ) = @_;
    open my $fh, '<:encoding(UTF-8)', $ruta_origen or return 0;
    local $/;
    my $texto = <$fh>;
    close $fh;
    my $codigos = comprimir($texto);
    my $binario = pack( 'N*', @$codigos );
    open my $out, '>:raw', $ruta_destino or return 0;
    print $out $binario;
    close $out;
    return 1;
}

sub descomprimir_archivo {
    my ( $ruta_origen, $ruta_destino ) = @_;
    open my $fh, '<:raw', $ruta_origen or return 0;
    local $/;
    my $datos = <$fh>;
    close $fh;
    my @codigos = unpack( 'N*', $datos );
    my $texto   = descomprimir( \@codigos );
    open my $out, '>:encoding(UTF-8)', $ruta_destino or return 0;
    print $out $texto;
    close $out;
    return 1;
}

1;
