import { useState } from "react";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import {
  AlertCircle,
  CheckCircle,
  FileJson,
  FileText,
  Package,
  Upload,
  Users,
} from "lucide-react";

export default function CargaMasiva() {
  const [inventarioFile, setInventarioFile] = useState<File | null>(null);
  const [usuariosFile, setUsuariosFile] = useState<File | null>(null);
  const [cargandoInventario, setCargandoInventario] = useState(false);
  const [cargandoUsuarios, setCargandoUsuarios] = useState(false);
  const [resultadoInventario, setResultadoInventario] = useState<string | null>(
    null,
  );
  const [resultadoUsuarios, setResultadoUsuarios] = useState<string | null>(
    null,
  );

  const handleCargarInventario = async () => {
    if (!inventarioFile) {
      toast.error("Seleccione un archivo JSON de inventario");
      return;
    }

    if (!inventarioFile.name.endsWith(".json")) {
      toast.error("El archivo debe ser de tipo JSON");
      return;
    }

    setCargandoInventario(true);
    setResultadoInventario(null);

    try {
      const response = await api.cargarInventario(inventarioFile);
      setResultadoInventario(response.mensaje);
      toast.success("Inventario cargado correctamente");
      setInventarioFile(null);

      const fileInput = document.getElementById(
        "inventario-file",
      ) as HTMLInputElement;
      if (fileInput) fileInput.value = "";
    } catch (error: any) {
      const errorMsg = error.response?.data?.error ||
        "Error al cargar inventario";
      setResultadoInventario(`❌ ERROR: ${errorMsg}`);
      toast.error(errorMsg);
    } finally {
      setCargandoInventario(false);
    }
  };

  const handleCargarUsuarios = async () => {
    if (!usuariosFile) {
      toast.error("Seleccione un archivo JSON de usuarios");
      return;
    }

    if (!usuariosFile.name.endsWith(".json")) {
      toast.error("El archivo debe ser de tipo JSON");
      return;
    }

    setCargandoUsuarios(true);
    setResultadoUsuarios(null);

    try {
      const response = await api.cargarUsuarios(usuariosFile);
      setResultadoUsuarios(response.mensaje);
      toast.success("Usuarios cargados correctamente");
      setUsuariosFile(null);

      const fileInput = document.getElementById(
        "usuarios-file",
      ) as HTMLInputElement;
      if (fileInput) fileInput.value = "";
    } catch (error: any) {
      const errorMsg = error.response?.data?.error ||
        "Error al cargar usuarios";
      setResultadoUsuarios(`❌ ERROR: ${errorMsg}`);
      toast.error(errorMsg);
    } finally {
      setCargandoUsuarios(false);
    }
  };

  return (
    <div className="max-w-5xl mx-auto">
      <h1 className="text-2xl font-bold text-gray-900 mb-2">
        Carga Masiva de Datos
      </h1>
      <p className="text-gray-600 mb-6">
        Suba archivos JSON para cargar grandes volúmenes de datos al sistema.
        Los archivos deben seguir la estructura especificada.
      </p>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Tarjeta de Inventario */}
        <div className="bg-white rounded-xl shadow-md overflow-hidden">
          <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-4">
            <div className="flex items-center space-x-3">
              <div className="bg-white p-2 rounded-lg">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-white">
                  Cargar Inventario
                </h2>
                <p className="text-blue-100 text-sm">
                  Medicamentos, equipos y suministros
                </p>
              </div>
            </div>
          </div>

          <div className="p-6 space-y-4">
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-blue-500 transition-colors">
              <input
                id="inventario-file"
                type="file"
                accept=".json"
                onChange={(e) => setInventarioFile(e.target.files?.[0] || null)}
                className="hidden"
              />
              <label
                htmlFor="inventario-file"
                className="cursor-pointer flex flex-col items-center space-y-2"
              >
                <FileJson className="h-12 w-12 text-gray-400" />
                <span className="text-sm text-gray-600">
                  {inventarioFile
                    ? inventarioFile.name
                    : "Seleccionar archivo JSON"}
                </span>
                <span className="text-xs text-gray-400">
                  {inventarioFile
                    ? `${(inventarioFile.size / 1024).toFixed(2)} KB`
                    : "Máximo 10 MB"}
                </span>
              </label>
            </div>

            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <AlertCircle size={14} />
                <span>Estructura esperada: proveedores con entregas</span>
              </div>
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <CheckCircle size={14} className="text-green-500" />
                <span>Validación automática de campos</span>
              </div>
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <CheckCircle size={14} className="text-green-500" />
                <span>Soporta medicamentos, equipos y suministros</span>
              </div>
            </div>

            <button
              onClick={handleCargarInventario}
              disabled={cargandoInventario || !inventarioFile}
              className={`w-full py-2 rounded-lg font-medium transition-all flex items-center justify-center space-x-2 ${
                cargandoInventario || !inventarioFile
                  ? "bg-gray-300 text-gray-500 cursor-not-allowed"
                  : "bg-blue-600 text-white hover:bg-blue-700"
              }`}
            >
              {cargandoInventario
                ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent">
                    </div>
                    <span>Procesando...</span>
                  </>
                )
                : (
                  <>
                    <Upload size={18} />
                    <span>Subir y Procesar Inventario</span>
                  </>
                )}
            </button>
          </div>
        </div>

        {/* Tarjeta de Usuarios */}
        <div className="bg-white rounded-xl shadow-md overflow-hidden">
          <div className="bg-gradient-to-r from-purple-600 to-purple-700 px-6 py-4">
            <div className="flex items-center space-x-3">
              <div className="bg-white p-2 rounded-lg">
                <Users className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-white">
                  Cargar Usuarios
                </h2>
                <p className="text-purple-100 text-sm">
                  Personal médico y administrativo
                </p>
              </div>
            </div>
          </div>

          <div className="p-6 space-y-4">
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-purple-500 transition-colors">
              <input
                id="usuarios-file"
                type="file"
                accept=".json"
                onChange={(e) => setUsuariosFile(e.target.files?.[0] || null)}
                className="hidden"
              />
              <label
                htmlFor="usuarios-file"
                className="cursor-pointer flex flex-col items-center space-y-2"
              >
                <FileText className="h-12 w-12 text-gray-400" />
                <span className="text-sm text-gray-600">
                  {usuariosFile
                    ? usuariosFile.name
                    : "Seleccionar archivo JSON"}
                </span>
                <span className="text-xs text-gray-400">
                  {usuariosFile
                    ? `${(usuariosFile.size / 1024).toFixed(2)} KB`
                    : "Máximo 10 MB"}
                </span>
              </label>
            </div>

            <div className="space-y-2">
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <AlertCircle size={14} />
                <span>Estructura esperada: lista de usuarios</span>
              </div>
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <CheckCircle size={14} className="text-green-500" />
                <span>
                  Validación de número de colegio, tipo y departamento
                </span>
              </div>
              <div className="flex items-center space-x-2 text-xs text-gray-500">
                <CheckCircle size={14} className="text-green-500" />
                <span>Actualiza automáticamente tabla hash y grafo</span>
              </div>
            </div>

            <button
              onClick={handleCargarUsuarios}
              disabled={cargandoUsuarios || !usuariosFile}
              className={`w-full py-2 rounded-lg font-medium transition-all flex items-center justify-center space-x-2 ${
                cargandoUsuarios || !usuariosFile
                  ? "bg-gray-300 text-gray-500 cursor-not-allowed"
                  : "bg-purple-600 text-white hover:bg-purple-700"
              }`}
            >
              {cargandoUsuarios
                ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent">
                    </div>
                    <span>Procesando...</span>
                  </>
                )
                : (
                  <>
                    <Upload size={18} />
                    <span>Subir y Procesar Usuarios</span>
                  </>
                )}
            </button>
          </div>
        </div>
      </div>

      {/* Resultados */}
      {(resultadoInventario || resultadoUsuarios) && (
        <div className="mt-6 bg-white rounded-xl shadow-md overflow-hidden">
          <div className="bg-gray-50 px-6 py-3 border-b border-gray-200">
            <h3 className="font-semibold text-gray-900">
              Resultado del Procesamiento
            </h3>
          </div>
          <div className="p-6 space-y-4">
            {resultadoInventario && (
              <div>
                <h4 className="text-sm font-medium text-blue-600 mb-2">
                  📦 Inventario
                </h4>
                <pre className="bg-gray-900 text-green-400 p-4 rounded-lg overflow-x-auto text-sm font-mono whitespace-pre-wrap max-h-60 overflow-y-auto">
                  {resultadoInventario}
                </pre>
              </div>
            )}
            {resultadoUsuarios && (
              <div>
                <h4 className="text-sm font-medium text-purple-600 mb-2">
                  👥 Usuarios
                </h4>
                <pre className="bg-gray-900 text-green-400 p-4 rounded-lg overflow-x-auto text-sm font-mono whitespace-pre-wrap max-h-60 overflow-y-auto">
                  {resultadoUsuarios}
                </pre>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Formato de ejemplo */}
      <div className="mt-6 bg-white rounded-xl shadow-md overflow-hidden">
        <div className="bg-gray-50 px-6 py-3 border-b border-gray-200">
          <h3 className="font-semibold text-gray-900">
            📋 Formato de Archivos JSON
          </h3>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div>
              <h4 className="text-sm font-medium text-gray-700 mb-2">
                Inventario (proveedores.json)
              </h4>
              <pre className="bg-gray-800 text-green-400 p-3 rounded-lg text-xs font-mono overflow-x-auto">
{`{
  "proveedor": [
    {
      "nit": "12345678-1",
      "nombre": "FarmaGT Distribuciones",
      "telefono": "2201-1100",
      "direccion": "Zona 4, Guatemala",
      "fecha_entrega": "2026-03-10",
      "numero_factura": "FAC-001",
      "entrega": [
        {
          "tipo": "EQUIPO",
          "codigo": "001",
          "nombre": "Monitor de Signos",
          "fabricante": "MediTech",
          "precio_unitario": 4500.00,
          "cantidad": 10,
          "fecha_ingreso": "2026-03-10",
          "nivel_minimo": 2
        }
      ]
    }
  ]
}`}
              </pre>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-700 mb-2">
                Usuarios (usuarios.json)
              </h4>
              <pre className="bg-gray-800 text-green-400 p-3 rounded-lg text-xs font-mono overflow-x-auto">
{`{
  "usuarios": [
    {
      "numero_colegio": "COL-10001",
      "nombre_completo": "Ana Ramirez",
      "tipo_usuario": "TIPO-01",
      "departamento": "DEP-MED",
      "especialidad": "Medicina General",
      "contrasena": "medgen2026"
    }
  ]
}`}
              </pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
