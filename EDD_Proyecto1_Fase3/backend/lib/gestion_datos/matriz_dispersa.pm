#!/usr/bin/perl
package gestion_datos::matriz_dispersa;
use warnings;
use strict;

sub nuevo {
    my ( $clase, $filas, $columnas ) = @_;
    my $self = {
        filas            => $filas,
        columnas         => $columnas,
        datos            => {},
        nombres_filas    => [],
        nombres_columnas => [],
        cantidad_minima  => []
    };
    bless $self, $clase;
    return $self;
}

sub nombre_filas {
    my ( $self, @nombres ) = @_;
    if ( scalar(@nombres) != $self->{filas} ) {
        die "Numero de nombres no coincide con filas\n";
    }
    $self->{nombres_filas} = \@nombres;
}

sub nombre_columnas {
    my ( $self, @nombres ) = @_;
    if ( scalar(@nombres) != $self->{columnas} ) {
        die "Numero de nombres no coincide con columnas\n";
    }
    $self->{nombres_columnas} = \@nombres;
}

sub insertar {
    my ( $self, $fila, $columna, $precio, $cantidad, $cantidad_minima ) = @_;
    if ( $fila < 0 || $fila >= $self->{filas} ) {
        die "Indice fuera del rango de la fila\n";
    }
    if ( $columna < 0 || $columna >= $self->{columnas} ) {
        die "Indice fuera del rango de la columna\n";
    }
    my $idx = "$fila,$columna";
    if ( $precio == 0 && $cantidad == 0 ) {
        delete $self->{datos}{$idx};
    }
    else {
        $self->{datos}{$idx} = {
            precio          => $precio,
            cantidad        => $cantidad,
            cantidad_minima => $cantidad_minima
        };
    }
}

sub obtener {
    my ( $self, $fila, $columna ) = @_;
    if ( $fila < 0 || $fila >= $self->{filas} ) {
        die "Indice fuera del rango de la fila\n";
    }
    if ( $columna < 0 || $columna >= $self->{columnas} ) {
        die "Indice fuera del rango de la columna\n";
    }
    my $idx = "$fila,$columna";
    return
      exists $self->{datos}{$idx}
      ? $self->{datos}{$idx}
      : { precio => 0, cantidad => 0 };
}

sub obtener_dimensiones {
    my ($self) = @_;
    return ( $self->{filas}, $self->{columnas} );
}

sub obtener_fila {
    my ( $self, $fila ) = @_;
    if ( $fila < 0 || $fila >= $self->{filas} ) {
        die "Indice fuera del rango de la fila\n";
    }
    my @fila_datos;
    for my $columna ( 0 .. $self->{columnas} - 1 ) {
        push @fila_datos, $self->obtener( $fila, $columna );
    }
    return @fila_datos;
}

sub obtener_columna {
    my ( $self, $columna ) = @_;
    if ( $columna < 0 || $columna >= $self->{columnas} ) {
        die "Indice fuera del rango de la columna\n";
    }
    my @columna_datos;
    for my $fila ( 0 .. $self->{filas} - 1 ) {
        push @columna_datos, $self->obtener( $fila, $columna );
    }
    return @columna_datos;
}

sub insertar_fila {
    my ( $self, $fila, @valores ) = @_;
    if ( $fila < 0 || $fila >= $self->{filas} ) {
        die "Indice fuera del rango de la fila\n";
    }
    if ( scalar(@valores) != $self->{columnas} ) {
        die "Numero incorrecto de valores";
    }
    for my $columna ( 0 .. $self->{columnas} - 1 ) {
        $self->insertar( $fila, $columna, $valores[$columna] );
    }
}

sub insertar_columna {
    my ( $self, $columna, @valores ) = @_;
    if ( $columna < 0 || $columna >= $self->{columnas} ) {
        die "Indice fuera del rango de la columna\n";
    }
    if ( scalar(@valores) != $self->{filas} ) {
        die "Numero incorrecto de valores";
    }
    for my $fila ( 0 .. $self->{filas} - 1 ) {
        $self->insertar( $fila, $columna, $valores[$fila] );
    }
}

sub consultar_medicamento {
    my ( $self, $nombre_medicamento ) = @_;
    my $fila = undef;
    for my $indice ( 0 .. $#{ $self->{nombres_columnas} } ) {
        if ( $self->{nombres_columnas}[$indice] eq $nombre_medicamento ) {
            $fila = $indice;
            last;
        }
    }
    return () unless defined $fila;
    my @resultados;
    for my $columna ( 0 .. $self->{filas} - 1 ) {
        my $datos = $self->obtener( $columna, $fila );
        if ( $datos->{precio} > 0 || $datos->{cantidad} > 0 ) {
            push @resultados,
              {
                laboratorio => $self->{nombres_filas}[$columna],
                precio      => $datos->{precio},
                cantidad    => $datos->{cantidad}
              };
        }
    }
    return @resultados;
}

1;
