#!/usr/bin/perl
package gestion_datos::btree_orden4;
use strict;
use warnings;
use utf8;

# ─────────────────────────────────────────────
#  Árbol B Orden 4  (max 3 claves por nodo)
#  Clave de ordenamiento: codigo (SUM-XXX)
#  val[1..num]  → datos completos del suministro
#  link[0..num] → hijos
# ─────────────────────────────────────────────

use constant MAX => 3;    # máximo de claves por nodo
use constant MIN => 1;    # mínimo de claves por nodo

# ─── Nodo ────────────────────────────────────
package gestion_datos::btree_orden4::nodo;

sub nuevo {
    my ($clase) = @_;
    return bless {
        val  => [],    # índice 1..num (cada val[i] es un hashref de datos)
        num  => 0,
        link => [],    # índice 0..num
    }, $clase;
}

# ─── Árbol B ─────────────────────────────────
package gestion_datos::btree_orden4;

sub nuevo {
    my ($clase) = @_;
    return bless { raiz => undef }, $clase;
}

# ── Inserción ────────────────────────────────

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

sub _clave {
    my ($self) = @_;
    return $self->{codigo};
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

            # Duplicado: actualizar
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
    while ( $i >= 1 && $codigo lt _clave( $nodo->{val}[$i] ) ) {
        $i--;
    }
    if ( $i >= 1 && $codigo eq _clave( $nodo->{val}[$i] ) ) {
        return $nodo->{val}[$i];
    }
    return undef unless defined $nodo->{link}[0];    # es hoja
    return $self->_buscar( $nodo->{link}[$i], $codigo );
}

sub eliminar {
    my ( $self, $codigo ) = @_;
    return unless defined $self->{raiz};
    $self->_eliminar( $self->{raiz}, $codigo );

    # Si la raíz quedó vacía, subir el único hijo
    if ( $self->{raiz}{num} == 0 ) {
        $self->{raiz} = $self->{raiz}{link}[0];
    }
}

sub _eliminar {
    my ( $self, $nodo, $codigo ) = @_;
    return unless defined $nodo;

    my $pos = $self->_buscar_pos( $nodo, $codigo );

    if (   $pos >= 1
        && $pos <= $nodo->{num}
        && $codigo eq _clave( $nodo->{val}[$pos] ) )
    {
        # Clave encontrada en este nodo
        if ( !defined $nodo->{link}[0] ) {

            # Nodo hoja: eliminar directamente
            $self->_quitar_de_nodo( $nodo, $pos );
        }
        else {
          # Nodo interno: reemplazar con predecesor (max del subárbol izquierdo)
            my $pred = $self->_maximo( $nodo->{link}[ $pos - 1 ] );
            $nodo->{val}[$pos] = $pred;
            $self->_eliminar( $nodo->{link}[ $pos - 1 ], _clave($pred) );
            $self->_reparar_si_necesario( $nodo, $pos - 1 );
        }
    }
    else {
        # Clave no está en este nodo, bajar al hijo correcto
        return unless defined $nodo->{link}[0];
        my $idx_hijo = ( $pos > $nodo->{num} ) ? $nodo->{num} : $pos - 1;
        $idx_hijo = 0 if $idx_hijo < 0;

        # Determinar índice correcto del hijo
        my $hijo_idx = 0;
        for my $i ( 0 .. $nodo->{num} ) {
            if (   $i == $nodo->{num}
                || $codigo lt _clave( $nodo->{val}[ $i + 1 ] ) )
            {
                $hijo_idx = $i;
                last;
            }
        }

        if ( defined $nodo->{link}[$hijo_idx]
            && $nodo->{link}[$hijo_idx]{num} == MIN )
        {
            $self->_rellenar( $nodo, $hijo_idx );

            # Recalcular posición tras rebalanceo
            $hijo_idx = 0;
            for my $i ( 0 .. $nodo->{num} ) {
                if (   $i == $nodo->{num}
                    || $codigo lt _clave( $nodo->{val}[ $i + 1 ] ) )
                {
                    $hijo_idx = $i;
                    last;
                }
            }
        }
        $self->_eliminar( $nodo->{link}[$hijo_idx], $codigo );
    }
}

sub _buscar_pos {
    my ( $self, $nodo, $codigo ) = @_;
    my $i = 1;
    $i++ while $i <= $nodo->{num} && $codigo gt _clave( $nodo->{val}[$i] );
    return $i;
}

sub _quitar_de_nodo {
    my ( $self, $nodo, $pos ) = @_;
    for my $i ( $pos .. $nodo->{num} - 1 ) {
        $nodo->{val}[$i]  = $nodo->{val}[ $i + 1 ];
        $nodo->{link}[$i] = $nodo->{link}[ $i + 1 ];
    }
    $nodo->{val}[ $nodo->{num} ]  = undef;
    $nodo->{link}[ $nodo->{num} ] = undef;
    $nodo->{num}--;
}

