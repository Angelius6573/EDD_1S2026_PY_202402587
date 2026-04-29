#!/usr/bin/perl
package gestion_datos::lista_doblemente_enlazada;
use strict;
use warnings;

package gestion_datos::lista_doblemente_enlazada::nodo;

sub nuevo {
    my ( $clase, $datos ) = @_;
    return bless {
        datos     => $datos,
        siguiente => undef,
        anterior  => undef,
    }, $clase;
}

package gestion_datos::lista_doblemente_enlazada;

sub nuevo {
    my $clase = shift;
    return bless { cabeza => undef, cola => undef }, $clase;
}

sub insertar_final {
    my ( $self, $datos ) = @_;
    my $nuevo = gestion_datos::lista_doblemente_enlazada::nodo->nuevo($datos);
    if ( !defined $self->{cabeza} ) {
        $self->{cabeza} = $nuevo;
        $self->{cola}   = $nuevo;
    }
    else {
        $nuevo->{anterior}         = $self->{cola};
        $self->{cola}->{siguiente} = $nuevo;
        $self->{cola}              = $nuevo;
    }
}

sub imprimir {
    my $self   = shift;
    my $actual = $self->{cabeza};
    while ($actual) {
        print $actual->{datos}, " <-> ";
        $actual = $actual->{siguiente};
    }
    print "NULL\n";
}

sub almacenar_array_simple {
    my $self = shift;
    my @datos;
    my $actual = $self->{cabeza};
    while ($actual) {
        push @datos, $actual->{datos};
        $actual = $actual->{siguiente};
    }
    return \@datos;
}

sub buscar_por_codigo {
    my ( $self, $codigo ) = @_;
    my $actual = $self->{cabeza};
    while ($actual) {
        if ( defined $actual->{datos}->{codigo}
            && $actual->{datos}->{codigo} eq $codigo )
        {
            return $actual->{datos};
        }
        $actual = $actual->{siguiente};
    }
    return undef;
}

sub modificar_cantidad {
    my ( $self, $codigo, $cantidad ) = @_;
    my $actual = $self->{cabeza};
    while ($actual) {
        if ( $actual->{datos}->{codigo} eq $codigo ) {
            $actual->{datos}->{cantidad} += $cantidad;
            return 1;
        }
        $actual = $actual->{siguiente};
    }
    return 0;
}

sub ordenar_por_campo {
    my ( $self, $campo ) = @_;
    return if !$self->{cabeza};
    my $intercambiado;
    do {
        $intercambiado = 0;
        my $actual = $self->{cabeza};
        while ( $actual && $actual->{siguiente} ) {
            if ( $actual->{datos}->{$campo}
                gt $actual->{siguiente}->{datos}->{$campo} )
            {
                my $temp = $actual->{datos};
                $actual->{datos}              = $actual->{siguiente}->{datos};
                $actual->{siguiente}->{datos} = $temp;
                $intercambiado                = 1;
            }
            $actual = $actual->{siguiente};
        }
    } while ($intercambiado);
}

sub eliminar_multi_parametro {
    my ( $self, $parametros ) = @_;
    return 0 unless defined $self->{cabeza};
    my $actual = $self->{cabeza};
    while ($actual) {
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
                if ( $actual == $self->{cabeza} && $actual == $self->{cola} ) {
                    $self->{cabeza} = undef;
                    $self->{cola}   = undef;
                }
                elsif ( $actual == $self->{cabeza} ) {
                    $self->{cabeza} = $actual->{siguiente};
                    $self->{cabeza}->{anterior} = undef if $self->{cabeza};
                }
                elsif ( $actual == $self->{cola} ) {
                    $self->{cola} = $actual->{anterior};
                    $self->{cola}->{siguiente} = undef if $self->{cola};
                }
                else {
                    $actual->{anterior}->{siguiente} = $actual->{siguiente};
                    $actual->{siguiente}->{anterior} = $actual->{anterior};
                }
                return 1;
            }
        }
        $actual = $actual->{siguiente};
    }
    return 0;
}

1;
