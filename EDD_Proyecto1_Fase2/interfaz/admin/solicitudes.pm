#!/usr/bin/perl
package interfaz::admin::solicitudes;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use JSON::PP;
use Time::Piece;
use interfaz::admin::common;
use utilidades::leer_json;

sub crear_tab {
    my ($ctx)      = @_;
    my $lista_med  = $ctx->{med};
    my $lista_prov = $ctx->{prov};

    my $vbox = Gtk3::Box->new( 'vertical', 10 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    my $notebook = Gtk3::Notebook->new();

    my $tab_pendientes = _tab_solicitudes_pendientes($ctx);
    $notebook->append_page( $tab_pendientes,
        interfaz::admin::common::tab_label('Solicitudes Pendientes') );

    my $tab_historial = _tab_historial_global($ctx);
    $notebook->append_page( $tab_historial,
        interfaz::admin::common::tab_label('Historial Global') );

    my $tab_pedidos = _tab_pedidos_proveedores($ctx);
    $notebook->append_page( $tab_pedidos,
        interfaz::admin::common::tab_label('Pedidos a Proveedores') );

    my $tab_nuevo_pedido = _tab_nuevo_pedido($ctx);
    $notebook->append_page( $tab_nuevo_pedido,
        interfaz::admin::common::tab_label('Nuevo Pedido a Proveedor') );

    $vbox->pack_start( $notebook, TRUE, TRUE, 0 );
    return $vbox;
}

sub _tab_solicitudes_pendientes {
    my ($ctx) = @_;
    my $lista_med = $ctx->{med};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(12);
    $vbox->set_margin_bottom(12);

    my $frame = Gtk3::Frame->new('Solicitudes Pendientes de Aprobacion');
    $frame->set_shadow_type('etched-in');

    my $inner = Gtk3::Box->new( 'vertical', 8 );
    $inner->set_margin_start(12);
    $inner->set_margin_end(12);
    $inner->set_margin_top(12);
    $inner->set_margin_bottom(12);

    my $store = Gtk3::ListStore->new(
        'Glib::String',    # UUID
        'Glib::String',    # Fecha
        'Glib::String',    # Departamento
        'Glib::String',    # Solicitante
        'Glib::String',    # Codigo
        'Glib::String',    # Nombre
        'Glib::String',    # Cantidad
        'Glib::String',    # Prioridad
        'Glib::String'     # Razon
    );

    my $view = Gtk3::TreeView->new($store);
    $view->set_hexpand(TRUE);
    $view->get_selection()->set_mode('single');

    my @headers = (
        'UUID',   'Fecha',  'Departamento', 'Solicitante',
        'Codigo', 'Nombre', 'Cantidad',     'Prioridad',
        'Razon'
    );
    for my $i ( 0 .. $#headers ) {
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers[$i],
            Gtk3::CellRendererText->new(),
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(80);
        if ( $i == 7 ) {
            $col->set_cell_data_func(
                Gtk3::CellRendererText->new(),
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, 7 );
                    if ( $e eq 'Urgente' ) {
                        $r2->set( foreground => '#dc2626' );
                    }
                    elsif ( $e eq 'Alta' ) {
                        $r2->set( foreground => '#d97706' );
                    }
                    else {
                        $r2->set( foreground => '#15803d' );
                    }
                }
            );
        }
        $view->append_column($col);
    }

    my $sc = Gtk3::ScrolledWindow->new();
    $sc->set_policy( 'automatic', 'automatic' );
    $sc->set_vexpand(TRUE);
    $sc->set_min_content_height(400);
    $sc->add($view);

    my $hb = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_aprobar =
      interfaz::admin::common::boton( 'Aprobar Solicitud', 'boton-primario' );
    my $btn_rechazar =
      interfaz::admin::common::boton( 'Rechazar Solicitud', 'boton-peligro' );
    my $btn_recargar =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );
    $hb->pack_start( $btn_aprobar,  FALSE, FALSE, 0 );
    $hb->pack_start( $btn_rechazar, FALSE, FALSE, 0 );
    $hb->pack_start( $btn_recargar, FALSE, FALSE, 0 );

    my $lbl_mensaje = Gtk3::Label->new('');
    $lbl_mensaje->set_line_wrap(TRUE);

    my $recargar_lista = sub {
        $store->clear();
        my $solicitudes = _obtener_todas_solicitudes();
        for my $s (@$solicitudes) {
            next unless $s->{estado} eq 'Pendiente';
            my $iter   = $store->append();
            my $nombre = '';
            if ($lista_med) {
                my $med =
                  $lista_med->buscar_por_codigo( $s->{codigo_medicamento} );
                $nombre = $med->{nombre} if $med;
            }
            $store->set(
                $iter,                 0, $s->{uuid},               1,
                $s->{fecha_solicitud}, 2, $s->{departamento},       3,
                $s->{solicitante},     4, $s->{codigo_medicamento}, 5,
                $nombre,               6, $s->{cantidad},           7,
                $s->{prioridad},       8, $s->{razon}
            );
        }
    };

    $btn_recargar->signal_connect( clicked => $recargar_lista );

    $btn_aprobar->signal_connect(
        clicked => sub {
            my ( $model, $iter ) = $view->get_selection()->get_selected();
            if ( !$iter ) {
                $lbl_mensaje->set_text(
                    'Seleccione una solicitud para aprobar.');
                return;
            }
            my $uuid     = $model->get_value( $iter, 0 );
            my $codigo   = $model->get_value( $iter, 4 );
            my $cantidad = $model->get_value( $iter, 6 );

            _cambiar_estado_solicitud( $uuid, 'Aprobado' );
            _generar_pedido_proveedor( $codigo, $cantidad,
                $model->get_value( $iter, 2 ) );

            $lbl_mensaje->set_text(
                'Solicitud aprobada. Se ha generado el pedido al proveedor.');
            $recargar_lista->();
        }
    );

    $btn_rechazar->signal_connect(
        clicked => sub {
            my ( $model, $iter ) = $view->get_selection()->get_selected();
            if ( !$iter ) {
                $lbl_mensaje->set_text(
                    'Seleccione una solicitud para rechazar.');
                return;
            }
            my $uuid = $model->get_value( $iter, 0 );
            _cambiar_estado_solicitud( $uuid, 'Rechazado' );
            $lbl_mensaje->set_text('Solicitud rechazada.');
            $recargar_lista->();
        }
    );

    $recargar_lista->();

    $inner->pack_start( $sc,          TRUE,  TRUE,  0 );
    $inner->pack_start( $hb,          FALSE, FALSE, 0 );
    $inner->pack_start( $lbl_mensaje, FALSE, FALSE, 0 );
    $frame->add($inner);
    $vbox->pack_start( $frame, TRUE, TRUE, 0 );
    return $vbox;
}

