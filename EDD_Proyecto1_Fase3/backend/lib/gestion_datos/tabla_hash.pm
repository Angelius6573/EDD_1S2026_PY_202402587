#!/usr/bin/perl
package gestion_datos::tabla_hash;
use strict;
use warnings;
use utf8;

sub nuevo {
    my ($clase) = @_;
    my $self = {
        buckets    => [],
        tamanio    => 5,
        colisiones => 0,
        ocupacion  => 0
    };
    for my $i ( 0 .. $self->{tamanio} - 1 ) {
        $self->{buckets}[$i] = [];
    }
    bless $self, $clase;
    return $self;
}

sub _indice_tipo {
    my ( $self, $tipo ) = @_;
    if ( $tipo eq 'TIPO-01' ) { return 0; }
    if ( $tipo eq 'TIPO-02' ) { return 1; }
    if ( $tipo eq 'TIPO-03' ) { return 2; }
    if ( $tipo eq 'TIPO-04' ) { return 3; }
    if ( $tipo eq 'TIPO-05' ) { return 4; }
    return -1;
}

sub insertar {
    my ( $self, $usuario ) = @_;
    my $tipo = $usuario->{tipo};
    my $idx  = $self->_indice_tipo($tipo);
    return 0 if $idx == -1;
    my $bucket = $self->{buckets}[$idx];
    for my $u (@$bucket) {
        if ( $u->{colegio} eq $usuario->{colegio} ) {
            $u = $usuario;
            return 1;
        }
    }
    push @$bucket, $usuario;
    $self->{ocupacion}++;
    if ( scalar(@$bucket) > 1 ) {
        $self->{colisiones}++;
    }
    return 1;
}

sub eliminar {
    my ( $self, $colegio ) = @_;
    for my $bucket ( @{ $self->{buckets} } ) {
        for my $i ( 0 .. $#$bucket ) {
            if ( $bucket->[$i]{colegio} eq $colegio ) {
                splice @$bucket, $i, 1;
                $self->{ocupacion}--;
                return 1;
            }
        }
    }
    return 0;
}

sub buscar_por_tipo {
    my ( $self, $tipo ) = @_;
    my $idx = $self->_indice_tipo($tipo);
    return [] if $idx == -1;
    return $self->{buckets}[$idx];
}

sub contar_por_tipo {
    my ( $self, $tipo ) = @_;
    my $lista = $self->buscar_por_tipo($tipo);
    return scalar(@$lista);
}

sub obtener_estadisticas {
    my ($self) = @_;
    my %stats;
    for my $i ( 0 .. $self->{tamanio} - 1 ) {
        my $tipo = '';
        if    ( $i == 0 ) { $tipo = 'TIPO-01'; }
        elsif ( $i == 1 ) { $tipo = 'TIPO-02'; }
        elsif ( $i == 2 ) { $tipo = 'TIPO-03'; }
        elsif ( $i == 3 ) { $tipo = 'TIPO-04'; }
        else              { $tipo = 'TIPO-05'; }
        $stats{$tipo} = {
            ocupacion  => scalar( @{ $self->{buckets}[$i] } ),
            colisiones => ( scalar( @{ $self->{buckets}[$i] } ) > 1 ) ? 1 : 0
        };
    }
    $stats{total_ocupacion}  = $self->{ocupacion};
    $stats{total_colisiones} = $self->{colisiones};
    return \%stats;
}

sub limpiar {
    my ($self) = @_;
    for my $bucket ( @{ $self->{buckets} } ) {
        $bucket = [];
    }
    $self->{ocupacion}  = 0;
    $self->{colisiones} = 0;
}

sub reconstruir_desde_avl {
    my ( $self, $avl ) = @_;
    $self->limpiar();
    $avl->en_orden(
        sub {
            my ($nodo) = @_;
            $self->insertar($nodo);
        }
    );
}

1;
