#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use interfaz_usuario::inicio;

print interfaz_usuario::inicio::consultar_usuario(), "\n";
