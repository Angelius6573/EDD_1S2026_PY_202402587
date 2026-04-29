#!/usr/bin/perl
package reportes::nombre_archivos;
use strict;
use warnings;
use POSIX qw(strftime);
use File::Path qw(make_path);

# Genera nombres únicos usando timestamp + random hex
# y crea los directorios necesarios si no existen.
sub nombre {
    my ($tipo, $para) = @_;
    my $ts     = strftime("%Y-%m-%d", localtime);
    my $codigo = sprintf("%08X", int(rand(0xFFFFFFFF)));

    my $base_dot = "reportes/archivos_dots/$tipo";
    my $base_png = "reportes/imagenes/$tipo/PNG";
    my $base_svg = "reportes/imagenes/$tipo/SVG";

    # Crear directorios si no existen
    for my $dir ($base_dot, $base_png, $base_svg) {
        unless (-d $dir) {
            make_path($dir) or warn "No se pudo crear directorio $dir: $!\n";
        }
    }

    my $nombre_dot = "$base_dot/$para-$ts-$codigo.dot";
    my $nombre_png = "$base_png/$para-$ts-$codigo.png";
    my $nombre_svg = "$base_svg/$para-$ts-$codigo.svg";

    return ($nombre_dot, $nombre_png, $nombre_svg);
}

1;
