#!/usr/bin/perl
package interfaz::usuario::solicitudes;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use Time::Piece;
use JSON::PP;
use File::Path qw(make_path);
use Data::UUID;
use interfaz::usuario::common;

sub crear_tab {
    my ($ctx)        = @_;
    my $nodo         = $ctx->{nodo};
    my $lista_med    = $ctx->{med};
    my $departamento = $nodo->{departamento};

    my $vbox = Gtk3::Box->new( 'vertical', 10 );
    $vbox->set_margin_start(20);
    $vbox->set_margin_end(20);
    $vbox->set_margin_top(20);
    $vbox->set_margin_bottom(20);

    my $notebook = Gtk3::Notebook->new();

    my $tab_nueva = _tab_nueva_solicitud( $ctx, $lista_med );
    $notebook->append_page( $tab_nueva,
        interfaz::usuario::common::tab_label('Nueva Solicitud') );

    my $tab_historial = _tab_historial_solicitudes($ctx);
    $notebook->append_page( $tab_historial,
        interfaz::usuario::common::tab_label('Mi Historial') );

    $vbox->pack_start( $notebook, TRUE, TRUE, 0 );
    return $vbox;
}

sub _tab_nueva_solicitud {
    my ( $ctx, $lista_med ) = @_;
    my $nodo = $ctx->{nodo};

    my $vbox = Gtk3::Box->new( 'vertical', 12 );
    $vbox->set_margin_start(20);
    $vbox->set_margin_end(20);
    $vbox->set_margin_top(16);
    $vbox->set_margin_bottom(16);

    my $titulo = Gtk3::Label->new('Solicitar Reabastecimiento de Medicamentos');
    $titulo->get_style_context()->add_class('tarjeta-titulo');
    $titulo->set_halign('start');
    $vbox->pack_start( $titulo, FALSE, FALSE, 0 );

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(8);
    $grid->set_column_spacing(12);
    $grid->set_margin_top(12);

    my $lbl_codigo = Gtk3::Label->new('Codigo del Medicamento:');
    $lbl_codigo->get_style_context()->add_class('campo-label');
    $lbl_codigo->set_halign('end');
    my $entry_codigo = Gtk3::Entry->new();
    $entry_codigo->set_placeholder_text('Ej: MED-001');
    $entry_codigo->set_hexpand(TRUE);

    my $btn_buscar = interfaz::usuario::common::boton( 'Buscar Medicamento',
        'boton-secundario' );
    my $lbl_info = Gtk3::Label->new('');
    $lbl_info->set_line_wrap(TRUE);
    $lbl_info->get_style_context()->add_class('valor-label');

    my $lbl_cantidad = Gtk3::Label->new('Cantidad Requerida:');
    $lbl_cantidad->get_style_context()->add_class('campo-label');
    $lbl_cantidad->set_halign('end');
    my $spin_cantidad = Gtk3::SpinButton->new_with_range( 1, 10000, 1 );
    $spin_cantidad->set_value(10);

    my $lbl_prioridad = Gtk3::Label->new('Prioridad:');
    $lbl_prioridad->get_style_context()->add_class('campo-label');
    $lbl_prioridad->set_halign('end');
    my $combo_prioridad = Gtk3::ComboBoxText->new();
    $combo_prioridad->append_text('Baja');
    $combo_prioridad->append_text('Media');
    $combo_prioridad->append_text('Alta');
    $combo_prioridad->append_text('Urgente');
    $combo_prioridad->set_active(1);

    my $lbl_razon = Gtk3::Label->new('Razon de la Solicitud:');
    $lbl_razon->get_style_context()->add_class('campo-label');
    $lbl_razon->set_halign('end');
    my $entry_razon = Gtk3::Entry->new();
    $entry_razon->set_placeholder_text('Motivo del reabastecimiento...');
    $entry_razon->set_hexpand(TRUE);

    my $btn_solicitar =
      interfaz::usuario::common::boton( 'Enviar Solicitud', 'boton-primario' );
    my $lbl_mensaje = Gtk3::Label->new('');
    $lbl_mensaje->set_line_wrap(TRUE);

    my $row = 0;
    $grid->attach( $lbl_codigo,   0, $row, 1, 1 );
    $grid->attach( $entry_codigo, 1, $row, 2, 1 );
    $grid->attach( $btn_buscar,   3, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_info, 1, $row, 3, 1 );
    $row++;
    $grid->attach( $lbl_cantidad,  0, $row, 1, 1 );
    $grid->attach( $spin_cantidad, 1, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_prioridad,   0, $row, 1, 1 );
    $grid->attach( $combo_prioridad, 1, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_razon,   0, $row, 1, 1 );
    $grid->attach( $entry_razon, 1, $row, 3, 1 );
    $row++;
    $grid->attach( $btn_solicitar, 1, $row, 2, 1 );
    $row++;
    $grid->attach( $lbl_mensaje, 1, $row, 3, 1 );

    my $medicamento_actual;

    $btn_buscar->signal_connect(
        clicked => sub {
            my $codigo = $entry_codigo->get_text();
            $codigo =~ s/^\s+|\s+$//g;

            if ( !$codigo ) {
                $lbl_info->set_text('Ingrese un codigo de medicamento.');
                return;
            }

            my $dato = $lista_med->buscar_por_codigo($codigo);
            if ($dato) {
                $medicamento_actual = $dato;
                my $stock  = $dato->{cantidad}     // 0;
                my $minimo = $dato->{nivel_minimo} // 0;
                my $alerta = ( $stock < $minimo ) ? ' (STOCK CRITICO)' : '';
                $lbl_info->set_text( "Nombre: $dato->{nombre}\n"
                      . "Stock actual: $stock unidades$alerta\n"
                      . "Nivel minimo: $minimo" );
            }
            else {
                $lbl_info->set_text("Medicamento '$codigo' no encontrado.");
                $medicamento_actual = undef;
            }
        }
    );

    $btn_solicitar->signal_connect(
        clicked => sub {
            my $codigo = $entry_codigo->get_text();
            $codigo =~ s/^\s+|\s+$//g;

            if ( !$codigo ) {
                interfaz::usuario::common::mensaje( $lbl_mensaje,
                    'Debe buscar y seleccionar un medicamento primero.', 1 );
                return;
            }

            if ( !$medicamento_actual ) {
                interfaz::usuario::common::mensaje( $lbl_mensaje,
                    'El medicamento no es valido. Busquelo nuevamente.', 1 );
                return;
            }

            my $cantidad  = $spin_cantidad->get_value();
            my $prioridad = $combo_prioridad->get_active_text();
            my $razon     = $entry_razon->get_text();

            if ( !$razon ) {
                interfaz::usuario::common::mensaje( $lbl_mensaje,
                    'Debe proporcionar una razon para la solicitud.', 1 );
                return;
            }

            eval {
                _guardar_solicitud( $nodo, $codigo, $cantidad, $prioridad,
                    $razon );
            };

            if ($@) {
                interfaz::usuario::common::mensaje( $lbl_mensaje,
                    "Error al enviar solicitud: $@", 1 );
            }
            else {
                interfaz::usuario::common::mensaje(
                    $lbl_mensaje,
'Solicitud enviada exitosamente. Esperando aprobacion del administrador.',
                    0
                );
                $entry_codigo->set_text('');
                $entry_razon->set_text('');
                $spin_cantidad->set_value(10);
                $combo_prioridad->set_active(1);
                $lbl_info->set_text('');
                $medicamento_actual = undef;
            }
        }
    );

    $vbox->pack_start( $grid, FALSE, FALSE, 0 );
    return $vbox;
}

