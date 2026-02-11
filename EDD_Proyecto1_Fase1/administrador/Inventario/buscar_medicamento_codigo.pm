package utilidades::buscar_medicamento_codigo;
use strict;
use warnings;
use utilidades::leer_json;

sub por_codigo {
  my ($codigo) = @_;
  my $ruta_inventario = 'administrador/Inventario/inventario.json';
  my $inventario = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta_inventario);
  
  foreach my $med (@$inventario) {
    return $med if $med->{codigo} eq $codigo;
  }
  
  return undef;  # No encontrado
}

1;
