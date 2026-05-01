import { useEffect, useRef, useState } from "react";
import { useAuth } from "../../../hooks/useAuth";
import { api, Colaborador, Conversacion, Mensaje } from "../../../services/api";
import toast from "react-hot-toast";
import { MessageCircle, Send, User } from "lucide-react";

type TimeoutHandle = ReturnType<typeof setTimeout>;

export default function Chat() {
  const { user } = useAuth();
  const [conversaciones, setConversaciones] = useState<Conversacion[]>([]);
  const [colaboradores, setColaboradores] = useState<Colaborador[]>([]);
  const [chatSeleccionado, setChatSeleccionado] = useState<string | null>(null);
  const [mensajes, setMensajes] = useState<Mensaje[]>([]);
  const [nuevoMensaje, setNuevoMensaje] = useState("");
  const [enviando, setEnviando] = useState(false);
  const [loading, setLoading] = useState(true);
  const [ultimoTimestamp, setUltimoTimestamp] = useState(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const intervalRef = useRef<TimeoutHandle | null>(null);

  useEffect(() => {
    cargarDatosIniciales();
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  useEffect(() => {
    if (chatSeleccionado) {
      cargarMensajes();
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
      intervalRef.current = setInterval(() => {
        cargarMensajes(true);
      }, 3000);
    }
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [chatSeleccionado]);

  useEffect(() => {
    scrollToBottom();
  }, [mensajes]);

  const cargarDatosIniciales = async () => {
    try {
      const [conversacionesRes, colaboradoresRes] = await Promise.all([
        api.getConversaciones(),
        api.getColaboradores(),
      ]);
      setConversaciones(conversacionesRes.conversaciones || []);
      setColaboradores(colaboradoresRes.colaboradores || []);
    } catch (error) {
      toast.error("Error al cargar conversaciones");
    } finally {
      setLoading(false);
    }
  };

  const cargarMensajes = async (silencioso: boolean = false) => {
    if (!chatSeleccionado) return;

    try {
      const response = await api.getMensajes(chatSeleccionado, ultimoTimestamp);
      if (response.mensajes && response.mensajes.length > 0) {
        setMensajes((prev) => {
          const nuevos = response.mensajes.filter(
            (msg: Mensaje) => !prev.some((p) => p.timestamp === msg.timestamp),
          );
          if (nuevos.length > 0) {
            const maxTimestamp = Math.max(
              ...nuevos.map((m: Mensaje) => m.timestamp),
            );
            setUltimoTimestamp(maxTimestamp);
            return [...prev, ...nuevos];
          }
          return prev;
        });
      }
    } catch (error) {
      if (!silencioso) {
        toast.error("Error al cargar mensajes");
      }
    }
  };

  const enviarMensaje = async () => {
    if (!chatSeleccionado || !nuevoMensaje.trim()) return;

    setEnviando(true);
    try {
      await api.enviarMensaje(chatSeleccionado, nuevoMensaje);
      setNuevoMensaje("");
      await cargarMensajes();
    } catch (error: any) {
      toast.error(error.response?.data?.error || "Error al enviar mensaje");
    } finally {
      setEnviando(false);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      enviarMensaje();
    }
  };

  const getNombreColaborador = (colegio: string) => {
    const colab = colaboradores.find((c) => c.colegio === colegio);
    return colab?.nombre || colegio;
  };

  const formatFecha = (timestamp: number) => {
    const date = new Date(timestamp * 1000);
    const hoy = new Date();
    const ayer = new Date(hoy);
    ayer.setDate(ayer.getDate() - 1);

    if (date.toDateString() === hoy.toDateString()) {
      return date.toLocaleTimeString("es-ES", {
        hour: "2-digit",
        minute: "2-digit",
      });
    } else if (date.toDateString() === ayer.toDateString()) {
      return `Ayer ${
        date.toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" })
      }`;
    } else {
      return date.toLocaleDateString("es-ES", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
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
        Mensajería Interna
      </h1>

      <div className="bg-white rounded-xl shadow-md overflow-hidden h-[calc(100vh-200px)]">
        <div className="flex h-full">
          {/* Lista de conversaciones */}
          <div className="w-80 border-r border-gray-200 flex flex-col">
            <div className="p-4 border-b border-gray-200 bg-gray-50">
              <h2 className="font-semibold text-gray-900">Conversaciones</h2>
              <p className="text-sm text-gray-500">Tus colaboradores</p>
            </div>
            <div className="flex-1 overflow-y-auto">
              {conversaciones.length === 0
                ? (
                  <div className="text-center py-8">
                    <MessageCircle className="h-12 w-12 mx-auto text-gray-400 mb-3" />
                    <p className="text-gray-500">No hay conversaciones aún</p>
                    <p className="text-xs text-gray-400">
                      Envía un mensaje a un colaborador
                    </p>
                  </div>
                )
                : (
                  conversaciones.map((conv) => (
                    <button
                      key={conv.colegio}
                      onClick={() => {
                        setChatSeleccionado(conv.colegio);
                        setMensajes([]);
                        setUltimoTimestamp(0);
                      }}
                      className={`w-full p-4 text-left hover:bg-gray-50 transition-colors border-b border-gray-100 ${
                        chatSeleccionado === conv.colegio ? "bg-primary-50" : ""
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                          <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                            <User className="h-5 w-5 text-primary-600" />
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">
                              {getNombreColaborador(conv.colegio)}
                            </p>
                            <p className="text-sm text-gray-500 truncate max-w-[150px]">
                              {conv.ultimo_mensaje}
                            </p>
                          </div>
                        </div>
                        <p className="text-xs text-gray-400">
                          {formatFecha(conv.timestamp)}
                        </p>
                      </div>
                    </button>
                  ))
                )}
            </div>
          </div>

          {/* Área de chat */}
          {chatSeleccionado
            ? (
              <div className="flex-1 flex flex-col">
                <div className="p-4 border-b border-gray-200 bg-gray-50">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                      <User className="h-5 w-5 text-primary-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">
                        {getNombreColaborador(chatSeleccionado)}
                      </h3>
                      <p className="text-xs text-gray-500">
                        {chatSeleccionado}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="flex-1 overflow-y-auto p-4 space-y-3">
                  {mensajes.map((msg, idx) => {
                    const esMio = msg.remitente === user?.colegio;
                    return (
                      <div
                        key={idx}
                        className={`flex ${
                          esMio ? "justify-end" : "justify-start"
                        }`}
                      >
                        <div
                          className={`max-w-[70%] px-4 py-2 rounded-lg ${
                            esMio
                              ? "bg-primary-600 text-white rounded-br-none"
                              : "bg-gray-100 text-gray-900 rounded-bl-none"
                          }`}
                        >
                          <p className="text-sm">{msg.contenido}</p>
                          <p
                            className={`text-xs mt-1 ${
                              esMio ? "text-primary-200" : "text-gray-500"
                            }`}
                          >
                            {formatFecha(msg.timestamp)}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                  <div ref={messagesEndRef} />
                </div>

                <div className="p-4 border-t border-gray-200">
                  <div className="flex space-x-2">
                    <textarea
                      value={nuevoMensaje}
                      onChange={(e) => setNuevoMensaje(e.target.value)}
                      onKeyDown={handleKeyDown}
                      placeholder="Escribe un mensaje..."
                      className="flex-1 input resize-none"
                      rows={2}
                    />
                    <button
                      onClick={enviarMensaje}
                      disabled={enviando || !nuevoMensaje.trim()}
                      className="btn-primary self-end"
                    >
                      <Send size={18} />
                    </button>
                  </div>
                </div>
              </div>
            )
            : (
              <div className="flex-1 flex items-center justify-center">
                <div className="text-center">
                  <MessageCircle className="h-16 w-16 mx-auto text-gray-300 mb-4" />
                  <h3 className="text-lg font-medium text-gray-500">
                    Selecciona una conversación
                  </h3>
                  <p className="text-sm text-gray-400">
                    Para comenzar a chatear con un colaborador
                  </p>
                </div>
              </div>
            )}
        </div>
      </div>
    </div>
  );
}
