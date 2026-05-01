import { useEffect, useState } from "react";
import { api, Solicitud } from "../../../services/api";
import toast from "react-hot-toast";
import { Calendar, ClipboardList, FileText, User } from "lucide-react";

export default function History() {
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [loading, setLoading] = useState(true);
  const [filtroTipo, setFiltroTipo] = useState<string>("");

  useEffect(() => {
    cargarHistorial();
  }, []);

  const cargarHistorial = async () => {
    try {
      const response = await api.getHistorialSolicitudes();
      setSolicitudes(response.solicitudes || []);
    } catch (error) {
      toast.error("Error al cargar historial de solicitudes");
    } finally {
      setLoading(false);
    }
  };

  const getTipoColor = (tipo: string) => {
    switch (tipo) {
      case "MEDICAMENTO":
        return "bg-green-100 text-green-800 border-green-200";
      case "EQUIPO":
        return "bg-blue-100 text-blue-800 border-blue-200";
      case "SUMINISTRO":
        return "bg-purple-100 text-purple-800 border-purple-200";
      default:
        return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const solicitudesFiltradas = filtroTipo
    ? solicitudes.filter((s) => s.tipo === filtroTipo)
    : solicitudes;

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600">
        </div>
      </div>
    );
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-2">
        Historial de Solicitudes
      </h1>
      <p className="text-gray-600 mb-6">
        Todas las solicitudes realizadas por tu departamento
      </p>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="p-4 border-b border-gray-200 bg-gray-50 flex flex-wrap gap-2">
          <button
            onClick={() => setFiltroTipo("")}
            className={`px-3 py-1 rounded-full text-sm transition-colors ${
              filtroTipo === ""
                ? "bg-primary-600 text-white"
                : "bg-gray-200 text-gray-700 hover:bg-gray-300"
            }`}
          >
            Todos
          </button>
          <button
            onClick={() => setFiltroTipo("MEDICAMENTO")}
            className={`px-3 py-1 rounded-full text-sm transition-colors ${
              filtroTipo === "MEDICAMENTO"
                ? "bg-green-600 text-white"
                : "bg-green-100 text-green-800 hover:bg-green-200"
            }`}
          >
            Medicamentos
          </button>
          <button
            onClick={() => setFiltroTipo("EQUIPO")}
            className={`px-3 py-1 rounded-full text-sm transition-colors ${
              filtroTipo === "EQUIPO"
                ? "bg-blue-600 text-white"
                : "bg-blue-100 text-blue-800 hover:bg-blue-200"
            }`}
          >
            Equipos
          </button>
          <button
            onClick={() => setFiltroTipo("SUMINISTRO")}
            className={`px-3 py-1 rounded-full text-sm transition-colors ${
              filtroTipo === "SUMINISTRO"
                ? "bg-purple-600 text-white"
                : "bg-purple-100 text-purple-800 hover:bg-purple-200"
            }`}
          >
            Suministros
          </button>
        </div>

        {solicitudesFiltradas.length === 0
          ? (
            <div className="text-center py-12">
              <ClipboardList className="h-12 w-12 mx-auto text-gray-400 mb-3" />
              <p className="text-gray-500">No hay solicitudes registradas</p>
              <p className="text-sm text-gray-400">
                Las solicitudes que realices aparecerán aquí
              </p>
            </div>
          )
          : (
            <div className="divide-y divide-gray-200">
              {solicitudesFiltradas.map((solicitud) => (
                <div
                  key={solicitud.uuid}
                  className="p-6 hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-3">
                        <span
                          className={`px-2 py-1 text-xs rounded-full border ${
                            getTipoColor(solicitud.tipo)
                          }`}
                        >
                          {solicitud.tipo}
                        </span>
                        <span className="text-xs text-gray-500 flex items-center">
                          <Calendar size={12} className="mr-1" />
                          {solicitud.fecha}
                        </span>
                        <span className="text-xs text-gray-500 flex items-center">
                          <User size={12} className="mr-1" />
                          {solicitud.solicitante}
                        </span>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-3">
                        <div>
                          <p className="text-xs text-gray-500">Código</p>
                          <p className="font-mono text-sm text-gray-900">
                            {solicitud.codigo}
                          </p>
                        </div>
                        <div>
                          <p className="text-xs text-gray-500">Cantidad</p>
                          <p className="text-sm text-gray-900">
                            {solicitud.cantidad} unidades
                          </p>
                        </div>
                        <div>
                          <p className="text-xs text-gray-500">Departamento</p>
                          <p className="text-sm text-gray-900">
                            {solicitud.departamento}
                          </p>
                        </div>
                      </div>

                      <div>
                        <p className="text-xs text-gray-500 flex items-center">
                          <FileText size={12} className="mr-1" />
                          Motivo
                        </p>
                        <p className="text-sm text-gray-700 mt-1">
                          {solicitud.motivo}
                        </p>
                      </div>
                    </div>

                    <div className="ml-4">
                      <div className="px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                        Pendiente
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
      </div>

      {/* Resumen estadístico */}
      {solicitudes.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
          <div className="bg-gradient-to-r from-green-500 to-green-600 rounded-xl p-4 text-white">
            <p className="text-sm opacity-90">Medicamentos</p>
            <p className="text-2xl font-bold">
              {solicitudes.filter((s) => s.tipo === "MEDICAMENTO").length}
            </p>
            <p className="text-xs opacity-75">solicitudes</p>
          </div>
          <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl p-4 text-white">
            <p className="text-sm opacity-90">Equipos</p>
            <p className="text-2xl font-bold">
              {solicitudes.filter((s) => s.tipo === "EQUIPO").length}
            </p>
            <p className="text-xs opacity-75">solicitudes</p>
          </div>
          <div className="bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl p-4 text-white">
            <p className="text-sm opacity-90">Suministros</p>
            <p className="text-2xl font-bold">
              {solicitudes.filter((s) => s.tipo === "SUMINISTRO").length}
            </p>
            <p className="text-xs opacity-75">solicitudes</p>
          </div>
        </div>
      )}
    </div>
  );
}
