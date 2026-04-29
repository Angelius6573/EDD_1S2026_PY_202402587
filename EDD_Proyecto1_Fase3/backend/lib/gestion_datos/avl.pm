#!/usr/bin/perl
package gestion_datos::avl;
use strict;
use warnings;
use utf8;

package gestion_datos::avl::nodo;

sub nuevo {
    my ( $clase, %d ) = @_;
    return bless {
        colegio      => $d{colegio},
        nombre       => $d{nombre}       // '',
        tipo         => $d{tipo}         // '',
        departamento => $d{departamento} // '',
        especialidad => $d{especialidad} // '',
        contrasena   => $d{contrasena}   // '',
        izquierda    => undef,
        derecha      => undef,
        altura       => 0,
    }, $clase;
}

package gestion_datos::avl;

sub nuevo {
    my ($clase) = @_;
    return bless { raiz => undef }, $clase;
}

sub _altura {
    my ( $self, $n ) = @_;
    return -1 unless defined $n;
    return $n->{altura};
}

sub _max {
    my ( $self, $a, $b ) = @_;
    return $a > $b ? $a : $b;
}

sub _actualizar_altura {
    my ( $self, $n ) = @_;
    $n->{altura} = 1 + $self->_max( $self->_altura( $n->{izquierda} ),
        $self->_altura( $n->{derecha} ) );
}

sub _balance {
    my ( $self, $n ) = @_;
    return 0 unless defined $n;
    return $self->_altura( $n->{izquierda} ) - $self->_altura( $n->{derecha} );
}

sub _rotar_derecha {
    my ( $self, $y ) = @_;
    my $x  = $y->{izquierda};
    my $T2 = $x->{derecha};
    $x->{derecha}   = $y;
    $y->{izquierda} = $T2;
    $self->_actualizar_altura($y);
    $self->_actualizar_altura($x);
    return $x;
}

sub _rotar_izquierda {
    my ( $self, $x ) = @_;
    my $y  = $x->{derecha};
    my $T2 = $y->{izquierda};
    $y->{izquierda} = $x;
    $x->{derecha}   = $T2;
    $self->_actualizar_altura($x);
    $self->_actualizar_altura($y);
    return $y;
}

sub _rebalancear_post_op {
    my ( $self, $n ) = @_;
    $self->_actualizar_altura($n);
    my $b = $self->_balance($n);

    # Izquierda-Izquierda
    if ( $b > 1 && $self->_balance( $n->{izquierda} ) >= 0 ) {
        return $self->_rotar_derecha($n);
    }

    # Izquierda-Derecha
    if ( $b > 1 && $self->_balance( $n->{izquierda} ) < 0 ) {
        $n->{izquierda} = $self->_rotar_izquierda( $n->{izquierda} );
        return $self->_rotar_derecha($n);
    }

    # Derecha-Derecha
    if ( $b < -1 && $self->_balance( $n->{derecha} ) <= 0 ) {
        return $self->_rotar_izquierda($n);
    }

    # Derecha-Izquierda
    if ( $b < -1 && $self->_balance( $n->{derecha} ) > 0 ) {
        $n->{derecha} = $self->_rotar_derecha( $n->{derecha} );
        return $self->_rotar_izquierda($n);
    }
    return $n;
}

sub insertar {
    my ( $self, %d ) = @_;
    $self->{raiz} = $self->_insertar( $self->{raiz}, %d );
}

sub _insertar {
    my ( $self, $n, %d ) = @_;
    unless ( defined $n ) {
        return gestion_datos::avl::nodo->nuevo(%d);
    }
    if ( $d{colegio} lt $n->{colegio} ) {
        $n->{izquierda} = $self->_insertar( $n->{izquierda}, %d );
    }
    elsif ( $d{colegio} gt $n->{colegio} ) {
        $n->{derecha} = $self->_insertar( $n->{derecha}, %d );
    }
    else {
        # Duplicado: actualizar todos los campos
        $n->{$_} = $d{$_}
          for qw(nombre tipo departamento especialidad contrasena);
        return $n;
    }
    return $self->_rebalancear_post_op($n);
}

sub buscar {
    my ( $self, $colegio ) = @_;
    return $self->_buscar( $self->{raiz}, $colegio );
}

sub _buscar {
    my ( $self, $n, $colegio ) = @_;
    return undef unless defined $n;
    return $n if $colegio eq $n->{colegio};
    return $self->_buscar( $n->{izquierda}, $colegio )
      if $colegio lt $n->{colegio};
    return $self->_buscar( $n->{derecha}, $colegio );
}

sub eliminar {
    my ( $self, $colegio ) = @_;
    $self->{raiz} = $self->_eliminar( $self->{raiz}, $colegio );
}

sub _min_nodo {
    my ( $self, $n ) = @_;
    $n = $n->{izquierda} while defined $n->{izquierda};
    return $n;
}

sub _eliminar {
    my ( $self, $n, $colegio ) = @_;
    return undef unless defined $n;

    if ( $colegio lt $n->{colegio} ) {
        $n->{izquierda} = $self->_eliminar( $n->{izquierda}, $colegio );
    }
    elsif ( $colegio gt $n->{colegio} ) {
        $n->{derecha} = $self->_eliminar( $n->{derecha}, $colegio );
    }
    else {
        # Nodo encontrado
        return $n->{derecha}   unless defined $n->{izquierda};
        return $n->{izquierda} unless defined $n->{derecha};

        # Dos hijos: sustituir con sucesor en orden
        my $suc = $self->_min_nodo( $n->{derecha} );
        $n->{$_} = $suc->{$_}
          for qw(colegio nombre tipo departamento especialidad contrasena);
        $n->{derecha} = $self->_eliminar( $n->{derecha}, $suc->{colegio} );
    }
    return $self->_rebalancear_post_op($n);
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

sub esta_vacio {
    my ($self) = @_;
    return !defined $self->{raiz};
}

sub cargar_desde_array {
    my ( $self, $arr ) = @_;
    for my $d (@$arr) {
        $self->insertar(
            colegio      => $d->{numero_colegio}  // $d->{colegio} // '',
            nombre       => $d->{nombre_completo} // $d->{nombre}  // '',
            tipo         => $d->{tipo_usuario}    // $d->{tipo}    // '',
            departamento => $d->{departamento}    // '',
            especialidad => $d->{especialidad}    // '',
            contrasena   => $d->{contrasena}      // '',
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
                numero_colegio  => $n->{colegio},
                nombre_completo => $n->{nombre},
                tipo_usuario    => $n->{tipo},
                departamento    => $n->{departamento},
                especialidad    => $n->{especialidad} // '',
                contrasena      => $n->{contrasena},
              };
        }
    );
    return \@arr;
}

1;
