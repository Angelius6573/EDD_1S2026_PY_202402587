#!/usr/bin/perl
package interfaz::admin::personal_medico;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use FindBin;
use lib $FindBin::Bin;
use Gtk3;
use Glib qw(TRUE FALSE);
use interfaz::admin::common;
use utilidades::leer_json;

sub crear_tab {
    my ($ctx) = @_;
    my $avl = $ctx->{avl};

    my $vbox = Gtk3::Box->new( 'vertical', 8 );
    $vbox->set_margin_start(12);
    $vbox->set_margin_end(12);
    $vbox->set_margin_top(10);
    $vbox->set_margin_bottom(10);

    # ── Tabla + filtro ──────────────────────────────────────────────────────
    my $store = Gtk3::ListStore->new(
        'Glib::String', 'Glib::String', 'Glib::String', 'Glib::String',
        'Glib::String'
    );
    _recargar_tabla( $store, $avl );

    my $filter = Gtk3::TreeModelFilter->new( $store, undef );

    # Variables de filtro compartidas por closure con los widgets de filtro
    my ( $f_dpto, $f_tipo, $f_esp ) = ( '', '', '' );
    $filter->set_visible_func(
        sub {
            my ( $model, $iter ) = @_;
            return TRUE if !$f_dpto && !$f_tipo && !$f_esp;
            my $dpto = $model->get_value( $iter, 3 ) // '';
            my $tipo = $model->get_value( $iter, 2 ) // '';
            my $esp  = $model->get_value( $iter, 4 ) // '';
            return FALSE if $f_dpto && $dpto ne $f_dpto;
            return FALSE if $f_tipo && $tipo ne $f_tipo;
            return FALSE if $f_esp  && index( lc($esp), lc($f_esp) ) == -1;
            return TRUE;
        }
    );

    my $view = interfaz::admin::common::crear_vista_generica(
        $filter,
        [
            'Nº Colegio', 'Nombre Completo',
            'Tipo',       'Departamento',
            'Especialidad'
        ]
    );

    # ── Barra de filtros (conectada al filter closure) ──────────────────────
    my $hfilt = Gtk3::Box->new( 'horizontal', 8 );
    my $lf    = Gtk3::Label->new('Filtrar:');
    $lf->get_style_context()->add_class('campo-label');

    my $combo_dpto = Gtk3::ComboBoxText->new();
    $combo_dpto->append_text('Todos los departamentos');
    $combo_dpto->append_text($_)
      for qw(DEP-ADM DEP-MED DEP-CIR DEP-LAB DEP-FAR);
    $combo_dpto->set_active(0);

    my $combo_tipo = Gtk3::ComboBoxText->new();
    $combo_tipo->append_text('Todos los tipos');
    $combo_tipo->append_text($_)
      for qw(TIPO-01 TIPO-02 TIPO-03 TIPO-04 TIPO-05);
    $combo_tipo->set_active(0);

    my $entry_esp = Gtk3::Entry->new();
    $entry_esp->set_placeholder_text('Especialidad...');
    $entry_esp->set_size_request( 140, -1 );

    my $btn_filt =
      interfaz::admin::common::boton( 'Aplicar filtro', 'boton-secundario' );
    my $btn_limpiar =
      interfaz::admin::common::boton( 'Limpiar', 'boton-secundario' );

    $btn_filt->signal_connect(
        clicked => sub {
            my $d = $combo_dpto->get_active_text() // '';
            my $t = $combo_tipo->get_active_text() // '';
            $f_dpto = ( $d =~ /^DEP-/ )  ? $d : '';
            $f_tipo = ( $t =~ /^TIPO-/ ) ? $t : '';
            $f_esp  = $entry_esp->get_text() // '';
            $filter->refilter();
        }
    );
    $btn_limpiar->signal_connect(
        clicked => sub {
            $combo_dpto->set_active(0);
            $combo_tipo->set_active(0);
            $entry_esp->set_text('');
            ( $f_dpto, $f_tipo, $f_esp ) = ( '', '', '' );
            $filter->refilter();
        }
    );

    $hfilt->pack_start( $lf,          FALSE, FALSE, 0 );
    $hfilt->pack_start( $combo_dpto,  FALSE, FALSE, 0 );
    $hfilt->pack_start( $combo_tipo,  FALSE, FALSE, 0 );
    $hfilt->pack_start( $entry_esp,   FALSE, FALSE, 0 );
    $hfilt->pack_start( $btn_filt,    FALSE, FALSE, 0 );
    $hfilt->pack_start( $btn_limpiar, FALSE, FALSE, 0 );

    # ── Botones de acción ───────────────────────────────────────────────────
    my $hbox = Gtk3::Box->new( 'horizontal', 8 );
    my $btn_nuevo =
      interfaz::admin::common::boton( 'Registrar', 'boton-primario' );
    my $btn_buscar =
      interfaz::admin::common::boton( 'Buscar', 'boton-secundario' );
    my $btn_eliminar =
      interfaz::admin::common::boton( 'Eliminar', 'boton-peligro' );
    my $btn_reload =
      interfaz::admin::common::boton( 'Recargar', 'boton-secundario' );
    $hbox->pack_start( $_, FALSE, FALSE, 0 )
      for ( $btn_nuevo, $btn_buscar, $btn_eliminar, $btn_reload );

    $btn_nuevo->signal_connect(
        clicked => sub { _dialogo_registrar( $ctx, $store, $filter ) } );

    $btn_buscar->signal_connect( clicked => sub { _dialogo_buscar($ctx) } );

    $btn_eliminar->signal_connect(
        clicked => sub {
            my $sel = $view->get_selection();
            my ( $fmodel, $fiter ) = $sel->get_selected();
            if ( defined $fiter ) {
                my $biter   = $filter->convert_iter_to_child_iter($fiter);
                my $colegio = $store->get_value( $biter, 0 );
                interfaz::admin::common::confirmar_y_ejecutar(
                    "¿Eliminar al usuario $colegio del sistema?",
                    sub {
                        $avl->eliminar($colegio);
                        _guardar_usuarios($avl);
                        _recargar_tabla( $store, $avl );
                        $filter->refilter();
                        interfaz::admin::common::msg_info(
                            "Usuario $colegio eliminado correctamente.");
                    }
                );
            }
            else {
                interfaz::admin::common::msg_info(
                    'Selecciona un usuario en la tabla primero.');
            }
        }
    );

    $btn_reload->signal_connect(
        clicked => sub {
            my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio(
                'datos/usuarios.json');
            $avl->cargar_desde_array($datos);
            _recargar_tabla( $store, $avl );
            $filter->refilter();
        }
    );

    # ── Scroll ──────────────────────────────────────────────────────────────
    my $scroll = Gtk3::ScrolledWindow->new();
    $scroll->set_policy( 'automatic', 'automatic' );
    $scroll->set_vexpand(TRUE);
    $scroll->add($view);

    $vbox->pack_start( $hfilt,  FALSE, FALSE, 0 );
    $vbox->pack_start( $hbox,   FALSE, FALSE, 4 );
    $vbox->pack_start( $scroll, TRUE,  TRUE,  0 );
    return $vbox;
}

