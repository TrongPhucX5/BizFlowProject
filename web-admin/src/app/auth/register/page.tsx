"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { Lock, Mail, User, Phone, ArrowRight, Store, CheckCircle2, Eye, EyeOff, Building2 } from "lucide-react";

// Đã loại bỏ GoogleIcon vì không dùng đến

export default function RegisterPage() {
    const router = useRouter();
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");
    const [showPassword, setShowPassword] = useState(false);

    const [formData, setFormData] = useState({
        fullName: "",
        email: "",
        phone: "",
        password: "",
        confirmPassword: "",
    });

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData((prev) => ({ ...prev, [name]: value }));
        if (error) setError("");
    };

    const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setError("");

        // Validate cơ bản
        if (formData.password !== formData.confirmPassword) {
            setError("Mật khẩu xác nhận không khớp!");
            return;
        }

        setIsLoading(true);

        try {
            // Gọi API đăng ký (endpoint giả định)
            await axiosClient.post("/v1/auth/register", {
                fullName: formData.fullName,
                email: formData.email,
                phone: formData.phone,
                password: formData.password
            });

            alert("Đăng ký thành công! Vui lòng đăng nhập.");
            router.push("/auth/login");

        } catch (err: any) {
            setError(err.response?.data?.message || "Đăng ký thất bại. Vui lòng thử lại.");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
            {/* 1. CỘT TRÁI - BRANDING (Giống Login) */}
            <div className="hidden lg:flex lg:w-[55%] bg-blue-700 flex-col justify-center px-16 xl:px-24 text-white relative lg:rounded-r-[80px] z-10 shadow-2xl">
                <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_30%_20%,_rgba(255,255,255,0.1)_0%,_transparent_50%)] rounded-r-[80px]"></div>
                <div className="absolute top-10 right-20 opacity-10 transform rotate-12">
                    <Building2 size={400} strokeWidth={0.5} />
                </div>

                <div className="z-10 relative">
                    <div className="flex items-center gap-3 mb-8">
                        <div className="p-2.5 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20 shadow-inner">
                            <Store className="w-8 h-8 text-white" />
                        </div>
                        <span className="text-3xl font-bold tracking-tight">BizFlow</span>
                    </div>

                    <h1 className="text-4xl xl:text-5xl font-extrabold mb-6 leading-tight tracking-tight drop-shadow-sm">
                        Bắt đầu hành trình <br/>
                        <span className="text-blue-200">Kinh doanh số.</span>
                    </h1>

                    <p className="text-blue-100 text-lg max-w-lg mb-8 leading-relaxed font-light">
                        Tạo tài khoản miễn phí ngay hôm nay để trải nghiệm bộ công cụ quản lý vật liệu xây dựng hàng đầu.
                    </p>

                    <div className="space-y-4">
                        <div className="flex items-center gap-4">
                            <CheckCircle2 className="w-6 h-6 text-blue-300" />
                            <span className="text-base font-medium text-blue-50">Quản lý kho hàng & Công nợ</span>
                        </div>
                        <div className="flex items-center gap-4">
                            <CheckCircle2 className="w-6 h-6 text-blue-300" />
                            <span className="text-base font-medium text-blue-50">Không cần thẻ tín dụng</span>
                        </div>
                        <div className="flex items-center gap-4">
                            <CheckCircle2 className="w-6 h-6 text-blue-300" />
                            <span className="text-base font-medium text-blue-50">Hỗ trợ cài đặt 1-1</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* 2. CỘT PHẢI - FORM ĐĂNG KÝ */}
            <div className="w-full lg:w-[45%] flex items-center justify-center p-6 bg-white relative">
                {/* Bóng nền trang trí */}
                <div className="absolute top-[-10%] right-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

                <div className="w-full max-w-[500px] relative z-20">

                    <div className="text-center mb-6">
                        <h2 className="text-3xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-600 pb-1">
                            Đăng ký tài khoản
                        </h2>
                        <p className="text-slate-500 mt-2 text-sm">
                            Đã có tài khoản?{" "}
                            <Link href="/auth/login" className="text-blue-700 font-bold hover:underline transition-all">
                                Đăng nhập ngay
                            </Link>
                        </p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-4">

                        {error && (
                            <div className="p-3 bg-red-50 border border-red-100 text-red-600 rounded-lg text-sm flex items-start gap-2">
                                <span>⚠️</span><span>{error}</span>
                            </div>
                        )}

                        {/* Họ tên */}
                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Họ và tên</label>
                            <div className="relative group">
                                <User className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                <Input name="fullName" placeholder="Nhập tên của bạn" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white focus:border-blue-500 transition-all" value={formData.fullName} onChange={handleChange} required />
                            </div>
                        </div>

                        {/* Email & Phone (Chia đôi cột) */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-700 uppercase ml-1">Email</label>
                                <div className="relative group">
                                    <Mail className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                    <Input type="email" name="email" placeholder="email@example.com" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white focus:border-blue-500 transition-all" value={formData.email} onChange={handleChange} required />
                                </div>
                            </div>
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-700 uppercase ml-1">Số điện thoại</label>
                                <div className="relative group">
                                    <Phone className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                    <Input type="tel" name="phone" placeholder="0909..." className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white focus:border-blue-500 transition-all" value={formData.phone} onChange={handleChange} required />
                                </div>
                            </div>
                        </div>

                        {/* Mật khẩu */}
                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Mật khẩu</label>
                            <div className="relative group">
                                <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                <Input name="password" type={showPassword ? "text" : "password"} placeholder="******" className="pl-12 pr-10 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white focus:border-blue-500 transition-all" value={formData.password} onChange={handleChange} required />
                                <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-3.5 text-slate-400 hover:text-slate-600">
                                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                                </button>
                            </div>
                        </div>

                        {/* Nhập lại mật khẩu */}
                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Xác nhận mật khẩu</label>
                            <div className="relative group">
                                <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                                <Input name="confirmPassword" type="password" placeholder="******" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white focus:border-blue-500 transition-all" value={formData.confirmPassword} onChange={handleChange} required />
                            </div>
                        </div>

                        <div className="flex items-start space-x-3 py-2 ml-1">
                            <Checkbox id="terms" className="mt-1 border-slate-300 data-[state=checked]:bg-blue-600" required />
                            <label htmlFor="terms" className="text-xs text-slate-600 leading-snug">
                                Tôi đồng ý với <Link href="#" className="text-blue-600 font-bold hover:underline">Điều khoản</Link> và <Link href="#" className="text-blue-600 font-bold hover:underline">Chính sách bảo mật</Link>.
                            </label>
                        </div>

                        <Button type="submit" disabled={isLoading} className="w-full h-11 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold rounded-xl shadow-lg shadow-blue-600/30 transition-all transform hover:-translate-y-0.5">
                            {isLoading ? "Đang tạo tài khoản..." : "Đăng ký "}
                            {!isLoading && <ArrowRight className="ml-2 w-5 h-5" />}
                        </Button>
                    </form>

                    {/* Đã bỏ nút Google và thanh ngăn cách ở đây */}

                </div>
            </div>
        </div>
    );
}