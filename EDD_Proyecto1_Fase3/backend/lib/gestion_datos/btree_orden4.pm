#!/usr/bin/perl
package gestion_datos::btree_orden4;
use strict;
use warnings;
use utf8;

use constant MAX => 3;
use constant MIN => 1;

package gestion_datos::btree_orden4::nodo;

sub nuevo {
    my ($clase) = @_;
    return bless {
        val  => [],
        num  => 0,
        link => [],
    }, $clase;
}

package gestion_datos::btree_orden4;

sub nuevo {
    my ($clase) = @_;
    return bless { raiz => undef }, $clase;
}

sub _clave { return $_[0]->{codigo} }

sub insertar {
    my ( $self, %d ) = @_;
    my $dato = {
        codigo            => $d{codigo}            // '',
        nombre            => $d{nombre}            // '',
        fabricante        => $d{fabricante}        // '',
        precio_unitario   => $d{precio_unitario}   // 0,
        cantidad          => $d{cantidad}          // 0,
        fecha_vencimiento => $d{fecha_vencimiento} // '',
        nivel_minimo      => $d{nivel_minimo}      // 0,
    };
    my ( $val_subido, $hijo_nuevo );
    if ( $self->_set_valor( $dato, \$val_subido, $self->{raiz}, \$hijo_nuevo ) )
    {
        $self->{raiz} = $self->_crear_raiz( $val_subido, $hijo_nuevo );
    }
}

sub _set_valor {
    my ( $self, $dato, $pval, $nodo, $hijo ) = @_;
    my $pos;

    unless ( defined $nodo ) {
        $$pval = $dato;
        $$hijo = undef;
        return 1;
    }

    if ( _clave($dato) lt _clave( $nodo->{val}[1] ) ) {
        $pos = 0;
    }
    else {
        $pos = $nodo->{num};
        while ( $pos > 1 && _clave($dato) lt _clave( $nodo->{val}[$pos] ) ) {
            $pos--;
        }
        if ( _clave($dato) eq _clave( $nodo->{val}[$pos] ) ) {
            $nodo->{val}[$pos] = $dato;
            return 0;
        }
    }

    my $nuevo_hijo;
    if ( $self->_set_valor( $dato, $pval, $nodo->{link}[$pos], \$nuevo_hijo ) )
    {
        if ( $nodo->{num} < MAX ) {
            $self->_insertar_en_nodo( $$pval, $pos, $nodo, $nuevo_hijo );
        }
        else {
            $self->_dividir_nodo( $$pval, $pval, $pos, $nodo, $nuevo_hijo,
                $hijo );
            return 1;
        }
    }
    return 0;
}

sub _crear_raiz {
    my ( $self, $val, $hijo ) = @_;
    my $nuevo = gestion_datos::btree_orden4::nodo->nuevo();
    $nuevo->{val}[1]  = $val;
    $nuevo->{num}     = 1;
    $nuevo->{link}[0] = $self->{raiz};
    $nuevo->{link}[1] = $hijo;
    return $nuevo;
}

sub _insertar_en_nodo {
    my ( $self, $val, $pos, $nodo, $hijo ) = @_;
    my $j = $nodo->{num};
    while ( $j > $pos ) {
        $nodo->{val}[ $j + 1 ]  = $nodo->{val}[$j];
        $nodo->{link}[ $j + 1 ] = $nodo->{link}[$j];
        $j--;
    }
    $nodo->{val}[ $j + 1 ]  = $val;
    $nodo->{link}[ $j + 1 ] = $hijo;
    $nodo->{num}++;
}

sub _dividir_nodo {
    my ( $self, $val, $pval, $pos, $nodo, $hijo, $nuevo_nodo ) = @_;
    my $median = ( $pos > MIN ) ? MIN + 1 : MIN;

    $$nuevo_nodo = gestion_datos::btree_orden4::nodo->nuevo();
    my $j = $median + 1;
    while ( $j <= MAX ) {
        $$nuevo_nodo->{val}[ $j - $median ]  = $nodo->{val}[$j];
        $$nuevo_nodo->{link}[ $j - $median ] = $nodo->{link}[$j];
        $j++;
    }
    $nodo->{num}        = $median;
    $$nuevo_nodo->{num} = MAX - $median;

    if ( $pos <= MIN ) {
        $self->_insertar_en_nodo( $val, $pos, $nodo, $hijo );
    }
    else {
        $self->_insertar_en_nodo( $val, $pos - $median, $$nuevo_nodo, $hijo );
    }
    $$pval = $nodo->{val}[ $nodo->{num} ];
    $$nuevo_nodo->{link}[0] = $nodo->{link}[ $nodo->{num} ];
    $nodo->{num}--;
}

sub buscar {
    my ( $self, $codigo ) = @_;
    return $self->_buscar( $self->{raiz}, $codigo );
}

sub _buscar {
    my ( $self, $nodo, $codigo ) = @_;
    return undef unless defined $nodo;
    my $i = $nodo->{num};
    while ( $i >= 1 && $codigo lt _clave( $nodo->{val}[$i] ) ) { $i--; }
    if ( $i >= 1 && $codigo eq _clave( $nodo->{val}[$i] ) ) {
        return $nodo->{val}[$i];
    }
    return undef unless defined $nodo->{link}[0];
    return $self->_buscar( $nodo->{link}[$i], $codigo );
}

sub eliminar {
    my ( $self, $codigo ) = @_;
    return unless defined $self->{raiz};
    $self->_eliminar( $self->{raiz}, $codigo );
    if ( $self->{raiz}{num} == 0 ) {
        $self->{raiz} = $self->{raiz}{link}[0];
    }
}

sub _en_orden {
    my ( $self, $nodo, $cb ) = @_;
    return unless defined $nodo;
    for my $i ( 0 .. $nodo->{num} ) {
        $self->_en_orden( $nodo->{link}[$i], $cb );
        $cb->( $nodo->{val}[ $i + 1 ] ) if $i < $nodo->{num};
    }
}

sub en_orden {
    my ( $self, $cb ) = @_;
    $self->_en_orden( $self->{raiz}, $cb );
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
            codigo            => $d->{codigo}            // '',
            nombre            => $d->{nombre}            // '',
            fabricante        => $d->{fabricante}        // '',
            precio_unitario   => $d->{precio_unitario}   // 0,
            cantidad          => $d->{cantidad}          // 0,
            fecha_vencimiento => $d->{fecha_vencimiento} // '',
            nivel_minimo      => $d->{nivel_minimo}      // 0,
        );
    }
}

sub a_array_json {
    my ($self) = @_;
    my @arr;
    $self->en_orden(
        sub {
            my ($d) = @_;
            push @arr,
              {
                codigo            => $d->{codigo},
                nombre            => $d->{nombre},
                fabricante        => $d->{fabricante},
                precio_unitario   => $d->{precio_unitario},
                cantidad          => $d->{cantidad},
                fecha_vencimiento => $d->{fecha_vencimiento},
                nivel_minimo      => $d->{nivel_minimo},
              };
        }
    );
    return \@arr;
}

1;