sub _tab_historial_solicitudes {
    my ($ctx)     = @_;
    my $nodo      = $ctx->{nodo};
    my $lista_med = $ctx->{med};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(12);
    $vbox->set_margin_bottom(12);

    my $titulo = Gtk3::Label->new('Historial de Solicitudes');
    $titulo->get_style_context()->add_class('tarjeta-titulo');
    $titulo->set_halign('start');
    $vbox->pack_start( $titulo, FALSE, FALSE, 0 );

    my $store = Gtk3::ListStore->new(
        'Glib::String',    # Fecha
        'Glib::String',    # Codigo
        'Glib::String',    # Nombre
        'Glib::String',    # Cantidad
        'Glib::String',    # Prioridad
        'Glib::String',    # Estado
        'Glib::String'     # Razon
    );

    my $view = Gtk3::TreeView->new($store);
    $view->set_hexpand(TRUE);
    $view->get_selection()->set_mode('single');

    my @headers = (
        'Fecha',     'Codigo', 'Nombre', 'Cantidad',
        'Prioridad', 'Estado', 'Razon'
    );
    for my $i ( 0 .. $#headers ) {
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers[$i],
            Gtk3::CellRendererText->new(),
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(80);

        if ( $i == 5 ) {
            $col->set_cell_data_func(
                Gtk3::CellRendererText->new(),
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, 5 );
                    if ( $e eq 'Aprobado' ) {
                        $r2->set( foreground => '#10b981' );
                    }
                    elsif ( $e eq 'Rechazado' ) {
                        $r2->set( foreground => '#dc2626' );
                    }
                    else {
                        $r2->set( foreground => '#d97706' );
                    }
                }
            );
        }
        $view->append_column($col);
    }

    my $sc = Gtk3::ScrolledWindow->new();
    $sc->set_policy( 'automatic', 'automatic' );
    $sc->set_vexpand(TRUE);
    $sc->set_min_content_height(300);
    $sc->add($view);

    my $btn_recargar = interfaz::usuario::common::boton( 'Recargar Historial',
        'boton-secundario' );

    my $recargar_historial = sub {
        $store->clear();
        my $solicitudes = _obtener_solicitudes_departamento($nodo);

        for my $s ( reverse @$solicitudes ) {
            my $iter   = $store->append();
            my $nombre = '';
            if ($lista_med) {
                my $med =
                  $lista_med->buscar_por_codigo( $s->{codigo_medicamento} );
                $nombre = $med->{nombre} if $med;
            }
            $store->set(
                $iter,                    0, $s->{fecha_solicitud}, 1,
                $s->{codigo_medicamento}, 2, $nombre,               3,
                $s->{cantidad},           4, $s->{prioridad},       5,
                $s->{estado},             6, $s->{razon}
            );
        }
    };

    $btn_recargar->signal_connect( clicked => $recargar_historial );
    $recargar_historial->();

    $vbox->pack_start( $btn_recargar, FALSE, FALSE, 0 );
    $vbox->pack_start( $sc,           TRUE,  TRUE,  0 );

    return $vbox;
}

