import { useEffect, useState } from "react";
import { Activity, ShoppingCart, TrendingUp, Users } from "lucide-react";
import { api, Solicitud, UsuarioPendiente } from "../../../services/api.ts";
import toast from "react-hot-toast";

export default function AdminDashboard() {
  const [pendientes, setPendientes] = useState<UsuarioPendiente[]>([]);
  const [solicitudes, setSolicitudes] = useState<Solicitud[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    cargarDatos();
  }, []);

  const cargarDatos = async () => {
    try {
      const [pendientesRes, solicitudesRes] = await Promise.all([
        api.getUsuariosPendientes(),
        api.getSolicitudes(),
      ]);
      setPendientes(pendientesRes.usuarios || []);
      setSolicitudes(solicitudesRes.solicitudes || []);
    } catch (error) {
      toast.error("Error al cargar datos del dashboard");
    } finally {
      setLoading(false);
    }
  };

  const stats = [
    {
      titulo: "Usuarios Pendientes",
      valor: pendientes.length,
      icono: Users,
      color: "bg-orange-500",
      descripcion: "Por asignar departamento",
    },
    {
      titulo: "Solicitudes Activas",
      valor: solicitudes.length,
      icono: ShoppingCart,
      color: "bg-blue-500",
      descripcion: "Esperando aprobación",
    },
    {
      titulo: "Total Usuarios",
      valor: "-",
      icono: Activity,
      color: "bg-green-500",
      descripcion: "Cargados en el sistema",
    },
    {
      titulo: "Colaboraciones",
      valor: "-",
      icono: TrendingUp,
      color: "bg-purple-500",
      descripcion: "Red de colaboración",
    },
  ];

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
        Panel de Administración
      </h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => {
          const Icono = stat.icono;
          return (
            <div key={index} className="bg-white rounded-xl shadow-md p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-500 mb-1">{stat.titulo}</p>
                  <p className="text-3xl font-bold text-gray-900">
                    {stat.valor}
                  </p>
                  <p className="text-xs text-gray-400 mt-2">
                    {stat.descripcion}
                  </p>
                </div>
                <div className={`${stat.color} p-3 rounded-lg`}>
                  <Icono className="h-6 w-6 text-white" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Usuarios Pendientes Recientes
          </h2>
          {pendientes.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No hay usuarios pendientes
              </p>
            )
            : (
              <div className="space-y-3">
                {pendientes.slice(0, 5).map((user) => (
                  <div
                    key={user.colegio}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">{user.nombre}</p>
                      <p className="text-sm text-gray-500">
                        {user.colegio} • {user.tipo}
                      </p>
                    </div>
                    <span className="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                      Pendiente
                    </span>
                  </div>
                ))}
              </div>
            )}
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Solicitudes Recientes
          </h2>
          {solicitudes.length === 0
            ? (
              <p className="text-gray-500 text-center py-8">
                No hay solicitudes activas
              </p>
            )
            : (
              <div className="space-y-3">
                {solicitudes.slice(0, 5).map((solicitud) => (
                  <div
                    key={solicitud.uuid}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">
                        {solicitud.tipo} - {solicitud.codigo}
                      </p>
                      <p className="text-sm text-gray-500">
                        {solicitud.departamento} • {solicitud.cantidad} unidades
                      </p>
                    </div>
                    <span className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                      Pendiente
                    </span>
                  </div>
                ))}
              </div>
            )}
        </div>
      </div>
    </div>
  );
}
