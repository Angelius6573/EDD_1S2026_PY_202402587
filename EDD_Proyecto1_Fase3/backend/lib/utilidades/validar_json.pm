#!/usr/bin/perl
package utilidades::validar_json;
use strict;
use warnings;
use utf8;
use Encode qw(decode encode);
use Time::Piece;

sub normalizar_utf8 {
    my ($texto) = @_;
    return '' unless defined $texto;
    if ( utf8::is_utf8($texto) || utf8::valid($texto) ) {
        utf8::decode($texto) if !utf8::is_utf8($texto);
        return $texto;
    }
    my $encodings = [ 'UTF-8', 'ISO-8859-1', 'cp1252', 'Latin-1' ];
    foreach my $enc (@$encodings) {
        my $decoded;
        eval { $decoded = decode( $enc, $texto, Encode::FB_CROAK ); };
        return $decoded if !$@ && defined $decoded;
    }
    $texto =~ s/[^\x20-\x7E\xA0-\xFF]//g;
    return $texto;
}

sub limpiar_campo {
    my ( $valor, $campo, $tipo ) = @_;
    $tipo //= '';
    if ( !defined $valor ) {
        return undef;
    }
    if ( ref($valor) eq '' ) {
        $valor =~ s/^\s+|\s+$//g;
        if ( $valor eq '' ) {
            return undef;
        }
    }
    if ( $tipo eq 'cantidad' || $tipo eq 'nivel_minimo' ) {
        if ( $valor !~ /^\d+$/ ) {
            return undef;
        }
        return $valor + 0;
    }
    if ( $tipo eq 'precio' ) {
        if ( $valor !~ /^\d+(?:\.\d+)?$/ ) {
            return undef;
        }
        return $valor + 0;
    }
    if ( $tipo eq 'fecha' ) {
        my $sep;
        if    ( $valor =~ /^\d{4}-\d{2}-\d{2}$/ )   { $sep = '%Y-%m-%d'; }
        elsif ( $valor =~ /^\d{4}\/\d{2}\/\d{2}$/ ) { $sep = '%Y/%m/%d'; }
        else                                        { return undef; }
        my $fecha;
        eval { $fecha = Time::Piece->strptime( $valor, $sep ); };
        if ( $@ || !defined $fecha ) {
            return undef;
        }
        if ( $fecha->year < 1900 || $fecha->year > 2100 ) {
            return undef;
        }
        return $valor;
    }
    if ( $tipo eq 'codigo' ) {
        if ( $valor !~ /^[A-Z]{3,4}-\d+$/i ) {
            return undef;
        }
        return uc($valor);
    }
    if ( $tipo eq 'tipo_producto' ) {
        my $uc = uc($valor);
        if ( $uc ne 'MEDICAMENTO' && $uc ne 'EQUIPO' && $uc ne 'SUMINISTRO' ) {
            return undef;
        }
        return $uc;
    }
    if ( $tipo eq 'texto' ) {
        if ( $valor eq '' ) {
            return undef;
        }
        return $valor;
    }
    return $valor;
}

sub validar_campos_obligatorios {
    my ( $item, $campos_obligatorios ) = @_;
    my @faltantes;
    foreach my $campo (@$campos_obligatorios) {
        my $valor    = $item->{$campo};
        my $faltante = 0;
        if ( !defined $valor ) {
            $faltante = 1;
        }
        elsif ( ref($valor) eq '' ) {
            $faltante = 1 if $valor eq '';
        }
        elsif ( ref($valor) eq 'ARRAY' ) {
            $faltante = 1 if scalar(@$valor) == 0;
        }
        elsif ( ref($valor) eq 'HASH' ) {
            $faltante = 1 if scalar( keys %$valor ) == 0;
        }
        push @faltantes, $campo if $faltante;
    }
    return @faltantes;
}

1;
