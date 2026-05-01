import { useEffect, useState } from "react";
import { api, Equipo, Medicamento, Suministro } from "../../../services/api";
import toast from "react-hot-toast";
import { AlertTriangle, CheckCircle, Package, Search } from "lucide-react";

type TabType = "medicamentos" | "equipos" | "suministros";

export default function Inventory() {
  const [activeTab, setActiveTab] = useState<TabType>("medicamentos");
  const [medicamentos, setMedicamentos] = useState<Medicamento[]>([]);
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [suministros, setSuministros] = useState<Suministro[]>([]);
  const [loading, setLoading] = useState(true);
  const [filtro, setFiltro] = useState("");

  useEffect(() => {
    cargarInventario();
  }, [activeTab, filtro]);

  const cargarInventario = async () => {
    setLoading(true);
    try {
      if (activeTab === "medicamentos") {
        const response = await api.getInventarioMedicamentos(filtro);
        setMedicamentos(response.medicamentos || []);
      } else if (activeTab === "equipos") {
        const response = await api.getInventarioEquipos(filtro);
        setEquipos(response.equipos || []);
      } else {
        const response = await api.getInventarioSuministros(filtro);
        setSuministros(response.suministros || []);
      }
    } catch (error) {
      toast.error("Error al cargar inventario");
    } finally {
      setLoading(false);
    }
  };

  const getStockStatus = (cantidad: number, nivelMinimo: number) => {
    if (cantidad === 0) {
      return {
        color: "bg-red-100 text-red-800",
        icon: AlertTriangle,
        text: "Agotado",
      };
    }
    if (cantidad < nivelMinimo) {
      return {
        color: "bg-yellow-100 text-yellow-800",
        icon: AlertTriangle,
        text: "Stock Bajo",
      };
    }
    return {
      color: "bg-green-100 text-green-800",
      icon: CheckCircle,
      text: "Suficiente",
    };
  };

  const tabs = [
    { id: "medicamentos", label: "Medicamentos", count: medicamentos.length },
    { id: "equipos", label: "Equipos Médicos", count: equipos.length },
    { id: "suministros", label: "Suministros", count: suministros.length },
  ];

  const currentData = activeTab === "medicamentos"
    ? medicamentos
    : activeTab === "equipos"
    ? equipos
    : suministros;

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Inventario Hospitalario
      </h1>

      <div className="bg-white rounded-xl shadow-md overflow-hidden">
        <div className="border-b border-gray-200">
          <div className="flex space-x-1 p-4">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as TabType)}
                className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                  activeTab === tab.id
                    ? "bg-primary-600 text-white"
                    : "text-gray-600 hover:bg-gray-100"
                }`}
              >
                {tab.label}
                <span className="ml-2 px-2 py-0.5 text-xs rounded-full bg-opacity-20 bg-white">
                  {tab.count}
                </span>
              </button>
            ))}
          </div>
        </div>

        <div className="p-4 border-b border-gray-200">
          <div className="relative">
            <Search
              className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
              size={18}
            />
            <input
              type="text"
              placeholder="Buscar por código o nombre..."
              value={filtro}
              onChange={(e) => setFiltro(e.target.value)}
              className="input pl-10"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          {loading
            ? (
              <div className="flex items-center justify-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600">
                </div>
              </div>
            )
            : currentData.length === 0
            ? (
              <div className="text-center py-12">
                <Package className="h-12 w-12 mx-auto text-gray-400 mb-3" />
                <p className="text-gray-500">
                  No hay elementos en este inventario
                </p>
              </div>
            )
            : (
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Código
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Nombre
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Stock
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Estado
                    </th>
                    {activeTab === "medicamentos" && (
                      <>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Vencimiento
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Laboratorio
                        </th>
                      </>
                    )}
                    {activeTab === "equipos" && (
                      <>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Fabricante
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Ingreso
                        </th>
                      </>
                    )}
                    {activeTab === "suministros" && (
                      <>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Fabricante
                        </th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                          Vencimiento
                        </th>
                      </>
                    )}
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Precio Unitario
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {currentData.map((item: any) => {
                    const status = getStockStatus(
                      item.cantidad,
                      item.nivel_minimo,
                    );
                    const StatusIcon = status.icon;
                    return (
                      <tr key={item.codigo} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {item.codigo}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                          {item.nombre}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                          {item.cantidad} unidades
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span
                            className={`px-2 py-1 text-xs rounded-full flex items-center space-x-1 w-fit ${status.color}`}
                          >
                            <StatusIcon size={12} />
                            <span>{status.text}</span>
                          </span>
                        </td>
                        {activeTab === "medicamentos" && (
                          <>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.fecha_vencimiento || "-"}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.laboratorio || item.fabricante || "-"}
                            </td>
                          </>
                        )}
                        {activeTab === "equipos" && (
                          <>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.fabricante || "-"}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.fecha_ingreso || "-"}
                            </td>
                          </>
                        )}
                        {activeTab === "suministros" && (
                          <>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.fabricante || "-"}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                              {item.fecha_vencimiento || "-"}
                            </td>
                          </>
                        )}
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                          Q{item.precio_unitario?.toFixed(2)}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
        </div>
      </div>
    </div>
  );
}
