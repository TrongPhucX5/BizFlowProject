"use client";

import { useState, useRef, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card } from "@/components/ui/card";
import {
  Bot,
  Send,
  X,
  MessageCircle,
  User,
  Mic,
  Loader2,
  Sparkles,
} from "lucide-react";
import axiosClient from "@/lib/axios-client";

interface Message {
  id: number;
  text: string;
  sender: "user" | "bot";
  time?: string; // Thêm hiển thị giờ
}

export function AiChatBox() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      text: "Xin chào! Tôi là Trợ lý AI BizFlow.\nBạn cần kiểm tra kho, xem doanh thu hay lên đơn hàng ngay bây giờ?",
      sender: "bot",
      time: new Date().toLocaleTimeString("vi-VN", {
        hour: "2-digit",
        minute: "2-digit",
      }),
    },
  ]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isRecording, setIsRecording] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Tự động cuộn xuống cuối
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    if (isOpen) scrollToBottom();
  }, [messages, isOpen]);

  // --- XỬ LÝ GỬI TIN NHẮN ---
  const handleSend = async () => {
    if (!input.trim()) return;

    const userText = input;
    const nowTime = new Date().toLocaleTimeString("vi-VN", {
      hour: "2-digit",
      minute: "2-digit",
    });

    // 1. Hiển thị tin nhắn User
    const userMsg: Message = {
      id: Date.now(),
      text: userText,
      sender: "user",
      time: nowTime,
    };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setIsLoading(true);

    try {
      // 2. Gửi xuống Backend
      const response = await axiosClient.post("/api/v1/ai/chat", {
        message: userText,
        history: [],
      });

      // 3. Hiển thị tin nhắn Bot
      const botMsg: Message = {
        id: Date.now() + 1,
        text: response.data.reply,
        sender: "bot",
        time: new Date().toLocaleTimeString("vi-VN", {
          hour: "2-digit",
          minute: "2-digit",
        }),
      };
      setMessages((prev) => [...prev, botMsg]);
    } catch (error: any) {
      console.error("Lỗi AI:", error);
      let errorText = "Hệ thống đang bận, vui lòng thử lại.";
      if (error.response?.status === 403) {
        errorText = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.";
      } else if (error.response?.status === 500) {
        errorText = "Lỗi kết nối Server AI. Vui lòng kiểm tra lại Backend.";
      }

      const errorMsg: Message = {
        id: Date.now() + 1,
        text: errorText,
        sender: "bot",
        time: nowTime,
      };
      setMessages((prev) => [...prev, errorMsg]);
    } finally {
      setIsLoading(false);
    }
  };

  // --- XỬ LÝ GIỌNG NÓI ---
  const handleVoiceInput = () => {
    if (!("webkitSpeechRecognition" in window)) {
      alert(
        "Trình duyệt không hỗ trợ nhận diện giọng nói (Chỉ hỗ trợ Chrome/Edge).",
      );
      return;
    }

    const SpeechRecognition = (window as any).webkitSpeechRecognition;
    const recognition = new SpeechRecognition();

    recognition.lang = "vi-VN";
    recognition.continuous = false;
    recognition.interimResults = false;

    recognition.onstart = () => setIsRecording(true);
    recognition.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript;
      setInput(transcript);
    };
    recognition.onerror = () => setIsRecording(false);
    recognition.onend = () => setIsRecording(false);
    recognition.start();
  };

  return (
    <div className="fixed bottom-6 right-6 z-[9999] flex flex-col items-end font-sans">
      {/* KHUNG CHAT */}
      {isOpen && (
        <Card className="w-[360px] md:w-[400px] h-[550px] mb-4 shadow-2xl border-0 flex flex-col animate-in slide-in-from-bottom-5 zoom-in-95 rounded-2xl overflow-hidden ring-1 ring-slate-200/50">
          {/* 1. HEADER HIỆN ĐẠI (Gradient) */}
          <div className="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 p-4 flex justify-between items-center shadow-md relative overflow-hidden">
            {/* Hiệu ứng nền nhẹ */}
            <div className="absolute top-0 left-0 w-full h-full bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10"></div>

            <div className="flex items-center gap-3 z-10">
              <div className="relative">
                <div className="p-2 bg-white/20 backdrop-blur-md rounded-full border border-white/30">
                  <Bot size={22} className="text-white" />
                </div>
                <span className="absolute bottom-0 right-0 w-3 h-3 bg-green-400 border-2 border-indigo-600 rounded-full"></span>
              </div>
              <div>
                <h3 className="text-white font-bold text-base leading-none">
                  Trợ lý BizFlow
                </h3>
                <p className="text-blue-100 text-xs mt-1 flex items-center gap-1">
                  <Sparkles size={10} /> Sẵn sàng hỗ trợ
                </p>
              </div>
            </div>
            <Button
              variant="ghost"
              size="icon"
              className="text-white/80 hover:text-white hover:bg-white/20 rounded-full transition-all z-10"
              onClick={() => setIsOpen(false)}
            >
              <X size={20} />
            </Button>
          </div>

          {/* 2. KHUNG TIN NHẮN (Màu xám nhạt) */}
          <div className="flex-1 overflow-y-auto p-4 space-y-5 bg-slate-50 scrollbar-thin scrollbar-thumb-slate-300 scrollbar-track-transparent">
            {messages.map((msg) => (
              <div
                key={msg.id}
                className={`flex flex-col ${msg.sender === "user" ? "items-end" : "items-start"}`}
              >
                <div
                  className={`flex max-w-[85%] ${msg.sender === "user" ? "flex-row-reverse" : "flex-row"} gap-2`}
                >
                  {/* Avatar nhỏ */}
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                      msg.sender === "user"
                        ? "bg-indigo-100 text-indigo-600"
                        : "bg-blue-600 text-white shadow-md"
                    }`}
                  >
                    {msg.sender === "user" ? (
                      <User size={14} />
                    ) : (
                      <Bot size={14} />
                    )}
                  </div>

                  {/* Bong bóng chat */}
                  <div
                    className={`p-3 rounded-2xl text-sm leading-relaxed shadow-sm break-words whitespace-pre-line ${
                      msg.sender === "user"
                        ? "bg-indigo-600 text-white rounded-tr-none" // User màu đậm
                        : "bg-white text-slate-800 border border-slate-100 rounded-tl-none" // Bot màu trắng
                    }`}
                  >
                    {msg.text}
                  </div>
                </div>
                {/* Thời gian */}
                <span
                  className={`text-[10px] text-slate-400 mt-1 mx-11 ${msg.sender === "user" ? "text-right" : "text-left"}`}
                >
                  {msg.time}
                </span>
              </div>
            ))}

            {/* Hiệu ứng đang gõ (Typing indicator) */}
            {isLoading && (
              <div className="flex items-start gap-2 animate-pulse">
                <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
                  <Bot size={14} className="text-white" />
                </div>
                <div className="bg-white border border-slate-100 px-4 py-3 rounded-2xl rounded-tl-none shadow-sm flex items-center gap-1">
                  <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:-0.3s]"></span>
                  <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:-0.15s]"></span>
                  <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce"></span>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* 3. INPUT AREA (Đẹp hơn) */}
          <div className="p-3 bg-white border-t border-slate-100">
            <div className="flex items-center gap-2 bg-slate-100 p-1.5 rounded-full border border-slate-200 focus-within:ring-2 focus-within:ring-indigo-100 focus-within:border-indigo-300 transition-all">
              {/* Nút Voice */}
              <Button
                type="button"
                variant="ghost"
                size="icon"
                onClick={handleVoiceInput}
                className={`rounded-full w-9 h-9 flex-shrink-0 transition-colors ${
                  isRecording
                    ? "bg-red-100 text-red-500 hover:bg-red-200"
                    : "text-slate-500 hover:bg-white hover:text-indigo-600 hover:shadow-sm"
                }`}
              >
                {isRecording ? (
                  <div className="w-2.5 h-2.5 bg-red-500 rounded-sm animate-pulse" />
                ) : (
                  <Mic size={18} />
                )}
              </Button>

              <Input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleSend()}
                placeholder="Nhập yêu cầu..."
                className="flex-1 border-none bg-transparent shadow-none focus-visible:ring-0 text-sm px-2 h-9"
                disabled={isLoading}
                autoComplete="off"
              />

              {/* Nút Gửi */}
              <Button
                size="icon"
                className={`rounded-full w-9 h-9 flex-shrink-0 shadow-sm transition-all ${
                  input.trim()
                    ? "bg-indigo-600 hover:bg-indigo-700 text-white hover:scale-105"
                    : "bg-slate-200 text-slate-400 cursor-not-allowed"
                }`}
                onClick={handleSend}
                disabled={isLoading || !input.trim()}
              >
                {isLoading ? (
                  <Loader2 size={16} className="animate-spin" />
                ) : (
                  <Send size={16} className="ml-0.5" />
                )}
              </Button>
            </div>
            <div className="text-center mt-2">
              <p className="text-[10px] text-slate-400">
                Powered by BizFlow AI & Gemini 2.5
              </p>
            </div>
          </div>
        </Card>
      )}

      {/* NÚT KÍCH HOẠT (Floating Button) */}
      {!isOpen && (
        <div className="relative group">
          {/* Tooltip */}
          <div className="absolute right-full mr-4 top-1/2 -translate-y-1/2 bg-slate-800 text-white text-xs px-3 py-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
            Chat với AI ngay!
            {/* Mũi tên tooltip */}
            <div className="absolute right-[-4px] top-1/2 -translate-y-1/2 w-2 h-2 bg-slate-800 rotate-45"></div>
          </div>

          <Button
            onClick={() => setIsOpen(true)}
            className="h-16 w-16 rounded-full bg-gradient-to-br from-blue-600 to-indigo-700 hover:from-blue-500 hover:to-indigo-600 shadow-2xl flex items-center justify-center transition-all hover:scale-110 active:scale-95 ring-4 ring-white/50"
          >
            <MessageCircle size={32} className="text-white" />

            {/* Vòng tròn sóng lan tỏa */}
            <span className="absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-20 animate-ping"></span>

            {/* Chấm đỏ thông báo */}
            <span className="absolute top-0 right-0 h-4 w-4">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-4 w-4 bg-red-500 border-2 border-white"></span>
            </span>
          </Button>
        </div>
      )}
    </div>
  );
}
