import { useState } from "react";
import { api } from "../../../services/api";
import toast from "react-hot-toast";
import { Upload } from "lucide-react";

export default function CargarRelaciones() {
  const [file, setFile] = useState<File | null>(null);
  const [cargando, setCargando] = useState(false);
  const [resultado, setResultado] = useState<string | null>(null);

  const handleSubmit = async () => {
    if (!file) return toast.error("Seleccione un archivo JSON");
    setCargando(true);
    try {
      const res = await api.cargarRelaciones(file);
      setResultado(res.mensaje);
      toast.success("Relaciones cargadas correctamente");
      setFile(null);
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al cargar");
    } finally {
      setCargando(false);
    }
  };

  return (
    <div className="card max-w-2xl mx-auto">
      <h2 className="text-xl font-bold mb-4">
        Cargar Relaciones de Colaboración
      </h2>
      <p className="text-sm text-gray-600 mb-4">
        Archivo JSON con array de objetos:{" "}
        {'{ "solicitante": "COL-...", "receptor": "COL-...", "estado": "ACTIVA|PENDIENTE|RECHAZADA" }'}
      </p>
      <input
        type="file"
        accept=".json"
        onChange={(e) => setFile(e.target.files?.[0] || null)}
        className="mb-4"
      />
      <button
        onClick={handleSubmit}
        disabled={cargando || !file}
        className="btn-primary"
      >
        <Upload size={18} className="inline mr-2" />
        {cargando ? "Procesando..." : "Subir y procesar"}
      </button>
      {resultado && (
        <pre className="mt-4 bg-gray-100 p-2 rounded text-sm whitespace-pre-wrap">{resultado}</pre>
      )}
    </div>
  );
}