sub _maximo {
    my ( $self, $nodo ) = @_;
    while ( defined $nodo->{link}[ $nodo->{num} ] ) {
        $nodo = $nodo->{link}[ $nodo->{num} ];
    }
    return $nodo->{val}[ $nodo->{num} ];
}

sub _reparar_si_necesario {
    my ( $self, $padre, $idx ) = @_;
    return unless defined $padre->{link}[$idx];
    $self->_rellenar( $padre, $idx ) if $padre->{link}[$idx]{num} < MIN;
}

sub _rellenar {
    my ( $self, $padre, $idx ) = @_;
    if (   $idx > 0
        && defined $padre->{link}[ $idx - 1 ]
        && $padre->{link}[ $idx - 1 ]{num} > MIN )
    {
        $self->_prestar_del_anterior( $padre, $idx );
    }
    elsif ( $idx < $padre->{num}
        && defined $padre->{link}[ $idx + 1 ]
        && $padre->{link}[ $idx + 1 ]{num} > MIN )
    {
        $self->_prestar_del_siguiente( $padre, $idx );
    }
    else {
        if ( $idx < $padre->{num} ) {
            $self->_fusionar( $padre, $idx );
        }
        else {
            $self->_fusionar( $padre, $idx - 1 );
        }
    }
}

sub _prestar_del_anterior {
    my ( $self, $padre, $idx ) = @_;
    my $hijo    = $padre->{link}[$idx];
    my $hermano = $padre->{link}[ $idx - 1 ];

    # Mover las claves del hijo hacia la derecha
    for my $i ( reverse 1 .. $hijo->{num} ) {
        $hijo->{val}[ $i + 1 ]  = $hijo->{val}[$i];
        $hijo->{link}[ $i + 1 ] = $hijo->{link}[$i];
    }
    $hijo->{link}[1] = $hijo->{link}[0];

    # Bajar clave del padre al hijo
    $hijo->{val}[1]  = $padre->{val}[$idx];
    $hijo->{link}[0] = $hermano->{link}[ $hermano->{num} ];
    $hijo->{num}++;

    # Subir la última clave del hermano al padre
    $padre->{val}[$idx]                 = $hermano->{val}[ $hermano->{num} ];
    $hermano->{link}[ $hermano->{num} ] = undef;
    $hermano->{val}[ $hermano->{num} ]  = undef;
    $hermano->{num}--;
}

sub _prestar_del_siguiente {
    my ( $self, $padre, $idx ) = @_;
    my $hijo    = $padre->{link}[$idx];
    my $hermano = $padre->{link}[ $idx + 1 ];

    # Bajar clave del padre al final del hijo
    $hijo->{val}[ $hijo->{num} + 1 ]  = $padre->{val}[ $idx + 1 ];
    $hijo->{link}[ $hijo->{num} + 1 ] = $hermano->{link}[0];
    $hijo->{num}++;

    # Subir la primera clave del hermano al padre
    $padre->{val}[ $idx + 1 ] = $hermano->{val}[1];
    $hermano->{link}[0] = $hermano->{link}[1];
    for my $i ( 1 .. $hermano->{num} - 1 ) {
        $hermano->{val}[$i]  = $hermano->{val}[ $i + 1 ];
        $hermano->{link}[$i] = $hermano->{link}[ $i + 1 ];
    }
    $hermano->{val}[ $hermano->{num} ]  = undef;
    $hermano->{link}[ $hermano->{num} ] = undef;
    $hermano->{num}--;
}

sub _fusionar {
    my ( $self, $padre, $idx ) = @_;
    my $izq = $padre->{link}[$idx];
    my $der = $padre->{link}[ $idx + 1 ];

    # Bajar la clave del padre al nodo izquierdo
    $izq->{val}[ $izq->{num} + 1 ]  = $padre->{val}[ $idx + 1 ];
    $izq->{link}[ $izq->{num} + 1 ] = $der->{link}[0];
    $izq->{num}++;

    # Copiar claves del nodo derecho al izquierdo
    for my $i ( 1 .. $der->{num} ) {
        $izq->{val}[ $izq->{num} + 1 ]  = $der->{val}[$i];
        $izq->{link}[ $izq->{num} + 1 ] = $der->{link}[$i];
        $izq->{num}++;
    }

    # Quitar la clave que bajó del padre
    for my $i ( $idx + 1 .. $padre->{num} - 1 ) {
        $padre->{val}[$i]  = $padre->{val}[ $i + 1 ];
        $padre->{link}[$i] = $padre->{link}[ $i + 1 ];
    }
    $padre->{val}[ $padre->{num} ]  = undef;
    $padre->{link}[ $padre->{num} ] = undef;
    $padre->{num}--;
}

sub en_orden {
    my ( $self, $cb ) = @_;
    $self->_en_orden( $self->{raiz}, $cb );
}

sub _en_orden {
    my ( $self, $nodo, $cb ) = @_;
    return unless defined $nodo;
    for my $i ( 0 .. $nodo->{num} ) {
        $self->_en_orden( $nodo->{link}[$i], $cb );
        $cb->( $nodo->{val}[ $i + 1 ] ) if $i < $nodo->{num};
    }
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