sub _tab_historial_global {
    my ($ctx) = @_;
    my $lista_med = $ctx->{med};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(12);
    $vbox->set_margin_bottom(12);

    my $frame = Gtk3::Frame->new('Historial Global de Solicitudes');
    $frame->set_shadow_type('etched-in');

    my $inner = Gtk3::Box->new( 'vertical', 8 );
    $inner->set_margin_start(12);
    $inner->set_margin_end(12);
    $inner->set_margin_top(12);
    $inner->set_margin_bottom(12);

    my $store = Gtk3::ListStore->new(
        'Glib::String',    # Fecha
        'Glib::String',    # Departamento
        'Glib::String',    # Solicitante
        'Glib::String',    # Codigo
        'Glib::String',    # Nombre
        'Glib::String',    # Cantidad
        'Glib::String',    # Estado
        'Glib::String'     # Razon
    );

    my $view = Gtk3::TreeView->new($store);
    $view->set_hexpand(TRUE);
    $view->get_selection()->set_mode('single');

    my @headers = (
        'Fecha',  'Departamento', 'Solicitante', 'Codigo',
        'Nombre', 'Cantidad',     'Estado',      'Razon'
    );
    for my $i ( 0 .. $#headers ) {
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers[$i],
            Gtk3::CellRendererText->new(),
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(80);
        if ( $i == 6 ) {
            $col->set_cell_data_func(
                Gtk3::CellRendererText->new(),
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, 6 );
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
    $sc->set_min_content_height(400);
    $sc->add($view);

    my $btn_recargar =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );

    my $recargar_lista = sub {
        $store->clear();
        my $solicitudes = _obtener_todas_solicitudes();
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
                $s->{departamento},       2, $s->{solicitante},     3,
                $s->{codigo_medicamento}, 4, $nombre,               5,
                $s->{cantidad},           6, $s->{estado},          7,
                $s->{razon}
            );
        }
    };

    $btn_recargar->signal_connect( clicked => $recargar_lista );
    $recargar_lista->();

    $inner->pack_start( $sc,           TRUE,  TRUE,  0 );
    $inner->pack_start( $btn_recargar, FALSE, FALSE, 0 );
    $frame->add($inner);
    $vbox->pack_start( $frame, TRUE, TRUE, 0 );
    return $vbox;
}

