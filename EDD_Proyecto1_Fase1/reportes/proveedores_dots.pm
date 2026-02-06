#!/usr/bin/perl
package reportes::proveedores_dots;
use strict;
use warnings;

sub generar_diagrama_proveedores {
  my ($lista_cicular, $ruta_dot, $ruta_png, $ruta_svg) = @_;

  open my $fh, '>', $ruta_dot
    or die "No se pudo abrir el archivo en $ruta_dot: $!";

  print $fh "digraph proveedores {\n";
  print $fh "rankdir=LR;\n"; # De izquierda a derecha
  print $fh "node [shape=box, style=filled, width=2, height=1];\n";
  print $fh "graph [nodesep=0.5, ranksep=1, splines=true, overlap=false];\n";

  return print $fh "}\n"
    unless $lista_cicular->{ultimo_nodo};

  my $inicio = $lista_cicular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;
  my %nodos;
  my $index = 0;

  do {
    my $id = "prov$index";
    my $datos = $actual->{datos};

    my $contacto = $datos->{Contacto} // '';
    my $direccion = $datos->{Direccion} // '';
    my $empresa = $datos->{Empresa} // '';
    my $nit = $datos->{NIT} // '';
    my $telefono = $datos->{Telefono} // '';

    my $label = "Contacto: $contacto\\nDirección: $direccion\\nEmpresa: $empresa\\nNIT: $nit\\nTeléfono: $telefono";
    print $fh "$id [label=\"$label\"];\n";

    $nodos{$actual} = $id;

    ## Validar caso: Hay o no hay entregas
    if ( $datos->{Entregas} && @{$datos->{Entregas}} ) {
      print $fh "subgraph cluster_$id {\n";
      print $fh "label=\"Entregas\";\n";
      print $fh "node [shape=box]\n";

      my $index_sub = 0;
      my $anterior;

      foreach my $entrega ( @{$datos->{Entregas}} ) {
        my $id_sub = "${id}_ent$index_sub";
        my $label_sub = "Código: $entrega->{Codigo}\\nCantidad: $entrega->{Cantidad}\\nFecha de Entrega: $entrega->{FechaDeEntrega}\\nFactura: $entrega->{Factura}";
        print $fh "$id_sub [label=\"$label_sub\"];\n";
        print $fh "$anterior -> $id_sub;\n" if defined $anterior;
        $anterior = $id_sub;
        $index_sub++;
      }
      print $fh "}\n";
    }
    $actual = $actual->{siguiente};
    $index++;
  } while ( $actual != $inicio );

  ## Cierre de ciclo
  $actual = $inicio;
  do {
    my $nodo_inicio = $nodos{$actual};
    my $nodo_final = $nodos{$actual->{siguiente}};
    print $fh "$nodo_inicio -> $nodo_final;\n";
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  print $fh "}\n";
  close $fh;

  # Generar imágenes
  system("dot -Tpng $ruta_dot -o $ruta_png") == 0
    or warn "Falló en generación de reporte .png";
  system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
    or warn "Falló en generación de reporte .svg";
}

1;
