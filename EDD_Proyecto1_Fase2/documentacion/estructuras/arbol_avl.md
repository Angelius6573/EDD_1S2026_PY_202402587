# Árbol AVL — Árbol Binario Autobalanceado

## Definición

El Árbol AVL extiende el BST añadiendo la propiedad de **balance**: la diferencia de altura entre los subárboles izquierdo y derecho de cualquier nodo no puede exceder 1. Esto garantiza que la altura del árbol sea siempre O(log n), eliminando el peor caso del BST degenerado.

## Factor de balance

```
FB(nodo) = altura(subárbol_izquierdo) - altura(subárbol_derecho)

FB = -1, 0, +1  → árbol balanceado
FB = -2 o +2    → requiere rotación
```

## Casos de desbalance y rotaciones

| Caso | FB del nodo | FB del hijo | Rotación |
|------|:-----------:|:-----------:|----------|
| LL | +2 | +1 | Simple derecha |
| RR | -2 | -1 | Simple izquierda |
| LR | +2 | -1 | Doble: izquierda luego derecha |
| RL | -2 | +1 | Doble: derecha luego izquierda |

## Implementación de rotaciones en Perl

```perl
sub _altura {
    my ($nodo) = @_;
    return 0 unless defined $nodo;
    return $nodo->{altura};
}

sub _actualizar_altura {
    my ($nodo) = @_;
    my $h_izq = _altura($nodo->{izquierdo});
    my $h_der = _altura($nodo->{derecho});
    $nodo->{altura} = 1 + ($h_izq > $h_der ? $h_izq : $h_der);
}

sub _factor_balance {
    my ($nodo) = @_;
    return 0 unless defined $nodo;
    return _altura($nodo->{izquierdo}) - _altura($nodo->{derecho});
}

sub _rotar_derecha {
    my ($self, $y) = @_;
    my $x  = $y->{izquierdo};
    my $T2 = $x->{derecho};
    $x->{derecho}    = $y;
    $y->{izquierdo}  = $T2;
    _actualizar_altura($y);
    _actualizar_altura($x);
    return $x;   # nueva raíz del subárbol
}

sub _rotar_izquierda {
    my ($self, $x) = @_;
    my $y  = $x->{derecho};
    my $T2 = $y->{izquierdo};
    $y->{izquierdo} = $x;
    $x->{derecho}   = $T2;
    _actualizar_altura($x);
    _actualizar_altura($y);
    return $y;
}

sub _balancear {
    my ($self, $nodo) = @_;
    _actualizar_altura($nodo);
    my $fb = _factor_balance($nodo);

    # Caso LL
    if ($fb > 1 && _factor_balance($nodo->{izquierdo}) >= 0) {
        return $self->_rotar_derecha($nodo);
    }
    # Caso LR
    if ($fb > 1 && _factor_balance($nodo->{izquierdo}) < 0) {
        $nodo->{izquierdo} = $self->_rotar_izquierda($nodo->{izquierdo});
        return $self->_rotar_derecha($nodo);
    }
    # Caso RR
    if ($fb < -1 && _factor_balance($nodo->{derecho}) <= 0) {
        return $self->_rotar_izquierda($nodo);
    }
    # Caso RL
    if ($fb < -1 && _factor_balance($nodo->{derecho}) > 0) {
        $nodo->{derecho} = $self->_rotar_derecha($nodo->{derecho});
        return $self->_rotar_izquierda($nodo);
    }
    return $nodo;   # ya balanceado
}
```

## Inserción completa

```perl
sub _insertar_rec {
    my ($self, $nodo, $nuevo) = @_;
    unless (defined $nodo) { return $nuevo }

    if ($nuevo->{numero_colegio} lt $nodo->{numero_colegio}) {
        $nodo->{izquierdo} = $self->_insertar_rec($nodo->{izquierdo}, $nuevo);
    } elsif ($nuevo->{numero_colegio} gt $nodo->{numero_colegio}) {
        $nodo->{derecho} = $self->_insertar_rec($nodo->{derecho}, $nuevo);
    } else {
        # Clave duplicada: no se inserta
        return $nodo;
    }
    return $self->_balancear($nodo);
}
```

---

[← Volver a Estructuras](README.md)
