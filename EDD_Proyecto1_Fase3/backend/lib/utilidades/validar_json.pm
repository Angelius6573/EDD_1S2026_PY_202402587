#!/usr/bin/perl
package utilidades::validar_json;
use strict;
use warnings;
use utf8;
use Encode qw(decode encode find_encoding);
use Time::Piece;

# ---------------------------------------------------------------------------
# normalizar_utf8
# Fix #1: el return dentro de eval no retorna de la subrutina.
#         Ahora se captura el valor decodificado fuera del eval y se retorna
#         correctamente solo cuando no hubo error ($@).
# ---------------------------------------------------------------------------
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

        # Retorna correctamente desde la subrutina (no desde el eval)
        return $decoded if !$@ && defined $decoded;
    }

    $texto =~ s/[^\x20-\x7E\xA0-\xFF]//g;
    return $texto;
}

# ---------------------------------------------------------------------------
# limpiar_campo
# Fix #2: eliminada la validación de negativos imposible (el regex ^\d+$
#         ya garantiza que no hay signo negativo).
# Fix #3: $tipo se inicializa a '' con //= para evitar warnings de undef.
# Fix #4: validación de fecha usa Time::Piece para detectar fechas inválidas
#         como 2024-02-30 o 2024-04-31.
# Fix #5: separadores de fecha mezclados ya no se aceptan; se exige un
#         separador uniforme ('-' o '/') mediante dos patrones distintos.
# ---------------------------------------------------------------------------
sub limpiar_campo {
    my ( $valor, $campo, $tipo ) = @_;

    # Fix #3: evita warnings si $tipo llega como undef
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

       # Fix #2: solo se valida el formato; la comprobación < 0 era inalcanzable
        if ( $valor !~ /^\d+$/ ) {
            return undef;
        }
        return $valor + 0;
    }

    if ( $tipo eq 'precio' ) {

        # Fix #2: idem para precio
        if ( $valor !~ /^\d+(?:\.\d+)?$/ ) {
            return undef;
        }
        return $valor + 0;
    }

    if ( $tipo eq 'fecha' ) {

        # Fix #5: separadores uniformes — no se permiten mezclas como 2024-02/30
        my $sep;
        if    ( $valor =~ /^\d{4}-\d{2}-\d{2}$/ )   { $sep = '%Y-%m-%d'; }
        elsif ( $valor =~ /^\d{4}\/\d{2}\/\d{2}$/ ) { $sep = '%Y/%m/%d'; }
        else                                        { return undef; }

        # Fix #4: Time::Piece detecta fechas estructuralmente inválidas
        my $fecha;
        eval { $fecha = Time::Piece->strptime( $valor, $sep ); };
        if ( $@ || !defined $fecha ) {
            return undef;
        }

        # Validación adicional de rango de año
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

# ---------------------------------------------------------------------------
# validar_campos_obligatorios
# Fix #6: ahora también detecta arrayrefs y hashrefs vacíos como faltantes.
# ---------------------------------------------------------------------------
sub validar_campos_obligatorios {
    my ( $item, $campos_obligatorios ) = @_;
    my @faltantes;

    foreach my $campo (@$campos_obligatorios) {
        my $valor = $item->{$campo};

        my $faltante = 0;

        if ( !defined $valor ) {
            $faltante = 1;
        }
        elsif ( ref($valor) eq '' ) {

            # Escalar vacío
            $faltante = 1 if $valor eq '';
        }
        elsif ( ref($valor) eq 'ARRAY' ) {

            # Fix #6: arrayref vacío
            $faltante = 1 if scalar(@$valor) == 0;
        }
        elsif ( ref($valor) eq 'HASH' ) {

            # Fix #6: hashref vacío
            $faltante = 1 if scalar( keys %$valor ) == 0;
        }

        push @faltantes, $campo if $faltante;
    }

    return @faltantes;
}

1;
