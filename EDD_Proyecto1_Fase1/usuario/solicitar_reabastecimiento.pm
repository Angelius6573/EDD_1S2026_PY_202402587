#!/usr/bin/perl
package usuario::solicitar_reabastecimiento;
use strict;
use warnings;

use interfaz_usuario::usuario;

sub solicitud_medicamentos {
  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso();
}

1;
