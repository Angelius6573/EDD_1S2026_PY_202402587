#!/usr/bin/perl
package reportes::proveedores_dots;
use strict;
use warnings;

sub generar_diagrama_proveedores {
  my ($lista_circular, $ruta_dot, $ruta_png, $ruta_svg) = @_;

  open my $fh, '>', $ruta_dot
    or die "No se pudo abrir el archivo en $ruta_dot: $!";

  print $fh "digraph proveedores {\n";
  print $fh "rankdir=TB;\n"; # Top to Bottom <- Conexión de arriba hacia abajo
  print $fh "node [shape=box, style=filled, fillcolor=gray90];\n";
  print $fh "graph [nodesep=1.2, ranksep=0.7];\n\n";

  return print $fh "}\n"
    unless $lista_circular->{ultimo_nodo};

  my $inicio = $lista_circular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;
  my %nodos;
  my @proveedores;
  my %entregas_por_proveedor;
  my $index = 0;

  ## Nodos para los proveedores
  do {
    my $id = "prov$index";
    my $datos = $actual->{datos};

    my $contacto = $datos->{Contacto} // '';
    my $direccion = $datos->{Direccion} // '';
    my $empresa = $datos->{Empresa} // '';
    my $nit = $datos->{NIT} // '';
    my $telefono = $datos->{Telefono} // '';

    my $label = "Contacto: $contacto\\nDirección: $direccion\\nEmpresa: $empresa\\nNIT: $nit\\nTeléfono: $telefono";
    print $fh "$id [label=\"$label\", fillcolor=lightblue];\n";
    $nodos{$actual} = $id;
    push @proveedores, $id;
    # Guardar entregas para procesar después
    if ( $datos->{Entregas} && @{$datos->{Entregas}} ) {
      $entregas_por_proveedor{$id} = $datos->{Entregas};
    }
    $actual = $actual->{siguiente};
    $index++;
  } while ( $actual != $inicio );

  print $fh "\n";

  ## Nodos para la/s entrega/s
  foreach my $prov_id (@proveedores) {
    if (exists $entregas_por_proveedor{$prov_id}) {
      my $entregas = $entregas_por_proveedor{$prov_id};
      my $index_sub = 0;
      foreach my $entrega (@$entregas) {
        my $id_sub = "${prov_id}_e$index_sub";
        my $label_sub = "Código: $entrega->{Codigo}\\nCantidad: $entrega->{Cantidad}\\nFecha de Entrega: $entrega->{FechaDeEntrega}\\nFactura: $entrega->{Factura}";
        print $fh "$id_sub [label=\"$label_sub\", fillcolor=lightyellow];\n";
        $index_sub++;
      }
    }
  }
  print $fh "\n";

  ## Con esto forzamos que los proveedores queden en una sola línea horizontal
  print $fh "{ rank=same; " . join("; ", @proveedores) . "; }\n\n";

  ## Conexiones de forma vertical, para proveedor/entrega
  foreach my $prov_id (@proveedores) {
    if (exists $entregas_por_proveedor{$prov_id}) {
      my $entregas = $entregas_por_proveedor{$prov_id};
      my $num_entregas = scalar @$entregas; 
      # Conectar proveedor con primera entrega
      if ($num_entregas > 0) {
        print $fh "$prov_id -> ${prov_id}_e0;\n";
      }
      # Conectar entregas entre sí verticalmente
      for (my $i = 0; $i < $num_entregas - 1; $i++) {
        print $fh "${prov_id}_e$i -> ${prov_id}_e" . ($i+1) . ";\n";
      }
    }
  }

  print $fh "\n";

  ## Líneas forzadas para la lista circular simple
  $actual = $inicio;
  do {
    my $nodo_inicio = $nodos{$actual};
    my $nodo_final  = $nodos{$actual->{siguiente}};
    print $fh "$nodo_inicio -> $nodo_final [constraint=false];\n";
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  print $fh "\n";

  ## Método de renderizado (Invisible) para que haga de margen
  for (my $i = 0; $i < @proveedores - 1; $i++) {
    print $fh "$proveedores[$i] -> $proveedores[$i+1] [style=invis, weight=10];\n";
  }

  print $fh "}\n";
  close $fh;

  system("dot -Tpng $ruta_dot -o $ruta_png") == 0
    or warn "Falló en generación de reporte .png";
  system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
    or warn "Falló en generación de reporte .svg";
}

1;
