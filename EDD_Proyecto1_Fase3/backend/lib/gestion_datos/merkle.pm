#!/usr/bin/perl
package gestion_datos::merkle;
use strict;
use warnings;
use utf8;
use Digest::SHA qw(sha256_hex);

sub nuevo {
    my ($clase) = @_;
    my $self = {
        raiz  => undef,
        hojas => []
    };
    bless $self, $clase;
    return $self;
}

sub _hash_mensaje {
    my ( $self, $mensaje ) = @_;
    my $texto =
        $mensaje->{remitente}
      . $mensaje->{receptor}
      . $mensaje->{contenido}
      . $mensaje->{timestamp};
    return sha256_hex($texto);
}

sub construir_desde_mensajes {
    my ( $self, $mensajes ) = @_;
    $self->{hojas} = [];
    for my $msg (@$mensajes) {
        my $hash = $self->_hash_mensaje($msg);
        push @{ $self->{hojas} }, { hash => $hash, mensaje => $msg };
    }
    $self->{raiz} = $self->_construir_nivel( $self->{hojas} );
    return $self->{raiz};
}

sub _construir_nivel {
    my ( $self, $nodos ) = @_;
    my @nuevo_nivel;
    for ( my $i = 0 ; $i < scalar(@$nodos) ; $i += 2 ) {
        if ( $i + 1 < scalar(@$nodos) ) {
            my $hash_combinado =
              sha256_hex( $nodos->[$i]{hash} . $nodos->[ $i + 1 ]{hash} );
            push @nuevo_nivel,
              {
                hash      => $hash_combinado,
                izquierda => $nodos->[$i],
                derecha   => $nodos->[ $i + 1 ]
              };
        }
        else {
            push @nuevo_nivel, $nodos->[$i];
        }
    }
    if ( scalar(@nuevo_nivel) == 1 ) {
        return $nuevo_nivel[0];
    }
    else {
        return $self->_construir_nivel( \@nuevo_nivel );
    }
}

sub obtener_raiz {
    my ($self) = @_;
    return $self->{raiz}{hash} if $self->{raiz};
    return undef;
}

sub verificar_integridad {
    my ($self) = @_;
    return 0 unless $self->{raiz};
    my $raiz_calculada = $self->_construir_nivel( $self->{hojas} );
    return ( $raiz_calculada->{hash} eq $self->{raiz}{hash} );
}

sub agregar_mensaje {
    my ( $self, $mensaje ) = @_;
    my $hash = $self->_hash_mensaje($mensaje);
    push @{ $self->{hojas} }, { hash => $hash, mensaje => $mensaje };
    $self->{raiz} = $self->_construir_nivel( $self->{hojas} );
    return $self->{raiz}{hash};
}

1;