sub _guardar_solicitud {
    my ( $nodo, $codigo, $cantidad, $prioridad, $razon ) = @_;

    my $departamento    = $nodo->{departamento};
    my $fecha_solicitud = localtime->strftime("%Y-%m-%d %H:%M:%S");
    my $ug              = Data::UUID->new;
    my $uuid            = $ug->create_str;

    my $ruta_base    = "datos/solicitudes";
    my $ruta_dep     = "$ruta_base/$departamento";
    my $ruta_archivo = "$ruta_dep/solicitudes.json";
    my $ruta_admin   = "$ruta_base/todas_solicitudes.json";

    unless ( -d $ruta_dep ) {
        make_path($ruta_dep);
    }

    my $solicitudes_existentes = _leer_json($ruta_archivo);

    my $nueva_solicitud = {
        uuid               => $uuid,
        codigo_medicamento => $codigo,
        cantidad           => $cantidad,
        prioridad          => $prioridad,
        razon              => $razon,
        estado             => 'Pendiente',
        fecha_solicitud    => $fecha_solicitud,
        departamento       => $departamento,
        solicitante        => $nodo->{nombre},
        colegio            => $nodo->{colegio}
    };

    push @$solicitudes_existentes, $nueva_solicitud;
    _guardar_json( $ruta_archivo, $solicitudes_existentes );

    my $todas_solicitudes = _leer_json($ruta_admin);
    push @$todas_solicitudes, $nueva_solicitud;
    _guardar_json( $ruta_admin, $todas_solicitudes );

    return 1;
}

sub _obtener_solicitudes_departamento {
    my ($nodo)       = @_;
    my $departamento = $nodo->{departamento};
    my $ruta         = "datos/solicitudes/$departamento/solicitudes.json";
    return _leer_json($ruta);
}

sub _leer_json {
    my ($ruta) = @_;
    return [] unless -e $ruta;
    open my $fh, '<:encoding(UTF-8)', $ruta or return [];
    local $/;
    my $texto = <$fh>;
    close $fh;
    eval { return decode_json($texto) };
    return [];
}

sub _guardar_json {
    my ( $ruta, $datos ) = @_;
    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($datos);
    close $fh;
}

1;
