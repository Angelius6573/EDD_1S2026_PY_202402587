#!/usr/bin/perl
package gestion_datos::bst;
use strict;
use warnings;
use utf8;

package gestion_datos::bst::nodo;

sub nuevo {
    my ( $clase, %d ) = @_;
    return bless {
        codigo          => $d{codigo}          // '',
        nombre          => $d{nombre}          // '',
        fabricante      => $d{fabricante}      // '',
        precio_unitario => $d{precio_unitario} // 0,
        cantidad        => $d{cantidad}        // 0,
        fecha_ingreso   => $d{fecha_ingreso}   // '',
        nivel_minimo    => $d{nivel_minimo}    // 0,
        izquierda       => undef,
        derecha         => undef,
    }, $clase;
}

package gestion_datos::bst;

sub nuevo {
    my ($clase) = @_;
    return bless { raiz => undef }, $clase;
}

sub insertar {
    my ( $self, %d ) = @_;
    $self->{raiz} = $self->_insertar( $self->{raiz}, %d );
}

sub _insertar {
    my ( $self, $n, %d ) = @_;
    unless ( defined $n ) {
        return gestion_datos::bst::nodo->nuevo(%d);
    }
    if ( $d{codigo} lt $n->{codigo} ) {
        $n->{izquierda} = $self->_insertar( $n->{izquierda}, %d );
    }
    elsif ( $d{codigo} gt $n->{codigo} ) {
        $n->{derecha} = $self->_insertar( $n->{derecha}, %d );
    }
    else {
        $n->{$_} = $d{$_}
          for
          qw(nombre fabricante precio_unitario cantidad fecha_ingreso nivel_minimo);
    }
    return $n;
}

sub buscar {
    my ( $self, $codigo ) = @_;
    return $self->_buscar( $self->{raiz}, $codigo );
}

sub _buscar {
    my ( $self, $n, $codigo ) = @_;
    return undef unless defined $n;
    return $n if $codigo eq $n->{codigo};
    return $self->_buscar( $n->{izquierda}, $codigo )
      if $codigo lt $n->{codigo};
    return $self->_buscar( $n->{derecha}, $codigo );
}

sub eliminar {
    my ( $self, $codigo ) = @_;
    $self->{raiz} = $self->_eliminar( $self->{raiz}, $codigo );
}

sub _min_nodo {
    my ( $self, $n ) = @_;
    $n = $n->{izquierda} while defined $n->{izquierda};
    return $n;
}

sub _eliminar {
    my ( $self, $n, $codigo ) = @_;
    return undef unless defined $n;

    if ( $codigo lt $n->{codigo} ) {
        $n->{izquierda} = $self->_eliminar( $n->{izquierda}, $codigo );
    }
    elsif ( $codigo gt $n->{codigo} ) {
        $n->{derecha} = $self->_eliminar( $n->{derecha}, $codigo );
    }
    else {
        return $n->{derecha}   unless defined $n->{izquierda};
        return $n->{izquierda} unless defined $n->{derecha};
        my $suc = $self->_min_nodo( $n->{derecha} );
        $n->{$_} = $suc->{$_}
          for
          qw(codigo nombre fabricante precio_unitario cantidad fecha_ingreso nivel_minimo);
        $n->{derecha} = $self->_eliminar( $n->{derecha}, $suc->{codigo} );
    }
    return $n;
}

sub en_orden {
    my ( $self, $cb ) = @_;
    $self->_en_orden( $self->{raiz}, $cb );
}

sub _en_orden {
    my ( $self, $n, $cb ) = @_;
    return unless defined $n;
    $self->_en_orden( $n->{izquierda}, $cb );
    $cb->($n);
    $self->_en_orden( $n->{derecha}, $cb );
}

sub pre_orden {
    my ( $self, $cb ) = @_;
    $self->_pre_orden( $self->{raiz}, $cb );
}

sub _pre_orden {
    my ( $self, $n, $cb ) = @_;
    return unless defined $n;
    $cb->($n);
    $self->_pre_orden( $n->{izquierda}, $cb );
    $self->_pre_orden( $n->{derecha},   $cb );
}

sub post_orden {
    my ( $self, $cb ) = @_;
    $self->_post_orden( $self->{raiz}, $cb );
}

sub _post_orden {
    my ( $self, $n, $cb ) = @_;
    return unless defined $n;
    $self->_post_orden( $n->{izquierda}, $cb );
    $self->_post_orden( $n->{derecha},   $cb );
    $cb->($n);
}

sub a_lista {
    my ($self) = @_;
    my @lista;
    $self->en_orden( sub { push @lista, $_[0] } );
    return \@lista;
}

sub esta_vacio { !defined $_[0]->{raiz} }

sub cargar_desde_array {
    my ( $self, $arr ) = @_;
    for my $d (@$arr) {
        $self->insertar(
            codigo          => $d->{codigo}          // '',
            nombre          => $d->{nombre}          // '',
            fabricante      => $d->{fabricante}      // '',
            precio_unitario => $d->{precio_unitario} // 0,
            cantidad        => $d->{cantidad}        // 0,
            fecha_ingreso   => $d->{fecha_ingreso}   // '',
            nivel_minimo    => $d->{nivel_minimo}    // 0,
        );
    }
}

sub a_array_json {
    my ($self) = @_;
    my @arr;
    $self->en_orden(
        sub {
            my ($n) = @_;
            push @arr,
              {
                codigo          => $n->{codigo},
                nombre          => $n->{nombre},
                fabricante      => $n->{fabricante},
                precio_unitario => $n->{precio_unitario},
                cantidad        => $n->{cantidad},
                fecha_ingreso   => $n->{fecha_ingreso},
                nivel_minimo    => $n->{nivel_minimo},
              };
        }
    );
    return \@arr;
}

sub es_hoja {
    my ( $self, $n ) = @_;
    return !defined $n->{izquierda} && !defined $n->{derecha};
}

1;
