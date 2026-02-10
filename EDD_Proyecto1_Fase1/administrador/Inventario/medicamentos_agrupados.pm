#!/usr/bin/perl
package administrador::Inventario::medicamentos_agrupados;
use strict;
use warnings;

sub validar_duplicados {
  my ($lista) = @_;
  my %medicamentos_agrupados;
  my $nodo_actual = $lista->{cabeza};
  
  while ($nodo_actual) {
    my $med = $nodo_actual->{dato};
    my $codigo = $med->{codigo};
    
    if (!exists $medicamentos_agrupados{$codigo}) {
      # Si no existe, creamos la entrada con el medicamento base
      $medicamentos_agrupados{$codigo} = {
        codigo => $med->{codigo},
        nombre => $med->{nombre},
        principio_activo => $med->{principio_activo},
        laboratorio => $med->{laboratorio},
        precio_unitario => $med->{precio_unitario},
        nivel_minimo => $med->{nivel_minimo},
        cantidad => $med->{cantidad} || 0,  # Cantidad total inicial
        lotes => []
      };
      # Agregamos el primer lote
      push @{$medicamentos_agrupados{$codigo}->{lotes}}, {
        fecha_vencimiento => $med->{fecha_vencimiento},
        cantidad => $med->{cantidad}  # Cambiado de cantidad_nueva a cantidad
      };
    } else {
      # Si ya existe, verificamos si la fecha de vencimiento es nueva
      my $fecha_existe = 0;
      foreach my $lote (@{$medicamentos_agrupados{$codigo}->{lotes}}) {
        if ($lote->{fecha_vencimiento} eq $med->{fecha_vencimiento}) {
          $lote->{cantidad} += $med->{cantidad};  # Acumulamos en el lote existente
          $fecha_existe = 1;
          last;
        }
      }
      if (!$fecha_existe) {
        # Nueva fecha de vencimiento para este código
        push @{$medicamentos_agrupados{$codigo}->{lotes}}, {
          fecha_vencimiento => $med->{fecha_vencimiento},
          cantidad => $med->{cantidad} 
        };
      } 
      # Siempre acumulamos a la cantidad total
      $medicamentos_agrupados{$codigo}->{cantidad} += $med->{cantidad};
    }
    
    $nodo_actual = $nodo_actual->{siguiente};
  }
  
  # !IMPORTANTE: Retornar el hash
  return \%medicamentos_agrupados;  # Retornamos una referencia al hash
}

1;
