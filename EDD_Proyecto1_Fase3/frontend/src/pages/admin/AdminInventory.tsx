import { useEffect, useState } from "react";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import {
  Check,
  Edit,
  Package,
  Plus,
  Search,
  Syringe,
  Trash2,
  Wrench,
  X,
} from "lucide-react";

type TabType = "medicamentos" | "equipos" | "suministros";

export default function AdminInventory() {
  const [activeTab, setActiveTab] = useState<TabType>("medicamentos");
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState<any | null>(null);
  const [formData, setFormData] = useState<any>({});
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    cargarItems();
  }, [activeTab]);

  const cargarItems = async () => {
    setLoading(true);
    setError(null);
    try {
      let lista: any[] = [];
      if (activeTab === "medicamentos") {
        const res = await api.getAdminMedicamentos();
        lista = res.medicamentos || [];
      } else if (activeTab === "equipos") {
        const res = await api.getAdminEquipos();
        // Normalizar: si es array directo o viene en objeto
        if (Array.isArray(res)) {
          lista = res;
        } else if (res && typeof res === "object") {
          lista = res.equipos || res.data || [];
        }
      } else if (activeTab === "suministros") {
        const res = await api.getAdminSuministros();
        lista = res.suministros || [];
      }

      // ELIMINAR CUALQUIER ELEMENTO NULL O UNDEFINED
      lista = lista.filter((item) => item != null && typeof item === "object");

      // SANITIZAR CADA ITEM (asignar valores por defecto)
      lista = lista.map((item) => ({
        codigo: item.codigo || "",
        nombre: item.nombre || "",
        cantidad: item.cantidad ?? 0,
        precio_unitario: item.precio_unitario ?? 0,
        nivel_minimo: item.nivel_minimo ?? 0,
        // Campos adicionales según tipo
        ...(activeTab === "medicamentos" && {
          principio_activo: item.principio_activo || "",
          laboratorio: item.laboratorio || "",
          fabricante: item.fabricante || "",
          fecha_vencimiento: item.fecha_vencimiento || "",
        }),
        ...(activeTab === "equipos" && {
          fabricante: item.fabricante || "",
          fecha_ingreso: item.fecha_ingreso || "",
        }),
        ...(activeTab === "suministros" && {
          fabricante: item.fabricante || "",
          fecha_vencimiento: item.fecha_vencimiento || "",
        }),
      }));

      setItems(lista);
    } catch (err: any) {
      console.error("Error cargando:", err);
      setError(err.message || "Error al cargar datos");
      toast.error("Error al cargar datos");
      setItems([]);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (item?: any) => {
    if (item) {
      setEditingItem(item);
      setFormData({ ...item });
    } else {
      setEditingItem(null);
      const baseForm = {
        codigo: "",
        nombre: "",
        cantidad: 0,
        precio_unitario: 0,
        nivel_minimo: 0,
      };
      if (activeTab === "medicamentos") {
        setFormData({
          ...baseForm,
          principio_activo: "",
          laboratorio: "",
          fabricante: "",
          fecha_vencimiento: "",
        });
      } else if (activeTab === "equipos") {
        setFormData({ ...baseForm, fabricante: "", fecha_ingreso: "" });
      } else {
        setFormData({ ...baseForm, fabricante: "", fecha_vencimiento: "" });
      }
    }
    setShowModal(true);
  };

  const handleSave = async () => {
    try {
      if (editingItem) {
        if (activeTab === "medicamentos") {
          await api.updateAdminMedicamento(editingItem.codigo, formData);
        } else if (activeTab === "equipos") {
          await api.updateAdminEquipo(editingItem.codigo, formData);
        } else await api.updateAdminSuministro(editingItem.codigo, formData);
        toast.success("Actualizado correctamente");
      } else {
        if (activeTab === "medicamentos") {
          await api.createAdminMedicamento(formData);
        } else if (activeTab === "equipos") {
          await api.createAdminEquipo(formData);
        } else await api.createAdminSuministro(formData);
        toast.success("Creado correctamente");
      }
      setShowModal(false);
      cargarItems();
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al guardar");
    }
  };

  const handleDelete = async (codigo: string) => {
    if (!confirm("¿Eliminar este elemento permanentemente?")) return;
    try {
      if (activeTab === "medicamentos") {
        await api.deleteAdminMedicamento(codigo);
      } else if (activeTab === "equipos") await api.deleteAdminEquipo(codigo);
      else await api.deleteAdminSuministro(codigo);
      toast.success("Eliminado correctamente");
      cargarItems();
    } catch (error) {
      toast.error("Error al eliminar");
    }
  };

  const filteredItems = items.filter((item) => {
    if (!item || typeof item !== "object") return false;
    const codigo = (item.codigo || "").toLowerCase();
    const nombre = (item.nombre || "").toLowerCase();
    const searchLower = search.toLowerCase();
    return codigo.includes(searchLower) || nombre.includes(searchLower);
  });

  const tabs = [
    { id: "medicamentos", label: "Medicamentos", icon: Package },
    { id: "equipos", label: "Equipos", icon: Wrench },
    { id: "suministros", label: "Suministros", icon: Syringe },
  ];

  const renderForm = () => {
    const prefix = activeTab === "medicamentos"
      ? "MED"
      : activeTab === "equipos"
      ? "EQU"
      : "SUM";
    return (
      <div className="space-y-4">
        <div>
          <label className="label">Código</label>
          <input
            type="text"
            value={formData.codigo || ""}
            onChange={(e) =>
              setFormData({ ...formData, codigo: e.target.value })}
            className="input"
            placeholder={`${prefix}-001`}
            disabled={!!editingItem}
          />
        </div>
        <div>
          <label className="label">Nombre</label>
          <input
            type="text"
            value={formData.nombre || ""}
            onChange={(e) =>
              setFormData({ ...formData, nombre: e.target.value })}
            className="input"
          />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="label">Cantidad</label>
            <input
              type="number"
              value={formData.cantidad || 0}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  cantidad: parseInt(e.target.value) || 0,
                })}
              className="input"
            />
          </div>
          <div>
            <label className="label">Precio Unitario</label>
            <input
              type="number"
              step="0.01"
              value={formData.precio_unitario || 0}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  precio_unitario: parseFloat(e.target.value) || 0,
                })}
              className="input"
            />
          </div>
        </div>
        <div>
          <label className="label">Nivel Mínimo</label>
          <input
            type="number"
            value={formData.nivel_minimo || 0}
            onChange={(e) =>
              setFormData({
                ...formData,
                nivel_minimo: parseInt(e.target.value) || 0,
              })}
            className="input"
          />
        </div>
        {activeTab === "medicamentos" && (
          <>
            <div>
              <label className="label">Principio Activo</label>
              <input
                type="text"
                value={formData.principio_activo || ""}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    principio_activo: e.target.value,
                  })}
                className="input"
              />
            </div>
            <div>
              <label className="label">Laboratorio</label>
              <input
                type="text"
                value={formData.laboratorio || ""}
                onChange={(e) =>
                  setFormData({ ...formData, laboratorio: e.target.value })}
                className="input"
              />
            </div>
            <div>
              <label className="label">Fabricante</label>
              <input
                type="text"
                value={formData.fabricante || ""}
                onChange={(e) =>
                  setFormData({ ...formData, fabricante: e.target.value })}
                className="input"
              />
            </div>
            <div>
              <label className="label">Fecha Vencimiento</label>
              <input
                type="date"
                value={formData.fecha_vencimiento || ""}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    fecha_vencimiento: e.target.value,
                  })}
                className="input"
              />
            </div>
          </>
        )}
        {(activeTab === "equipos" || activeTab === "suministros") && (
          <>
            <div>
              <label className="label">Fabricante</label>
              <input
                type="text"
                value={formData.fabricante || ""}
                onChange={(e) =>
                  setFormData({ ...formData, fabricante: e.target.value })}
                className="input"
              />
            </div>
            {activeTab === "equipos" && (
              <div>
                <label className="label">Fecha Ingreso</label>
                <input
                  type="date"
                  value={formData.fecha_ingreso || ""}
                  onChange={(e) =>
                    setFormData({ ...formData, fecha_ingreso: e.target.value })}
                  className="input"
                />
              </div>
            )}
            {activeTab === "suministros" && (
              <div>
                <label className="label">Fecha Vencimiento</label>
                <input
                  type="date"
                  value={formData.fecha_vencimiento || ""}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      fecha_vencimiento: e.target.value,
                    })}
                  className="input"
                />
              </div>
            )}
          </>
        )}
      </div>
    );
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">
          Gestión de Inventario
        </h1>
        <button
          onClick={() => handleOpenModal()}
          className="btn-primary flex items-center space-x-2"
        >
          <Plus size={18} />
          <span>Nuevo {activeTab.slice(0, -1)}</span>
        </button>
      </div>

      <div className="border-b border-gray-200 mb-6">
        <div className="flex space-x-4">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as TabType)}
                className={`py-2 px-4 font-medium flex items-center space-x-2 transition-colors ${
                  activeTab === tab.id
                    ? "text-primary-600 border-b-2 border-primary-600"
                    : "text-gray-500 hover:text-gray-700"
                }`}
              >
                <Icon size={18} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      <div className="mb-4 relative">
        <Search
          className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
          size={18}
        />
        <input
          type="text"
          placeholder="Buscar por código o nombre..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="input pl-10"
        />
      </div>

      {loading
        ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600">
            </div>
          </div>
        )
        : error
        ? (
          <div className="card text-center py-12 text-red-600">
            <p>Error: {error}</p>
            <button
              onClick={() => cargarItems()}
              className="btn-secondary mt-4"
            >
              Reintentar
            </button>
          </div>
        )
        : items.length === 0
        ? (
          <div className="card text-center py-12">
            <Package className="h-12 w-12 mx-auto text-gray-400 mb-3" />
            <p className="text-gray-500">No hay {activeTab} registrados</p>
            <button
              onClick={() => handleOpenModal()}
              className="mt-3 text-primary-600 hover:text-primary-700 text-sm font-medium"
            >
              + Agregar el primer {activeTab.slice(0, -1)}
            </button>
          </div>
        )
        : (
          <div className="bg-white rounded-xl shadow-md overflow-hidden">
            <div className="overflow-x-auto">
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
                      Precio
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredItems.map((item) => (
                    <tr key={item.codigo} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {item.codigo || "-"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {item.nombre || "-"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {item.cantidad ?? 0}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        Q{(item.precio_unitario ?? 0).toFixed(2)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                        <button
                          onClick={() =>
                            handleOpenModal(item)}
                          className="text-blue-600 hover:text-blue-800"
                        >
                          <Edit size={18} />
                        </button>
                        <button
                          onClick={() =>
                            handleDelete(item.codigo)}
                          className="text-red-600 hover:text-red-800"
                        >
                          <Trash2 size={18} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl max-w-lg w-full max-h-[90vh] overflow-y-auto p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">
                {editingItem ? "Editar" : "Nuevo"} {activeTab.slice(0, -1)}
              </h2>
              <button
                onClick={() => setShowModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X size={24} />
              </button>
            </div>
            {renderForm()}
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowModal(false)}
                className="btn-secondary"
              >
                Cancelar
              </button>
              <button
                onClick={handleSave}
                className="btn-primary flex items-center space-x-2"
              >
                <Check size={18} />
                <span>Guardar</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
