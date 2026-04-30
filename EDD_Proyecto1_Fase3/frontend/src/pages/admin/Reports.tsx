import { useState } from "react";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import { BarChart3, Database, Eye, FileText, Hash, Share2 } from "lucide-react";

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

  // Reportes de imágenes
  const [grafoPng, setGrafoPng] = useState<string | null>(null);
  const [cargandoGrafo, setCargandoGrafo] = useState(false);
  const [matrizPng, setMatrizPng] = useState<string | null>(null);
  const [cargandoMatriz, setCargandoMatriz] = useState(false);

  // Estados de Merkle (con sus respectivos cargando)
  const [merklePng, setMerklePng] = useState<string | null>(null);
  const [cargandoMerkle, setCargandoMerkle] = useState(false);
  const [merkleData, setMerkleData] = useState<
    { raiz: string; integridad: string; num_mensajes: number } | null
  >(null);

  // Reportes de texto
  const [listaAdyacencia, setListaAdyacencia] = useState<string>("");
  const [tablaHashStats, setTablaHashStats] = useState<TablaHashStats | null>(
    null,
  );
  const [archivosCompresion, setArchivosCompresion] = useState<string[]>([]);

  // ---------- Grafo ----------
  const generarReporteGrafo = async () => {
    setCargandoGrafo(true);
    try {
      const res = await api.getReporteGrafo();
      if (res.png) {
        setGrafoPng(res.png);
        toast.success("Reporte de grafo generado");
      } else {
        toast.error(res.error || "Error");
      }
    } catch (err) {
      toast.error("Error al generar grafo");
    } finally {
      setCargandoGrafo(false);
    }
  };

  // ---------- Matriz ----------
  const generarReporteMatriz = async () => {
    setCargandoMatriz(true);
    try {
      const res = await api.getReporteMatriz();
      if (res.png) {
        setMatrizPng(res.png);
        toast.success("Matriz dispersa generada");
      }
    } catch (err) {
      toast.error("Error al generar matriz");
    } finally {
      setCargandoMatriz(false);
    }
  };

  // ---------- Árbol de Merkle (con logs para depuración) ----------
  const generarMerkle = async () => {
    console.log("Iniciando generación de Merkle...");
    setCargandoMerkle(true);
    setMerklePng(null);
    setMerkleData(null);
    try {
      const res = await api.getReporteMerkle();
      console.log("Respuesta completa de Merkle:", res);
      if (res && typeof res === "object") {
        if (res.png) {
          setMerklePng(res.png);
          console.log("PNG recibido:", res.png);
        } else {
          console.warn("La respuesta no contiene campo 'png'");
        }
        if (res.raiz && res.integridad && res.num_mensajes !== undefined) {
          setMerkleData({
            raiz: String(res.raiz),
            integridad: String(res.integridad),
            num_mensajes: Number(res.num_mensajes),
          });
          console.log("Datos extra guardados");
        } else {
          console.warn("Faltan datos extra en la respuesta", {
            raiz: res.raiz,
            integridad: res.integridad,
            num_mensajes: res.num_mensajes,
          });
        }
        if (res.png) toast.success("Árbol de Merkle generado");
      } else {
        toast.error("Respuesta inválida del servidor");
      }
    } catch (err) {
      console.error("Error capturado en generarMerkle:", err);
      toast.error("Error al generar Merkle");
    } finally {
      setCargandoMerkle(false);
    }
  };

  // ---------- Lista adyacencia ----------
  const generarListaAdyacencia = async () => {
    setLoading(true);
    try {
      const res = await api.getReporteListaAdyacencia();
      setListaAdyacencia(res.lista || "");
      toast.success("Lista de adyacencia cargada");
    } catch (err) {
      toast.error("Error al cargar lista");
    } finally {
      setLoading(false);
    }
  };

  // ---------- Tabla Hash ----------
  const generarTablaHash = async () => {
    setLoading(true);
    try {
      const res = await api.getReporteTablaHash();
      setTablaHashStats(res.estadisticas);
      toast.success("Estadísticas cargadas");
    } catch (err) {
      toast.error("Error al cargar estadísticas");
    } finally {
      setLoading(false);
    }
  };

  // ---------- Compresión ----------
  const generarReporteCompresion = async () => {
    setLoading(true);
    try {
      const res = await api.getReporteCompresion();
      setArchivosCompresion(res.archivos || []);
      toast.success("Reporte de compresión cargado");
    } catch (err) {
      toast.error("Error al cargar compresión");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Reportes Avanzados
      </h1>

      {/* Botones con estilo uniforme */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <button
          onClick={generarReporteGrafo}
          disabled={cargandoGrafo}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <Share2 className="h-6 w-6 text-primary-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Grafo de Colaboraciones</h3>
              <p className="text-sm text-gray-500">Visualización de la red</p>
            </div>
          </div>
          <Eye className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarReporteMatriz}
          disabled={cargandoMatriz}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-indigo-100 rounded-lg">
              <Database className="h-6 w-6 text-indigo-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Matriz Dispersa</h3>
              <p className="text-sm text-gray-500">
                Proveedores vs Fabricantes
              </p>
            </div>
          </div>
          <BarChart3 className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarMerkle}
          disabled={cargandoMerkle}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-amber-100 rounded-lg">
              <Hash className="h-6 w-6 text-amber-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Árbol de Merkle</h3>
              <p className="text-sm text-gray-500">Integridad de mensajes</p>
            </div>
          </div>
          <Eye className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarListaAdyacencia}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <FileText className="h-6 w-6 text-blue-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Lista de Adyacencia</h3>
              <p className="text-sm text-gray-500">Texto del grafo</p>
            </div>
          </div>
          <FileText className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarTablaHash}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-green-100 rounded-lg">
              <Hash className="h-6 w-6 text-green-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Tabla Hash</h3>
              <p className="text-sm text-gray-500">Estadísticas por tipo</p>
            </div>
          </div>
          <BarChart3 className="h-5 w-5 text-gray-400" />
        </button>

        <button
          onClick={generarReporteCompresion}
          disabled={loading}
          className="card flex items-center justify-between hover:shadow-lg"
        >
          <div className="flex items-center space-x-4">
            <div className="p-3 bg-purple-100 rounded-lg">
              <Database className="h-6 w-6 text-purple-600" />
            </div>
            <div className="text-left">
              <h3 className="font-semibold">Compresión LZW</h3>
              <p className="text-sm text-gray-500">Archivos .lzw</p>
            </div>
          </div>
          <BarChart3 className="h-5 w-5 text-gray-400" />
        </button>
      </div>

      {/* Imagen del Grafo */}
      {grafoPng && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Grafo de Colaboraciones
          </h2>
          <div className="bg-gray-100 rounded-lg overflow-x-auto p-2">
            <img
              src={grafoPng}
              alt="Grafo"
              className="max-w-full h-auto mx-auto"
            />
          </div>
        </div>
      )}

      {/* Imagen de la Matriz */}
      {matrizPng && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Matriz Dispersa
          </h2>
          <div className="bg-gray-100 rounded-lg overflow-x-auto p-2">
            <img
              src={matrizPng}
              alt="Matriz"
              className="max-w-full h-auto mx-auto"
            />
          </div>
        </div>
      )}

      {/* Bloque del Árbol de Merkle con protección extra */}
      {merklePng && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Árbol de Merkle
          </h2>
          <div className="bg-gray-100 rounded-lg overflow-x-auto p-2">
            <img
              src={`${merklePng}?t=${Date.now()}`}
              alt="Árbol de Merkle"
              className="max-w-full h-auto mx-auto"
              onError={(e) => {
                console.error("Error al cargar la imagen de Merkle");
                e.currentTarget.style.display = "none";
              }}
            />
          </div>
          {merkleData && (
            <div className="mt-4 space-y-2 text-sm">
              <p>
                <span className="font-medium">Hash raíz:</span>{" "}
                <code className="bg-gray-100 p-1 rounded break-all">
                  {merkleData.raiz}
                </code>
              </p>
              <p>
                <span className="font-medium">Integridad:</span>{" "}
                {merkleData.integridad}
              </p>
              <p>
                <span className="font-medium">Mensajes procesados:</span>{" "}
                {merkleData.num_mensajes}
              </p>
            </div>
          )}
          <p className="text-xs text-gray-500 mt-2">
            El árbol de Merkle garantiza la integridad de los mensajes de chat.
          </p>
        </div>
      )}

      {/* Lista de adyacencia */}
      {listaAdyacencia && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Lista de Adyacencia
          </h2>
          <pre className="bg-gray-900 text-green-400 p-4 rounded-lg overflow-x-auto text-sm">{listaAdyacencia}</pre>
        </div>
      )}

      {/* Tabla hash */}
      {tablaHashStats && (
        <div className="card mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Tabla Hash
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {Object.entries(tablaHashStats).map(([k, v]) => {
              if (k.startsWith("TIPO-")) {
                return (
                  <div key={k} className="bg-gray-50 p-3 rounded">
                    <p className="font-medium">{k}</p>
                    <p>Ocupación: {v.ocupacion}</p>
                    <p>Colisiones: {v.colisiones ? "Sí" : "No"}</p>
                  </div>
                );
              }
              return null;
            })}
          </div>
          <div className="mt-4 pt-2 border-t">
            Total ocupación: {tablaHashStats.total_ocupacion} | Colisiones:{" "}
            {tablaHashStats.total_colisiones}
          </div>
        </div>
      )}

      {/* Archivos LZW */}
      {archivosCompresion.length > 0 && (
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Archivos Comprimidos (LZW)
          </h2>
          <div className="space-y-2">
            {archivosCompresion.map((a, i) => (
              <div
                key={i}
                className="flex justify-between p-2 bg-gray-50 rounded"
              >
                <span>{a}</span>
                <span className="text-xs text-gray-500">.lzw</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
