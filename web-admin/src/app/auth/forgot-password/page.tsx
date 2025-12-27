"use client";

import { useState, FormEvent } from "react";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ArrowLeft, Store, CheckCircle2, Building2 } from "lucide-react";

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
                text: "Hướng dẫn đã được gửi! Vui lòng kiểm tra email của bạn."
            });
        } catch (err: any) {
            setMessage({ type: 'error', text: "Email không tồn tại hoặc có lỗi xảy ra." });
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">

            {/* 1. CỘT TRÁI - BRANDING (GIỮ NGUYÊN) */}
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
                        Chúng tôi sẽ giúp bạn lấy lại mật khẩu nhanh chóng để tiếp tục công việc quản lý.
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

            {/* 2. CỘT PHẢI - FORM */}
            <div className="w-full lg:w-[40%] flex items-center justify-center p-8 bg-white relative">
                <div className="absolute top-[-10%] right-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

                <div className="w-full max-w-[450px] relative z-20">

                    <div className="mb-6 text-center lg:text-left">
                        {/* Đã sửa dòng này: Thêm hiệu ứng Gradient giống hệt trang Login */}
                        <h1 className="text-3xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-600 mb-4 pb-1">
                            Khôi phục mật khẩu
                        </h1>
                        <p className="text-slate-500 text-[15px] leading-relaxed">
                            Hãy nhập thông tin của bạn. Hướng dẫn khôi phục mật khẩu sẽ được gửi đến email của bạn.
                        </p>
                    </div>

                    {/* Đường kẻ mờ */}
                    <div className="w-full border-t border-slate-100 mb-8"></div>

                    {message && (
                        <div className={`p-4 rounded-xl text-sm flex items-start gap-3 shadow-sm mb-6 ${
                            message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'
                        }`}>
                            <span className="text-lg">{message.type === 'success' ? '✅' : '⚠️'}</span>
                            <span>{message.text}</span>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-6">
                        <div className="space-y-2">
                            <label className="text-sm font-bold text-slate-800 ml-1">
                                Email <span className="text-red-500">*</span>
                            </label>

                            <Input
                                type="email"
                                placeholder="Email của bạn"
                                className="h-12 rounded-lg border-slate-200 bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 text-base shadow-sm px-4"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                required
                                disabled={isLoading}
                            />
                        </div>

                        <Button
                            type="submit"
                            disabled={isLoading}
                            className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white font-bold text-base rounded-lg shadow-md transition-all"
                        >
                            {isLoading ? "Đang xử lý..." : "Khôi phục mật khẩu"}
                        </Button>
                    </form>

                    {/* Nút quay lại */}
                    <div className="mt-8 flex justify-center lg:justify-start">
                        <Link href="/auth/login" className="flex items-center text-slate-500 hover:text-blue-600 font-medium transition-colors text-sm">
                            <ArrowLeft className="w-4 h-4 mr-2" />
                            Quay lại đăng nhập
                        </Link>
                    </div>

                </div>
            </div>
        </div>
    );
}