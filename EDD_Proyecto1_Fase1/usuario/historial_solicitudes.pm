#!/usr/bin/perl
package usuario::historial_solicitudes;
use strict;
use warnings;

use interfaz_usuario::usuario;

sub historial_solicitudes {
  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso();
}

1;
