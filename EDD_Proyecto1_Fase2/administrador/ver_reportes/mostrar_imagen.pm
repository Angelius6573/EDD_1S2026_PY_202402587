#!/usr/bin/perl
package administrador::ver_reportes::mostrar_imagen;

sub mostrar {
  # Directorio donde se almacenan los reportes SVG del inventario
  my ($directorio) = @_;

  # Abrir el directorio para leer su contenido; abortar si no existe o no es accesible
  opendir(my $dh, $directorio)
    or die "No se pudo encontrar el directorio";

  my $imagen;                  # Almacenará el nombre del archivo más reciente encontrado
  my $tiempo_mas_reciente = 0; # Marca de tiempo más alta vista hasta el momento (epoch)

  # Iterar sobre cada entrada del directorio
  while (my $archivo = readdir($dh)) {

    next if $archivo =~ /^\.\.?$/; # Saltar las entradas especiales "." (actual) y ".." (padre)

    my $ruta = "$directorio/$archivo";
    next unless -f $ruta; # Saltar subdirectorios, symlinks u otros tipos; solo archivos regulares

    # stat() retorna una lista de 13 atributos del archivo; el índice 9 es mtime (última modificación)
    my $mtime = (stat($ruta))[9];

    # Si este archivo fue modificado más recientemente que el candidato actual, reemplazarlo
    if ($mtime > $tiempo_mas_reciente) {
      $tiempo_mas_reciente = $mtime;
      $imagen = $archivo;
    }
  }

  closedir($dh); # Liberar el handle del directorio una vez terminado el recorrido

  if ($imagen) {
    print "\n";
    system("kitten icat $directorio/$imagen");
  } else {
    print "No se encontraron archivos.\n";
  }
}

1;
