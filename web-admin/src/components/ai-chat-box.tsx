"use client";

import { useState, useRef, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Bot, Send, X, MessageCircle, User } from "lucide-react";
import axiosClient from "@/lib/axios-client"; // Đảm bảo ông đã có file này cấu hình đúng baseURL

interface Message {
    id: number;
    text: string;
    sender: "user" | "bot";
}

export function AiChatBox() {
    const [isOpen, setIsOpen] = useState(false); // Trạng thái đóng/mở khung chat
    const [messages, setMessages] = useState<Message[]>([
        { id: 1, text: "Xin chào! Tôi là trợ lý AI BizFlow. Bạn cần giúp gì về đơn hàng hay kho bãi không?", sender: "bot" },
    ]);
    const [input, setInput] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    // Tự động cuộn xuống cuối khi có tin nhắn mới
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };
    useEffect(() => {
        scrollToBottom();
    }, [messages, isOpen]);

    const handleSend = async () => {
        if (!input.trim()) return;

        // 1. Hiển thị tin nhắn của User ngay lập tức
        const userMsg: Message = { id: Date.now(), text: input, sender: "user" };
        setMessages((prev) => [...prev, userMsg]);
        setInput("");
        setIsLoading(true);

        try {
            // 2. Gọi API xuống Backend (Cái ông bạn vừa code xong)
            const response = await axiosClient.post("/api/ai/chat", {
                prompt: input, // Gửi câu hỏi xuống
            });

            // 3. Nhận câu trả lời từ Gemini và hiển thị
            const botMsg: Message = {
                id: Date.now() + 1,
                text: response.data.answer, // Lấy trường 'answer' từ JSON trả về
                sender: "bot"
            };
            setMessages((prev) => [...prev, botMsg]);
        } catch (error) {
            console.error("Lỗi AI:", error);
            const errorMsg: Message = { id: Date.now() + 1, text: "Xin lỗi, server đang bận. Vui lòng thử lại sau.", sender: "bot" };
            setMessages((prev) => [...prev, errorMsg]);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="fixed bottom-6 right-6 z-50 flex flex-col items-end">
            {/* KHUNG CHAT (Chỉ hiện khi isOpen = true) */}
            {isOpen && (
                <Card className="w-80 h-96 mb-4 shadow-xl border-blue-200 flex flex-col animate-in slide-in-from-bottom-5">
                    <CardHeader className="bg-blue-600 text-white p-3 rounded-t-xl flex flex-row justify-between items-center">
                        <div className="flex items-center gap-2">
                            <Bot size={20} />
                            <CardTitle className="text-sm">Trợ lý BizFlow</CardTitle>
                        </div>
                        <Button variant="ghost" size="icon" className="h-6 w-6 text-white hover:bg-blue-700" onClick={() => setIsOpen(false)}>
                            <X size={16} />
                        </Button>
                    </CardHeader>

                    <CardContent className="flex-1 overflow-y-auto p-3 space-y-3 bg-slate-50">
                        {messages.map((msg) => (
                            <div key={msg.id} className={`flex ${msg.sender === "user" ? "justify-end" : "justify-start"}`}>
                                <div className={`max-w-[80%] p-2 rounded-lg text-sm ${
                                    msg.sender === "user"
                                        ? "bg-blue-500 text-white rounded-br-none"
                                        : "bg-white border border-slate-200 text-slate-800 rounded-bl-none shadow-sm"
                                }`}>
                                    {msg.text}
                                </div>
                            </div>
                        ))}
                        {isLoading && (
                            <div className="flex justify-start">
                                <div className="bg-slate-200 p-2 rounded-lg text-xs italic text-slate-500 animate-pulse">
                                    Đang suy nghĩ...
                                </div>
                            </div>
                        )}
                        <div ref={messagesEndRef} />
                    </CardContent>

                    <div className="p-3 border-t bg-white flex gap-2">
                        <Input
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={(e) => e.key === "Enter" && handleSend()}
                            placeholder="Hỏi gì đó..."
                            className="text-sm focus-visible:ring-blue-500"
                        />
                        <Button size="icon" className="bg-blue-600 hover:bg-blue-700" onClick={handleSend} disabled={isLoading}>
                            <Send size={16} />
                        </Button>
                    </div>
                </Card>
            )}

            {/* NÚT TRÒN ĐỂ MỞ CHAT */}
            {!isOpen && (
                <Button
                    onClick={() => setIsOpen(true)}
                    className="h-14 w-14 rounded-full bg-blue-600 hover:bg-blue-700 shadow-lg flex items-center justify-center transition-transform hover:scale-110"
                >
                    <MessageCircle size={28} />
                </Button>
            )}
        </div>
    );
}