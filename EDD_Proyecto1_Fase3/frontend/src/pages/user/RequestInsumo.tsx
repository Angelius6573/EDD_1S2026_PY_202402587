import { useEffect, useState } from "react";
import { useAuth } from "../../../hooks/useAuth";
import { api, Equipo, Medicamento, Suministro } from "../../../services/api";
import toast from "react-hot-toast";
import {
  AlertCircle,
  CheckCircle,
  Package,
  Pill,
  Search,
  Send,
  Syringe,
  Wrench,
} from "lucide-react";

type TipoInsumo = "MEDICAMENTO" | "EQUIPO" | "SUMINISTRO";

export default function RequestInsumo() {
  const { user } = useAuth();
  const [tipo, setTipo] = useState<TipoInsumo>("MEDICAMENTO");
  const [codigoBusqueda, setCodigoBusqueda] = useState("");
  const [itemSeleccionado, setItemSeleccionado] = useState<any>(null);
  const [cantidad, setCantidad] = useState<number>(1);
  const [motivo, setMotivo] = useState("");
  const [cargando, setCargando] = useState(false);
  const [buscando, setBuscando] = useState(false);
  const [resultadosBusqueda, setResultadosBusqueda] = useState<any[]>([]);
  const [mostrarResultados, setMostrarResultados] = useState(false);

  // Obtener permisos según departamento del usuario
  const permisos = {
    medicamentos: user?.departamento === "DEP-ADM" ||
      user?.departamento === "DEP-MED" || user?.departamento === "DEP-FAR",
    equipos: user?.departamento === "DEP-ADM" ||
      user?.departamento === "DEP-CIR" || user?.departamento === "DEP-LAB",
    suministros: user?.departamento === "DEP-ADM" ||
      user?.departamento === "DEP-MED" || user?.departamento === "DEP-CIR",
  };

  const buscarItem = async () => {
    if (!codigoBusqueda.trim()) {
      toast.error("Ingrese un código para buscar");
      return;
    }

    setBuscando(true);
    setResultadosBusqueda([]);

    try {
      if (tipo === "MEDICAMENTO" && permisos.medicamentos) {
        const response = await api.getInventarioMedicamentos(codigoBusqueda);
        const items = response.medicamentos || [];
        setResultadosBusqueda(items);
        if (items.length === 0) {
          toast.error(
            `No se encontró medicamento con código "${codigoBusqueda}"`,
          );
        }
      } else if (tipo === "EQUIPO" && permisos.equipos) {
        const response = await api.getInventarioEquipos(codigoBusqueda);
        const items = response.equipos || [];
        setResultadosBusqueda(items);
        if (items.length === 0) {
          toast.error(`No se encontró equipo con código "${codigoBusqueda}"`);
        }
      } else if (tipo === "SUMINISTRO" && permisos.suministros) {
        const response = await api.getInventarioSuministros(codigoBusqueda);
        const items = response.suministros || [];
        setResultadosBusqueda(items);
        if (items.length === 0) {
          toast.error(
            `No se encontró suministro con código "${codigoBusqueda}"`,
          );
        }
      }
      setMostrarResultados(true);
    } catch (error) {
      toast.error("Error al buscar el insumo");
    } finally {
      setBuscando(false);
    }
  };

  const seleccionarItem = (item: any) => {
    setItemSeleccionado(item);
    setMostrarResultados(false);
    setCodigoBusqueda(item.codigo);
    toast.success(`${item.nombre} seleccionado`);
  };

  const enviarSolicitud = async () => {
    if (!itemSeleccionado) {
      toast.error("Seleccione un insumo primero");
      return;
    }

    if (cantidad <= 0) {
      toast.error("La cantidad debe ser mayor a 0");
      return;
    }

    if (cantidad > itemSeleccionado.cantidad) {
      toast.error(
        `Stock insuficiente. Solo hay ${itemSeleccionado.cantidad} unidades disponibles`,
      );
      return;
    }

    if (!motivo.trim()) {
      toast.error("Debe proporcionar un motivo para la solicitud");
      return;
    }

    setCargando(true);
    try {
      const response = await api.solicitarInsumo({
        tipo: tipo,
        codigo: itemSeleccionado.codigo,
        cantidad: cantidad,
        motivo: motivo,
      });

      if (response.success) {
        toast.success("Solicitud enviada correctamente");
        // Limpiar formulario
        setItemSeleccionado(null);
        setCodigoBusqueda("");
        setCantidad(1);
        setMotivo("");
      } else {
        toast.error(response.error || "Error al enviar solicitud");
      }
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al enviar solicitud");
    } finally {
      setCargando(false);
    }
  };

  const getStockStatus = (cantidad: number, nivelMinimo: number) => {
    if (cantidad === 0) {
      return {
        color: "text-red-600",
        bg: "bg-red-100",
        text: "Agotado",
        icon: AlertCircle,
      };
    }
    if (cantidad < nivelMinimo) {
      return {
        color: "text-yellow-600",
        bg: "bg-yellow-100",
        text: "Stock Bajo",
        icon: AlertCircle,
      };
    }
    return {
      color: "text-green-600",
      bg: "bg-green-100",
      text: "Suficiente",
      icon: CheckCircle,
    };
  };

  // Verificar si el usuario tiene algún permiso
  const tienePermiso = permisos.medicamentos || permisos.equipos ||
    permisos.suministros;

  if (!tienePermiso) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="card text-center py-12">
          <AlertCircle className="h-16 w-16 mx-auto text-red-400 mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">
            Sin permisos
          </h2>
          <p className="text-gray-600">
            Su departamento ({user?.departamento || "Sin asignar"}) no tiene
            permisos para solicitar insumos.
          </p>
          <p className="text-sm text-gray-500 mt-2">
            Contacte al administrador para asignarle un departamento con
            permisos.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto">
      <h1 className="text-2xl font-bold text-gray-900 mb-2">
        Solicitar Insumo
      </h1>
      <p className="text-gray-600 mb-6">
        Complete el formulario para solicitar medicamentos, equipos o
        suministros al administrador.
      </p>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="p-6 space-y-6">
          {/* Tipo de insumo */}
          <div>
            <label className="label">Tipo de Insumo</label>
            <div className="flex space-x-2">
              {permisos.medicamentos && (
                <button
                  type="button"
                  onClick={() => {
                    setTipo("MEDICAMENTO");
                    setItemSeleccionado(null);
                    setCodigoBusqueda("");
                    setResultadosBusqueda([]);
                  }}
                  className={`flex-1 py-2 px-4 rounded-lg font-medium transition-all flex items-center justify-center space-x-2 ${
                    tipo === "MEDICAMENTO"
                      ? "bg-green-600 text-white"
                      : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  }`}
                >
                  <Pill size={18} />
                  <span>Medicamento</span>
                </button>
              )}
              {permisos.equipos && (
                <button
                  type="button"
                  onClick={() => {
                    setTipo("EQUIPO");
                    setItemSeleccionado(null);
                    setCodigoBusqueda("");
                    setResultadosBusqueda([]);
                  }}
                  className={`flex-1 py-2 px-4 rounded-lg font-medium transition-all flex items-center justify-center space-x-2 ${
                    tipo === "EQUIPO"
                      ? "bg-blue-600 text-white"
                      : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  }`}
                >
                  <Wrench size={18} />
                  <span>Equipo</span>
                </button>
              )}
              {permisos.suministros && (
                <button
                  type="button"
                  onClick={() => {
                    setTipo("SUMINISTRO");
                    setItemSeleccionado(null);
                    setCodigoBusqueda("");
                    setResultadosBusqueda([]);
                  }}
                  className={`flex-1 py-2 px-4 rounded-lg font-medium transition-all flex items-center justify-center space-x-2 ${
                    tipo === "SUMINISTRO"
                      ? "bg-purple-600 text-white"
                      : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                  }`}
                >
                  <Syringe size={18} />
                  <span>Suministro</span>
                </button>
              )}
            </div>
          </div>

          {/* Búsqueda de insumo */}
          <div>
            <label className="label">Buscar Insumo</label>
            <div className="flex space-x-2">
              <div className="flex-1 relative">
                <input
                  type="text"
                  value={codigoBusqueda}
                  onChange={(e) => setCodigoBusqueda(e.target.value)}
                  placeholder={`Ingrese el código del ${
                    tipo === "MEDICAMENTO"
                      ? "medicamento"
                      : tipo === "EQUIPO"
                      ? "equipo"
                      : "suministro"
                  } (ej: ${
                    tipo === "MEDICAMENTO"
                      ? "MED-001"
                      : tipo === "EQUIPO"
                      ? "EQU-001"
                      : "SUM-001"
                  })`}
                  className="input"
                  onKeyPress={(e) => e.key === "Enter" && buscarItem()}
                />
                {mostrarResultados && resultadosBusqueda.length > 0 && (
                  <div className="absolute z-10 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                    {resultadosBusqueda.map((item) => {
                      const status = getStockStatus(
                        item.cantidad,
                        item.nivel_minimo,
                      );
                      const StatusIcon = status.icon;
                      return (
                        <button
                          key={item.codigo}
                          onClick={() => seleccionarItem(item)}
                          className="w-full p-3 text-left hover:bg-gray-50 border-b border-gray-100 last:border-0"
                        >
                          <div className="flex justify-between items-start">
                            <div>
                              <p className="font-medium text-gray-900">
                                {item.nombre}
                              </p>
                              <p className="text-sm text-gray-500">
                                {item.codigo}
                              </p>
                            </div>
                            <div
                              className={`px-2 py-1 rounded-full text-xs flex items-center space-x-1 ${status.bg} ${status.color}`}
                            >
                              <StatusIcon size={12} />
                              <span>{status.text}</span>
                            </div>
                          </div>
                          <div className="flex justify-between mt-1 text-xs text-gray-400">
                            <span>Stock: {item.cantidad} unidades</span>
                            <span>
                              Precio: Q{item.precio_unitario?.toFixed(2)}
                            </span>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
              <button
                onClick={buscarItem}
                disabled={buscando || !codigoBusqueda.trim()}
                className="btn-secondary flex items-center space-x-2"
              >
                <Search size={18} />
                <span>Buscar</span>
              </button>
            </div>
          </div>

          {/* Insumo seleccionado */}
          {itemSeleccionado && (
            <div className="bg-green-50 border border-green-200 rounded-lg p-4">
              <div className="flex justify-between items-start">
                <div>
                  <p className="font-semibold text-green-800">
                    Insumo Seleccionado
                  </p>
                  <p className="text-lg font-bold text-green-900">
                    {itemSeleccionado.nombre}
                  </p>
                  <p className="text-sm text-green-700">
                    Código: {itemSeleccionado.codigo}
                  </p>
                </div>
                <button
                  onClick={() => {
                    setItemSeleccionado(null);
                    setCodigoBusqueda("");
                  }}
                  className="text-green-600 hover:text-green-800"
                >
                  <Package size={20} />
                </button>
              </div>
              <div className="grid grid-cols-2 gap-4 mt-3 text-sm">
                <div>
                  <span className="text-green-700">Stock disponible:</span>
                  <span className="ml-2 font-medium text-green-900">
                    {itemSeleccionado.cantidad} unidades
                  </span>
                </div>
                <div>
                  <span className="text-green-700">Nivel mínimo:</span>
                  <span className="ml-2 font-medium text-green-900">
                    {itemSeleccionado.nivel_minimo} unidades
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* Cantidad y motivo */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="label">Cantidad Solicitada</label>
              <input
                type="number"
                min="1"
                max={itemSeleccionado?.cantidad || 9999}
                value={cantidad}
                onChange={(e) =>
                  setCantidad(Math.max(1, parseInt(e.target.value) || 1))}
                className="input"
                disabled={!itemSeleccionado}
              />
              {itemSeleccionado && cantidad > itemSeleccionado.cantidad && (
                <p className="text-xs text-red-500 mt-1">
                  La cantidad supera el stock disponible ({itemSeleccionado
                    .cantidad} unidades)
                </p>
              )}
            </div>
            <div>
              <label className="label">Prioridad</label>
              <select className="input" defaultValue="NORMAL">
                <option value="NORMAL">Normal</option>
                <option value="ALTA">Alta</option>
                <option value="URGENTE">Urgente</option>
              </select>
            </div>
          </div>

          <div>
            <label className="label">Motivo de la Solicitud</label>
            <textarea
              value={motivo}
              onChange={(e) => setMotivo(e.target.value)}
              rows={3}
              className="input resize-none"
              placeholder="Describa el motivo clínico o administrativo de esta solicitud..."
              disabled={!itemSeleccionado}
            />
          </div>

          {/* Botón de envío */}
          <button
            onClick={enviarSolicitud}
            disabled={cargando || !itemSeleccionado ||
              cantidad > itemSeleccionado.cantidad}
            className="btn-primary w-full flex items-center justify-center space-x-2 disabled:opacity-50"
          >
            {cargando
              ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent">
                  </div>
                  <span>Enviando...</span>
                </>
              )
              : (
                <>
                  <Send size={18} />
                  <span>Enviar Solicitud</span>
                </>
              )}
          </button>
        </div>
      </div>

      {/* Información de permisos */}
      <div className="mt-6 bg-gray-50 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-gray-700 mb-2">
          Permisos de tu departamento ({user?.departamento || "Sin asignar"})
        </h3>
        <div className="flex flex-wrap gap-2">
          {permisos.medicamentos && (
            <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs">
              ✓ Medicamentos
            </span>
          )}
          {permisos.equipos && (
            <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
              ✓ Equipos
            </span>
          )}
          {permisos.suministros && (
            <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded-full text-xs">
              ✓ Suministros
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
