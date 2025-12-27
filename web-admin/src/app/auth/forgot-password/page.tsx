"use client";

import { useState, FormEvent } from "react";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Mail, ArrowLeft, ArrowRight, Store, CheckCircle2, Building2 } from "lucide-react";

export default function ForgotPasswordPage() {
    const [email, setEmail] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null);

    const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setIsLoading(true);
        setMessage(null);

        try {
            await axiosClient.post("/v1/auth/forgot-password", { email });

            setMessage({
                type: 'success',
                text: "Đã gửi hướng dẫn! Vui lòng kiểm tra email của bạn."
            });
        } catch (err: any) {
            setMessage({ type: 'error', text: "Email không tồn tại hoặc có lỗi xảy ra." });
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
            {/* 1. CỘT TRÁI (GIỮ NGUYÊN) */}
            <div className="hidden lg:flex lg:w-[60%] bg-blue-700 flex-col justify-center px-20 xl:px-32 text-white relative lg:rounded-r-[80px] z-10 shadow-2xl">
                <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_30%_20%,_rgba(255,255,255,0.1)_0%,_transparent_50%)] rounded-r-[80px]"></div>
                <div className="absolute top-10 right-20 opacity-10 transform rotate-12">
                    <Building2 size={400} strokeWidth={0.5} />
                </div>

                <div className="z-10 relative">
                    <div className="flex items-center gap-3 mb-10">
                        <div className="p-2.5 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20 shadow-inner">
                            <Store className="w-8 h-8 text-white" />
                        </div>
                        <span className="text-3xl font-bold tracking-tight">BizFlow</span>
                    </div>

                    <h1 className="text-5xl xl:text-6xl font-extrabold mb-8 leading-tight tracking-tight drop-shadow-sm">
                        Khôi phục <br/>
                        <span className="text-blue-200">Truy cập.</span>
                    </h1>

                    <p className="text-blue-100 text-xl max-w-lg mb-10 leading-relaxed font-light">
                        Lấy lại mật khẩu nhanh chóng để tiếp tục công việc quản lý.
                    </p>

                    <div className="space-y-6">
                        <div className="flex items-center gap-4">
                            <div className="p-2 bg-blue-600/80 rounded-full ring-2 ring-blue-500/50">
                                <CheckCircle2 className="w-6 h-6 text-white" />
                            </div>
                            <span className="text-lg font-medium text-blue-50">Bảo mật & An toàn</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* 2. CỘT PHẢI (ĐÃ CHỈNH SỬA) */}
            <div className="w-full lg:w-[40%] flex items-center justify-center p-8 bg-white relative">
                <div className="absolute top-[-10%] right-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

                {/* Thêm class lg:-mt-20 để kéo cả khối này lên cao hơn trên màn hình lớn */}
                <div className="w-full max-w-[450px] relative z-20 lg:-mt-20">

                    <Link href="/auth/login" className="inline-flex items-center text-sm text-slate-500 hover:text-blue-600 mb-6 transition-colors group font-medium">
                        <ArrowLeft className="w-4 h-4 mr-2 group-hover:-translate-x-1 transition-transform" />
                        Quay lại Đăng nhập
                    </Link>

                    <div className="mb-8">
                        <h2 className="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-700 to-indigo-600 mb-2">
                            Quên mật khẩu?
                        </h2>
                        {/* Văn bản ngắn gọn hơn */}
                        <p className="text-slate-500 text-base">
                            Nhập email để nhận link đặt lại mật khẩu mới.
                        </p>
                    </div>

                    {message && (
                        <div className={`p-4 rounded-xl text-sm flex items-start gap-3 shadow-sm mb-6 ${
                            message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'
                        }`}>
                            <span className="text-lg">{message.type === 'success' ? '✅' : '⚠️'}</span>
                            <span>{message.text}</span>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-5">
                        <div className="space-y-2">
                            <label className="text-sm font-semibold text-slate-700 ml-1">Email</label>
                            <div className="relative group">
                                <Mail className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                <Input
                                    type="email"
                                    placeholder="admin@bizflow.com"
                                    className="pl-12 h-12 rounded-xl border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all text-base shadow-sm"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                    disabled={isLoading}
                                />
                            </div>
                        </div>

                        <Button
                            type="submit"
                            disabled={isLoading}
                            className="w-full h-12 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold text-base rounded-xl shadow-lg shadow-blue-600/30 hover:shadow-blue-600/50 transition-all duration-300 transform hover:-translate-y-0.5"
                        >
                            {isLoading ? "Đang gửi..." : "Gửi yêu cầu"}
                            {!isLoading && <ArrowRight className="ml-2 w-5 h-5" />}
                        </Button>
                    </form>
                </div>
            </div>
        </div>
    );
}