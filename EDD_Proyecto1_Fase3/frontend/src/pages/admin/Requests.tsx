import { useEffect, useState } from "react";
import { api, Solicitud } from "../../../services/api";
import toast from "react-hot-toast";
import { CheckCircle, Package } from "lucide-react";

export default function AdminRequests() {
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [loading, setLoading] = useState(true);
  const [aprobando, setAprobando] = useState<string | null>(null);

  useEffect(() => {
    cargarSolicitudes();
  }, []);

  const cargarSolicitudes = async () => {
    try {
      const response = await api.getSolicitudes();
      setSolicitudes(response.solicitudes || []);
    } catch (error) {
      toast.error("Error al cargar solicitudes");
    } finally {
      setLoading(false);
    }
  };

  const handleAprobar = async (uuid: string) => {
    setAprobando(uuid);
    try {
      await api.aprobarSolicitud(uuid);
      toast.success("Solicitud aprobada correctamente");
      cargarSolicitudes();
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al aprobar solicitud");
    } finally {
      setAprobando(null);
    }
  };

  const getTipoColor = (tipo: string) => {
    switch (tipo) {
      case "MEDICAMENTO":
        return "bg-green-100 text-green-800";
      case "EQUIPO":
        return "bg-blue-100 text-blue-800";
      case "SUMINISTRO":
        return "bg-purple-100 text-purple-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

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
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Solicitudes de Reabastecimiento
      </h1>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Código
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cantidad
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Departamento
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Motivo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {solicitudes.length === 0
                ? (
                  <tr>
                    <td
                      colSpan={7}
                      className="px-6 py-8 text-center text-gray-500"
                    >
                      <Package className="h-12 w-12 mx-auto text-gray-400 mb-2" />
                      No hay solicitudes pendientes
                    </td>
                  </tr>
                )
                : (
                  solicitudes.map((solicitud) => (
                    <tr key={solicitud.uuid} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`px-2 py-1 text-xs rounded-full ${
                            getTipoColor(solicitud.tipo)
                          }`}
                        >
                          {solicitud.tipo}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {solicitud.codigo}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {solicitud.cantidad}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {solicitud.departamento}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600 max-w-xs truncate">
                        {solicitud.motivo}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {solicitud.fecha}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <button
                          onClick={() =>
                            handleAprobar(solicitud.uuid)}
                          disabled={aprobando === solicitud.uuid}
                          className="text-green-600 hover:text-green-800 mr-3"
                        >
                          <CheckCircle size={20} />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
