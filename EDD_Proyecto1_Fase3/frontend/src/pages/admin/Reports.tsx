import { useState } from "react";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import { BarChart3, Download, Eye, FileText, Hash, Share2 } from "lucide-react";

interface TablaHashStats {
  "TIPO-01": { ocupacion: number; colisiones: number };
  "TIPO-02": { ocupacion: number; colisiones: number };
  "TIPO-03": { ocupacion: number; colisiones: number };
  "TIPO-04": { ocupacion: number; colisiones: number };
  "TIPO-05": { ocupacion: number; colisiones: number };
  total_ocupacion: number;
  total_colisiones: number;
}

export default function AdminReports() {
  const [loading, setLoading] = useState(false);
  const [tablaHashStats, setTablaHashStats] = useState<TablaHashStats | null>(
    null,
  );
  const [listaAdyacencia, setListaAdyacencia] = useState<string>("");
  const [archivosCompresion, setArchivosCompresion] = useState<string[]>([]);

  const generarReporteGrafo = async () => {
    setLoading(true);
    try {
      const response = await api.getReporteGrafo();
      if (response.png) {
        window.open(`http://localhost:3000${response.png}`, "_blank");
      }
      toast.success("Reporte de grafo generado");
    } catch (error) {
      toast.error("Error al generar reporte de grafo");
    } finally {
      setLoading(false);
    }
  };

  const generarListaAdyacencia = async () => {
    setLoading(true);
    try {
      const response = await api.getReporteListaAdyacencia();
      setListaAdyacencia(response.lista || "");
      toast.success("Lista de adyacencia cargada");
    } catch (error) {
      toast.error("Error al cargar lista de adyacencia");
    } finally {
      setLoading(false);
    }
  };

  const generarTablaHash = async () => {
    setLoading(true);
    try {
      const response = await api.getReporteTablaHash();
      setTablaHashStats(response.estadisticas);
      toast.success("Estadísticas de tabla hash cargadas");
    } catch (error) {
      toast.error("Error al cargar estadísticas de tabla hash");
    } finally {
      setLoading(false);
    }
  };

  const generarReporteCompresion = async () => {
    setLoading(true);
    try {
      const response = await api.getReporteCompresion();
      setArchivosCompresion(response.archivos || []);
      toast.success("Reporte de compresión cargado");
    } catch (error) {
      toast.error("Error al cargar reporte de compresión");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Reportes Avanzados
      </h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <button
          onClick={generarReporteGrafo}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg transition-shadow"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <Share2 className="h-6 w-6 text-primary-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold text-gray-900">
                Grafo de Colaboraciones
              </h3>
              <p className="text-sm text-gray-500">
                Visualización completa de la red de colaboración
              </p>
            </div>
          </div>
          <Eye className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarListaAdyacencia}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg transition-shadow"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <FileText className="h-6 w-6 text-blue-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold text-gray-900">
                Lista de Adyacencia
              </h3>
              <p className="text-sm text-gray-500">
                Representación textual del grafo
              </p>
            </div>
          </div>
          <Download className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarTablaHash}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg transition-shadow"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-green-100 rounded-lg">
              <Hash className="h-6 w-6 text-green-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold text-gray-900">Tabla Hash</h3>
              <p className="text-sm text-gray-500">
                Estadísticas por tipo de usuario
              </p>
            </div>
          </div>
          <BarChart3 className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarReporteCompresion}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg transition-shadow"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-purple-100 rounded-lg">
              <Download className="h-6 w-6 text-purple-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold text-gray-900">Compresión LZW</h3>
              <p className="text-sm text-gray-500">
                Archivos de chat comprimidos
              </p>
            </div>
          </div>
          <BarChart3 className="h-5 w-5 text-gray-400" />
        </button>
      </div>

      {listaAdyacencia && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Lista de Adyacencia
          </h2>
          <pre className="bg-gray-900 text-green-400 p-4 rounded-lg overflow-x-auto text-sm">
            {listaAdyacencia}
          </pre>
        </div>
      )}

      {tablaHashStats && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Estadísticas de Tabla Hash
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {Object.entries(tablaHashStats).map(([key, value]) => {
              if (key.startsWith("TIPO-")) {
                return (
                  <div key={key} className="bg-gray-50 p-4 rounded-lg">
                    <p className="font-medium text-gray-900">{key}</p>
                    <p className="text-sm text-gray-600">
                      Ocupación: {value.ocupacion} usuarios
                    </p>
                    <p className="text-sm text-gray-600">
                      Colisiones: {value.colisiones ? "Sí" : "No"}
                    </p>
                  </div>
                );
              }
              return null;
            })}
          </div>
          <div className="mt-4 pt-4 border-t border-gray-200">
            <p className="text-sm text-gray-600">
              Total ocupación: {tablaHashStats.total_ocupacion} usuarios
            </p>
            <p className="text-sm text-gray-600">
              Total colisiones: {tablaHashStats.total_colisiones}
            </p>
          </div>
        </div>
      )}

      {archivosCompresion.length > 0 && (
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Archivos Comprimidos (LZW)
          </h2>
          <div className="space-y-2">
            {archivosCompresion.map((archivo, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <span className="text-sm font-mono text-gray-700">
                  {archivo}
                </span>
                <span className="text-xs text-gray-500">.lzw</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
