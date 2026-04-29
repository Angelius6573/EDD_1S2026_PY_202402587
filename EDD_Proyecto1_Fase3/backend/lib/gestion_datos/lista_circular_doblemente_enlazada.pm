#!/usr/bin/perl
package gestion_datos::lista_circular_doblemente_enlazada;
use strict;
use warnings;

package gestion_datos::lista_circular_doblemente_enlazada::nodo;

sub nuevo {
    my ( $clase, $datos ) = @_;
    return bless {
        datos     => $datos,
        siguiente => undef,
        anterior  => undef,
    }, $clase;
}

package gestion_datos::lista_circular_doblemente_enlazada;

sub nuevo {
    my ($clase) = @_;
    return bless { cabeza => undef }, $clase;
}

sub insertar_final {
    my ( $self, $datos ) = @_;
    my $nuevo_nodo =
      gestion_datos::lista_circular_doblemente_enlazada::nodo->nuevo($datos);

    if ( !$self->{cabeza} ) {
        $nuevo_nodo->{siguiente} = $nuevo_nodo;
        $nuevo_nodo->{anterior}  = $nuevo_nodo;
        $self->{cabeza}          = $nuevo_nodo;
    }
    else {
        my $cola = $self->{cabeza}->{anterior};
        $cola->{siguiente}          = $nuevo_nodo;
        $nuevo_nodo->{anterior}     = $cola;
        $nuevo_nodo->{siguiente}    = $self->{cabeza};
        $self->{cabeza}->{anterior} = $nuevo_nodo;
    }
}

sub almacenar_array_simple {
    my ($self) = @_;
    my @datos;
    return [] unless defined $self->{cabeza};
    my $inicio = $self->{cabeza};
    my $actual = $inicio;
    do {
        push @datos, $actual->{datos};
        $actual = $actual->{siguiente};
    } while ( $actual != $inicio );
    return \@datos;
}

sub cambiar_estado_multi_parametro {
    my ( $self, $parametros, $campo, $nuevo_valor ) = @_;
    return 0 unless defined $self->{cabeza};
    my $actual = $self->{cabeza};
    my $inicio = $actual;
    do {
        if ( ref( $actual->{datos} ) eq 'HASH' ) {
            my $coincide = 1;
            foreach my $clave ( keys %$parametros ) {
                if (   !defined $actual->{datos}->{$clave}
                    || !defined $parametros->{$clave}
                    || $actual->{datos}->{$clave} ne $parametros->{$clave} )
                {
                    $coincide = 0;
                    last;
                }
            }
            if ($coincide) {
                $actual->{datos}->{$campo} = $nuevo_valor;
                return 1;
            }
        }
        $actual = $actual->{siguiente};
    } while ( $actual != $inicio );
    return 0;
}

sub eliminar_multi_parametro {
    my ( $self, $parametros ) = @_;
    return 0 unless defined $self->{cabeza};
    my $actual = $self->{cabeza};
    my $inicio = $actual;
    do {
        if ( ref( $actual->{datos} ) eq 'HASH' ) {
            my $coincide = 1;
            foreach my $clave ( keys %$parametros ) {
                if (   !defined $actual->{datos}->{$clave}
                    || !defined $parametros->{$clave}
                    || $actual->{datos}->{$clave} ne $parametros->{$clave} )
                {
                    $coincide = 0;
                    last;
                }
            }
            if ($coincide) {
                if ( $actual->{siguiente} == $actual ) {
                    $self->{cabeza} = undef;
                    return 1;
                }
                $actual->{anterior}->{siguiente} = $actual->{siguiente};
                $actual->{siguiente}->{anterior} = $actual->{anterior};
                if ( $actual == $self->{cabeza} ) {
                    $self->{cabeza} = $actual->{siguiente};
                }
                return 1;
            }
        }
        $actual = $actual->{siguiente};
    } while ( $actual != $inicio );
    return 0;
}

1;