# ── Helpers privados ─────────────────────────────────────────────────────────

sub _recargar_tabla {
    my ( $store, $avl ) = @_;
    $store->clear();
    $avl->en_orden(
        sub {
            my ($n) = @_;
            my $iter = $store->append();
            $store->set(
                $iter, 0, $n->{colegio} // '', 1,
                $n->{nombre} // '', 2, $n->{tipo} // '', 3,
                $n->{departamento} // '', 4, $n->{especialidad} // ''
            );
        }
    );
}

sub _guardar_usuarios {
    my ($avl) = @_;
    utilidades::leer_json::guardar_json( 'datos/usuarios.json',
        $avl->a_array_json() );
}

sub _dialogo_registrar {
    my ( $ctx, $store, $filter ) = @_;
    my $avl = $ctx->{avl};

    my $dlg = Gtk3::Dialog->new(
        'Registrar Personal Medico', undef, 'modal',
        '_Cancelar' => 'cancel',
        '_Guardar'  => 'accept'
    );
    $dlg->set_default_size( 420, 480 );
    my $area = $dlg->get_content_area();
    my $vb   = Gtk3::Box->new( 'vertical', 8 );
    $vb->set_margin_start(20);
    $vb->set_margin_end(20);
    $vb->set_margin_top(12);
    $vb->set_margin_bottom(12);

    my ( $e_col, $l_col ) =
      interfaz::admin::common::campo_entry('Numero de Colegio (COL-XXXXX)');
    my ( $e_nom, $l_nom ) =
      interfaz::admin::common::campo_entry('Nombre Completo');
    my ( $e_esp, $l_esp ) =
      interfaz::admin::common::campo_entry('Especialidad (opcional)');
    my ( $e_pas, $l_pas ) =
      interfaz::admin::common::campo_entry( 'Contrasena', 1 );

    my $l_tipo = Gtk3::Label->new('Tipo de Usuario');
    $l_tipo->set_halign('start');
    $l_tipo->get_style_context()->add_class('campo-label');
    my $combo_tipo = Gtk3::ComboBoxText->new();
    $combo_tipo->append_text('TIPO-01 - Medico General');
    $combo_tipo->append_text('TIPO-02 - Medico Especialista/Cirujano');
    $combo_tipo->append_text('TIPO-03 - Enfermero/a');
    $combo_tipo->append_text('TIPO-04 - Tecnico de Laboratorio');
    $combo_tipo->append_text('TIPO-05 - Personal Administrativo');
    $combo_tipo->set_active(0);

    my $l_dep = Gtk3::Label->new('Departamento');
    $l_dep->set_halign('start');
    $l_dep->get_style_context()->add_class('campo-label');
    my $combo_dep = Gtk3::ComboBoxText->new();
    $combo_dep->append_text('DEP-ADM - Administracion');
    $combo_dep->append_text('DEP-MED - Medicina General');
    $combo_dep->append_text('DEP-CIR - Cirugia');
    $combo_dep->append_text('DEP-LAB - Laboratorio');
    $combo_dep->append_text('DEP-FAR - Farmacia');
    $combo_dep->set_active(1);

    my $msg = Gtk3::Label->new('');
    $msg->get_style_context()->add_class('alerta-stock');

    $vb->pack_start( $_, FALSE, FALSE, 0 )
      for (
        $l_col,      $e_col, $l_nom,     $e_nom, $l_tipo,
        $combo_tipo, $l_dep, $combo_dep, $l_esp, $e_esp,
        $l_pas,      $e_pas, $msg
      );
    $area->pack_start( $vb, TRUE, TRUE, 0 );
    $dlg->show_all();

    if ( $dlg->run() eq 'accept' ) {
        my $col    = $e_col->get_text();
        my $nom    = $e_nom->get_text();
        my $esp    = $e_esp->get_text();
        my $pas    = $e_pas->get_text();
        my ($tipo) = ( $combo_tipo->get_active_text() // '' ) =~ /^(TIPO-\d+)/;
        my ($dep)  = ( $combo_dep->get_active_text()  // '' ) =~ /^(DEP-\w+)/;

        if ( !$col || !$nom || !$pas ) {
            interfaz::admin::common::msg_info(
                'Colegio, nombre y contrasena son obligatorios.');
        }
        elsif ( $avl->buscar($col) ) {
            interfaz::admin::common::msg_info(
                "El colegio '$col' ya esta registrado en el sistema.");
        }
        else {
            $avl->insertar(
                colegio      => $col,
                nombre       => $nom,
                tipo         => $tipo // 'TIPO-01',
                departamento => $dep  // 'DEP-MED',
                especialidad => $esp,
                contrasena   => $pas,
            );
            _guardar_usuarios($avl);
            _recargar_tabla( $store, $avl );
            $filter->refilter() if $filter;
            interfaz::admin::common::msg_info(
                "Usuario $col registrado correctamente.");
        }
    }
    $dlg->destroy();
}

sub _dialogo_buscar {
    my ($ctx) = @_;
    my $avl = $ctx->{avl};

    my $dlg = Gtk3::Dialog->new(
        'Buscar Personal Medico', undef, 'modal',
        '_Cerrar' => 'close',
        '_Buscar' => 'accept'
    );
    $dlg->set_default_size( 400, 240 );
    my $area = $dlg->get_content_area();
    my $vb   = Gtk3::Box->new( 'vertical', 10 );
    $vb->set_margin_start(20);
    $vb->set_margin_end(20);
    $vb->set_margin_top(12);

    my ( $e, $l ) =
      interfaz::admin::common::campo_entry('Numero de Colegio (COL-XXXXX)');
    my $resultado = Gtk3::Label->new('');
    $resultado->set_line_wrap(TRUE);
    $resultado->set_max_width_chars(50);

    $vb->pack_start( $l,         FALSE, FALSE, 0 );
    $vb->pack_start( $e,         FALSE, FALSE, 0 );
    $vb->pack_start( $resultado, FALSE, FALSE, 4 );
    $area->pack_start( $vb, TRUE, TRUE, 0 );
    $dlg->show_all();

    while (1) {
        my $resp = $dlg->run();
        last unless $resp eq 'accept';
        my $col  = $e->get_text();
        my $nodo = $avl->buscar($col);
        if ( defined $nodo ) {
            $resultado->set_text( "Nombre:       $nodo->{nombre}\n"
                  . "Tipo:         $nodo->{tipo}\n"
                  . "Departamento: $nodo->{departamento}\n"
                  . "Especialidad: "
                  . ( $nodo->{especialidad} // '—' ) );
        }
        else {
            $resultado->set_text("No se encontro el colegio '$col'.");
        }
    }
    $dlg->destroy();
}

1;