sub _tab_pedidos_proveedores {
    my ($ctx) = @_;

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(12);
    $vbox->set_margin_bottom(12);

    my $frame = Gtk3::Frame->new('Pedidos a Proveedores');
    $frame->set_shadow_type('etched-in');

    my $inner = Gtk3::Box->new( 'vertical', 8 );
    $inner->set_margin_start(12);
    $inner->set_margin_end(12);
    $inner->set_margin_top(12);
    $inner->set_margin_bottom(12);

    my $store = Gtk3::ListStore->new(
        'Glib::String',    # Fecha
        'Glib::String',    # Proveedor
        'Glib::String',    # Medicamento
        'Glib::String',    # Cantidad
        'Glib::String',    # Estado
        'Glib::String'     # Departamento
    );

    my $view = Gtk3::TreeView->new($store);
    $view->set_hexpand(TRUE);
    $view->get_selection()->set_mode('single');

    my @headers = (
        'Fecha',  'Proveedor', 'Medicamento', 'Cantidad',
        'Estado', 'Departamento'
    );
    for my $i ( 0 .. $#headers ) {
        my $col =
          Gtk3::TreeViewColumn->new_with_attributes( $headers[$i],
            Gtk3::CellRendererText->new(),
            text => $i );
        $col->set_resizable(TRUE);
        $col->set_min_width(100);
        if ( $i == 4 ) {
            $col->set_cell_data_func(
                Gtk3::CellRendererText->new(),
                sub {
                    my ( $c, $r2, $m, $it ) = @_;
                    my $e = $m->get_value( $it, 4 );
                    if ( $e eq 'Entregado' ) {
                        $r2->set( foreground => '#10b981' );
                    }
                    elsif ( $e eq 'Pendiente' ) {
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
    $sc->set_min_content_height(400);
    $sc->add($view);

    my $hb = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_recargar =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );
    my $btn_marcar_entregado =
      interfaz::admin::common::boton( 'Marcar como Entregado',
        'boton-primario' );
    $hb->pack_start( $btn_recargar,         FALSE, FALSE, 0 );
    $hb->pack_start( $btn_marcar_entregado, FALSE, FALSE, 0 );

    my $recargar_pedidos = sub {
        $store->clear();
        my $pedidos = _obtener_pedidos();
        for my $p (@$pedidos) {
            my $iter = $store->append();
            $store->set(
                $iter,              0,
                $p->{fecha_pedido}, 1,
                $p->{proveedor},    2,
                $p->{medicamento},  3,
                $p->{cantidad},     4,
                $p->{estado},       5,
                $p->{departamento} // 'Administracion'
            );
        }
    };

    $btn_recargar->signal_connect( clicked => $recargar_pedidos );

    $btn_marcar_entregado->signal_connect(
        clicked => sub {
            my ( $model, $iter ) = $view->get_selection()->get_selected();
            if ( !$iter ) {
                interfaz::admin::common::msg_info(
                    "Seleccione un pedido para marcar como entregado.");
                return;
            }
            my $proveedor   = $model->get_value( $iter, 1 );
            my $medicamento = $model->get_value( $iter, 2 );
            my $cantidad    = $model->get_value( $iter, 3 );

            _marcar_pedido_entregado( $proveedor, $medicamento, $cantidad );
            _actualizar_inventario( $medicamento, $cantidad );

            $recargar_pedidos->();
            interfaz::admin::common::msg_info(
                "Pedido marcado como entregado. Inventario actualizado.");
        }
    );

    $recargar_pedidos->();

    $inner->pack_start( $sc, TRUE,  TRUE,  0 );
    $inner->pack_start( $hb, FALSE, FALSE, 0 );
    $frame->add($inner);
    $vbox->pack_start( $frame, TRUE, TRUE, 0 );
    return $vbox;
}

sub _tab_nuevo_pedido {
    my ($ctx)      = @_;
    my $lista_med  = $ctx->{med};
    my $lista_prov = $ctx->{prov};

    my $vbox = Gtk3::Box->new( 'vertical', 12 );
    $vbox->set_margin_start(20);
    $vbox->set_margin_end(20);
    $vbox->set_margin_top(16);
    $vbox->set_margin_bottom(16);

    my $frame = Gtk3::Frame->new('Realizar Pedido Directo a Proveedor');
    $frame->set_shadow_type('etched-in');

    my $inner = Gtk3::Box->new( 'vertical', 12 );
    $inner->set_margin_start(20);
    $inner->set_margin_end(20);
    $inner->set_margin_top(16);
    $inner->set_margin_bottom(16);

    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(10);
    $grid->set_column_spacing(12);

    my $lbl_prov = Gtk3::Label->new('Seleccionar Proveedor:');
    $lbl_prov->get_style_context()->add_class('campo-label');
    $lbl_prov->set_halign('end');
    my $combo_prov = Gtk3::ComboBoxText->new();
    $combo_prov->set_hexpand(TRUE);

    my $proveedores = $lista_prov->almacenar_array_simple();
    for my $prov (@$proveedores) {
        $combo_prov->append_text(
            $prov->{nombre} . ' (' . ( $prov->{nit} // '' ) . ')' );
    }
    $combo_prov->set_active(0)
      if $combo_prov->get_model()->iter_n_children() > 0;

    my $lbl_med = Gtk3::Label->new('Codigo del Medicamento:');
    $lbl_med->get_style_context()->add_class('campo-label');
    $lbl_med->set_halign('end');
    my $entry_codigo = Gtk3::Entry->new();
    $entry_codigo->set_placeholder_text('Ej: MED-001');
    $entry_codigo->set_hexpand(TRUE);

    my $btn_buscar = interfaz::admin::common::boton( 'Buscar Medicamento',
        'boton-secundario' );
    my $lbl_info = Gtk3::Label->new('');
    $lbl_info->set_line_wrap(TRUE);
    $lbl_info->get_style_context()->add_class('valor-label');

    my $lbl_cantidad = Gtk3::Label->new('Cantidad a Pedir:');
    $lbl_cantidad->get_style_context()->add_class('campo-label');
    $lbl_cantidad->set_halign('end');
    my $spin_cantidad = Gtk3::SpinButton->new_with_range( 1, 100000, 1 );
    $spin_cantidad->set_value(100);

    my $lbl_razon = Gtk3::Label->new('Motivo del Pedido:');
    $lbl_razon->get_style_context()->add_class('campo-label');
    $lbl_razon->set_halign('end');
    my $entry_razon = Gtk3::Entry->new();
    $entry_razon->set_placeholder_text('Razon del pedido...');
    $entry_razon->set_hexpand(TRUE);

    my $btn_pedir =
      interfaz::admin::common::boton( 'Realizar Pedido', 'boton-primario' );
    my $lbl_mensaje = Gtk3::Label->new('');
    $lbl_mensaje->set_line_wrap(TRUE);

    my $row = 0;
    $grid->attach( $lbl_prov,   0, $row, 1, 1 );
    $grid->attach( $combo_prov, 1, $row, 2, 1 );
    $row++;
    $grid->attach( $lbl_med,      0, $row, 1, 1 );
    $grid->attach( $entry_codigo, 1, $row, 1, 1 );
    $grid->attach( $btn_buscar,   2, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_info, 1, $row, 2, 1 );
    $row++;
    $grid->attach( $lbl_cantidad,  0, $row, 1, 1 );
    $grid->attach( $spin_cantidad, 1, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_razon,   0, $row, 1, 1 );
    $grid->attach( $entry_razon, 1, $row, 2, 1 );
    $row++;
    $grid->attach( $btn_pedir, 1, $row, 1, 1 );
    $row++;
    $grid->attach( $lbl_mensaje, 1, $row, 2, 1 );

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
                      . "Nivel minimo: $minimo\n"
                      . "Proveedor sugerido: "
                      . ( $dato->{fabricante} // 'No especificado' ) );
            }
            else {
                $lbl_info->set_text("Medicamento '$codigo' no encontrado.");
                $medicamento_actual = undef;
            }
        }
    );

    $btn_pedir->signal_connect(
        clicked => sub {
            my $codigo = $entry_codigo->get_text();
            $codigo =~ s/^\s+|\s+$//g;

            if ( !$codigo ) {
                interfaz::admin::common::mensaje( $lbl_mensaje,
                    'Debe buscar y seleccionar un medicamento primero.', 1 );
                return;
            }

            if ( !$medicamento_actual ) {
                interfaz::admin::common::mensaje( $lbl_mensaje,
                    'El medicamento no es valido. Busquelo nuevamente.', 1 );
                return;
            }

            my $cantidad         = $spin_cantidad->get_value();
            my $razon            = $entry_razon->get_text();
            my $proveedor_nombre = $combo_prov->get_active_text();
            $proveedor_nombre =~ s/\s*\(.*\)//;

            if ( !$razon ) {
                interfaz::admin::common::mensaje( $lbl_mensaje,
                    'Debe proporcionar una razon para el pedido.', 1 );
                return;
            }

            eval {
                _generar_pedido_directo( $proveedor_nombre, $codigo,
                    $medicamento_actual->{nombre},
                    $cantidad, $razon );
            };

            if ($@) {
                interfaz::admin::common::mensaje( $lbl_mensaje,
                    "Error al realizar pedido: $@", 1 );
            }
            else {
                interfaz::admin::common::mensaje(
                    $lbl_mensaje,
"Pedido realizado exitosamente al proveedor $proveedor_nombre.",
                    0
                );
                $entry_codigo->set_text('');
                $entry_razon->set_text('');
                $spin_cantidad->set_value(100);
                $lbl_info->set_text('');
                $medicamento_actual = undef;
            }
        }
    );

    $inner->pack_start( $grid, FALSE, FALSE, 0 );
    $frame->add($inner);
    $vbox->pack_start( $frame, TRUE, TRUE, 0 );
    return $vbox;
}

sub _obtener_todas_solicitudes {
    my $ruta = "datos/solicitudes/todas_solicitudes.json";
    return [] unless -e $ruta;
    open my $fh, '<:encoding(UTF-8)', $ruta or return [];
    local $/;
    my $texto = <$fh>;
    close $fh;
    eval { return decode_json($texto) };
    return [];
}

sub _cambiar_estado_solicitud {
    my ( $uuid, $estado ) = @_;

    my $ruta        = "datos/solicitudes/todas_solicitudes.json";
    my $solicitudes = _obtener_todas_solicitudes();

    for my $s (@$solicitudes) {
        if ( $s->{uuid} eq $uuid ) {
            $s->{estado} = $estado;
            last;
        }
    }

    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($solicitudes);
    close $fh;

    my $dep      = $solicitudes->[0]->{departamento};
    my $ruta_dep = "datos/solicitudes/$dep/solicitudes.json";
    if ( -e $ruta_dep ) {
        open my $fh2, '<:encoding(UTF-8)', $ruta_dep;
        local $/;
        my $texto = <$fh2>;
        close $fh2;
        my $dep_solicitudes = decode_json($texto);
        for my $s (@$dep_solicitudes) {
            if ( $s->{uuid} eq $uuid ) {
                $s->{estado} = $estado;
                last;
            }
        }
        open my $fh3, '>:encoding(UTF-8)', $ruta_dep;
        print $fh3 $json->encode($dep_solicitudes);
        close $fh3;
    }
}

sub _generar_pedido_proveedor {
    my ( $codigo_medicamento, $cantidad, $departamento ) = @_;

    my $proveedor   = _buscar_proveedor_medicamento($codigo_medicamento);
    my $medicamento = _buscar_nombre_medicamento($codigo_medicamento);

    my $ruta    = "datos/pedidos.json";
    my $pedidos = [];
    if ( -e $ruta ) {
        open my $fh, '<:encoding(UTF-8)', $ruta;
        local $/;
        my $texto = <$fh>;
        close $fh;
        eval { $pedidos = decode_json($texto) };
    }

    my $fecha = localtime->strftime("%Y-%m-%d %H:%M:%S");
    push @$pedidos,
      {
        fecha_pedido       => $fecha,
        proveedor          => $proveedor,
        medicamento        => $medicamento,
        codigo_medicamento => $codigo_medicamento,
        cantidad           => $cantidad,
        estado             => 'Pendiente',
        departamento       => $departamento,
        tipo               => 'Solicitud Aprobada'
      };

    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($pedidos);
    close $fh;
}

sub _generar_pedido_directo {
    my ( $proveedor, $codigo, $nombre, $cantidad, $razon ) = @_;

    my $ruta    = "datos/pedidos.json";
    my $pedidos = [];
    if ( -e $ruta ) {
        open my $fh, '<:encoding(UTF-8)', $ruta;
        local $/;
        my $texto = <$fh>;
        close $fh;
        eval { $pedidos = decode_json($texto) };
    }

    my $fecha = localtime->strftime("%Y-%m-%d %H:%M:%S");
    push @$pedidos,
      {
        fecha_pedido       => $fecha,
        proveedor          => $proveedor,
        medicamento        => $nombre,
        codigo_medicamento => $codigo,
        cantidad           => $cantidad,
        estado             => 'Pendiente',
        razon              => $razon,
        tipo               => 'Pedido Directo'
      };

    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($pedidos);
    close $fh;
}

sub _buscar_proveedor_medicamento {
    my ($codigo) = @_;
    my $ruta = "datos/proveedores.json";
    return 'Proveedor Generico' unless -e $ruta;

    open my $fh, '<:encoding(UTF-8)', $ruta;
    local $/;
    my $texto = <$fh>;
    close $fh;
    my $proveedores = decode_json($texto);

    for my $prov (@$proveedores) {
        my $entregas = $prov->{entregas} // [];
        for my $entrega (@$entregas) {
            if ( $entrega->{codigo} eq $codigo ) {
                return $prov->{nombre};
            }
        }
    }
    return 'Proveedor Generico';
}

sub _buscar_nombre_medicamento {
    my ($codigo) = @_;
    my $ruta = "datos/inventario.json";
    return $codigo unless -e $ruta;

    open my $fh, '<:encoding(UTF-8)', $ruta;
    local $/;
    my $texto = <$fh>;
    close $fh;
    my $inventario = decode_json($texto);

    for my $med (@$inventario) {
        if ( $med->{codigo} eq $codigo ) {
            return $med->{nombre};
        }
    }
    return $codigo;
}

sub _obtener_pedidos {
    my $ruta = "datos/pedidos.json";
    return [] unless -e $ruta;
    open my $fh, '<:encoding(UTF-8)', $ruta;
    local $/;
    my $texto = <$fh>;
    close $fh;
    eval { return decode_json($texto) };
    return [];
}

sub _marcar_pedido_entregado {
    my ( $proveedor, $medicamento, $cantidad ) = @_;

    my $ruta    = "datos/pedidos.json";
    my $pedidos = _obtener_pedidos();

    for my $p (@$pedidos) {
        if (   $p->{proveedor} eq $proveedor
            && $p->{medicamento} eq $medicamento
            && $p->{estado} eq 'Pendiente' )
        {
            $p->{estado} = 'Entregado';
            last;
        }
    }

    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh $json->encode($pedidos);
    close $fh;
}

sub _actualizar_inventario {
    my ( $medicamento, $cantidad ) = @_;

    my $ruta = "datos/inventario.json";
    return unless -e $ruta;

    open my $fh, '<:encoding(UTF-8)', $ruta;
    local $/;
    my $texto = <$fh>;
    close $fh;
    my $inventario = decode_json($texto);

    for my $med (@$inventario) {
        if ( $med->{nombre} eq $medicamento ) {
            $med->{cantidad} += $cantidad;
            last;
        }
    }

    my $json = JSON::PP->new->utf8->pretty->canonical(1);
    open my $fh2, '>:encoding(UTF-8)', $ruta or die "No se pudo escribir: $!";
    print $fh2 $json->encode($inventario);
    close $fh2;
}

1;
