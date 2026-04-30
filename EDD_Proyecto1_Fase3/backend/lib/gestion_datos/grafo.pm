#!/usr/bin/perl
package gestion_datos::grafo;
use strict;
use warnings;
use utf8;

sub nuevo {
    my ($clase) = @_;
    my $self = {
        nodos      => {},    # clave: colegio, valor: hash de atributos del nodo
        aristas    => {},    # clave: "colegio_a|colegio_b", valor: 1
        adyacencia => {}     # clave: colegio, valor: hash de vecinos
    };
    bless $self, $clase;
    return $self;
}

sub agregar_nodo {
    my ( $self, $colegio, $nombre, $departamento, $tipo, $especialidad ) = @_;
    $self->{nodos}{$colegio} = {
        nombre       => $nombre,
        departamento => $departamento // 'SIN-DEP',
        tipo         => $tipo,
        especialidad => $especialidad // ''
    };
    $self->{adyacencia}{$colegio} //= {};
}

sub existe_nodo {
    my ( $self, $colegio ) = @_;
    return exists $self->{nodos}{$colegio};
}

sub obtener_nodo {
    my ( $self, $colegio ) = @_;
    return $self->{nodos}{$colegio};
}

sub actualizar_departamento {
    my ( $self, $colegio, $nuevo_departamento ) = @_;
    if ( exists $self->{nodos}{$colegio} ) {
        $self->{nodos}{$colegio}{departamento} = $nuevo_departamento;
        return 1;
    }
    return 0;
}

sub agregar_arista {
    my ( $self, $colegio_a, $colegio_b ) = @_;
    return 0 if ( $colegio_a eq $colegio_b );
    my $key =
      ( $colegio_a lt $colegio_b )
      ? "$colegio_a|$colegio_b"
      : "$colegio_b|$colegio_a";
    $self->{aristas}{$key}                      = 1;
    $self->{adyacencia}{$colegio_a}{$colegio_b} = 1;
    $self->{adyacencia}{$colegio_b}{$colegio_a} = 1;
    return 1;
}

sub eliminar_arista {
    my ( $self, $colegio_a, $colegio_b ) = @_;
    my $key =
      ( $colegio_a lt $colegio_b )
      ? "$colegio_a|$colegio_b"
      : "$colegio_b|$colegio_a";
    delete $self->{aristas}{$key};
    delete $self->{adyacencia}{$colegio_a}{$colegio_b};
    delete $self->{adyacencia}{$colegio_b}{$colegio_a};
    return 1;
}

sub son_vecinos {
    my ( $self, $colegio_a, $colegio_b ) = @_;
    return exists $self->{adyacencia}{$colegio_a}{$colegio_b};
}

sub obtener_vecinos {
    my ( $self, $colegio ) = @_;
    my $vecinos = $self->{adyacencia}{$colegio} // {};
    return [ keys %$vecinos ];
}

sub bfs_dos_saltos {
    my ( $self, $origen, $max_distancia ) = @_;
    $max_distancia //= 2;
    my %visitado;
    my %distancia;
    my @cola = ($origen);
    $visitado{$origen}  = 1;
    $distancia{$origen} = 0;
    my $resultados = [];

    while (@cola) {
        my $actual      = shift @cola;
        my $dist_actual = $distancia{$actual};
        if ( $dist_actual >= $max_distancia ) {
            next;
        }
        my $vecinos = $self->obtener_vecinos($actual);
        for my $vec (@$vecinos) {
            unless ( $visitado{$vec} ) {
                $visitado{$vec}  = 1;
                $distancia{$vec} = $dist_actual + 1;
                push @cola, $vec;
                if ( $dist_actual + 1 == $max_distancia ) {
                    push @$resultados, $vec;
                }
            }
        }
    }
    return $resultados;
}

sub sugerencias_bfs {
    my ( $self, $colegio ) = @_;
    my $vecinos_directos = $self->obtener_vecinos($colegio);
    my %vecinos_map;
    $vecinos_map{$_} = 1 for @$vecinos_directos;
    my %sugerencias;
    for my $vecino (@$vecinos_directos) {
        my $vecinos_del_vecino = $self->obtener_vecinos($vecino);
        for my $candidato (@$vecinos_del_vecino) {
            next if $candidato eq $colegio;
            next if $vecinos_map{$candidato};
            $sugerencias{$candidato}++;
        }
    }
    my @ordenadas =
      sort { $sugerencias{$b} <=> $sugerencias{$a} } keys %sugerencias;
    return \@ordenadas;
}

sub todos_los_nodos {
    my ($self) = @_;
    return [ keys %{ $self->{nodos} } ];
}

sub obtener_aristas {
    my ($self) = @_;
    my @aristas;
    for my $key ( keys %{ $self->{aristas} } ) {
        my ( $a, $b ) = split /\|/, $key;
        push @aristas, [ $a, $b ];
    }
    return \@aristas;
}

sub cargar_desde_vector {
    my ( $self, $nodos_ref, $aristas_ref ) = @_;
    for my $n (@$nodos_ref) {
        $self->agregar_nodo(
            $n->{colegio}, $n->{nombre}, $n->{departamento},
            $n->{tipo},    $n->{especialidad}
        );
    }
    for my $ar (@$aristas_ref) {
        $self->agregar_arista( $ar->[0], $ar->[1] );
    }
}

1;
