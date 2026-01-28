"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { 
  Lock, Mail, User, Phone, ArrowRight, Store, 
  CheckCircle2, Eye, EyeOff, Building2, AtSign, Loader2 
} from "lucide-react";

export default function RegisterPage() {
    const router = useRouter();
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");
    const [showPassword, setShowPassword] = useState(false);

    const [formData, setFormData] = useState({
        username: "",
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

        // 1. Kiểm tra khớp mật khẩu
        if (formData.password !== formData.confirmPassword) {
            setError("Mật khẩu xác nhận không khớp!");
            return;
        }

        // 2. Kiểm tra độ dài mật khẩu (Khớp với @Size(min=6) ở Backend)
        if (formData.password.length < 6) {
            setError("Mật khẩu phải có ít nhất 6 ký tự.");
            return;
        }

        setIsLoading(true);

        try {
            // Gửi dữ liệu tới API /v1/auth/register
            // Backend CreateUserUseCase sẽ tự động gán storeId = 1L nếu chúng ta không gửi storeId
            await axiosClient.post("/v1/auth/register", {
                username: formData.username.trim(),
                password: formData.password,
                fullName: formData.fullName.trim(),
                email: formData.email.trim(),
                phone: formData.phone.trim(),
                // Không cần gửi storeId vì Backend đã tự xử lý gán mặc định là 1
            });

            // Thay alert bằng thông báo hoặc điều hướng ngay
            router.push("/auth/login?registered=true");

        } catch (err: any) {
            // Lấy message từ ApiResponse.java của Backend
            const message = err.response?.data?.message || "Đăng ký thất bại. Vui lòng thử lại.";
            setError(message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
            {/* CỘT TRÁI - BRANDING (Giữ nguyên giao diện đẹp của bạn) */}
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

                    <h1 className="text-4xl xl:text-5xl font-extrabold mb-6 leading-tight tracking-tight">
                        Bắt đầu hành trình <br/>
                        <span className="text-blue-200">Kinh doanh số.</span>
                    </h1>

                    <div className="space-y-4">
                        <div className="flex items-center gap-4">
                            <CheckCircle2 className="w-6 h-6 text-blue-300" />
                            <span className="text-base font-medium text-blue-50">Quản lý kho hàng & Công nợ</span>
                        </div>
                        <div className="flex items-center gap-4">
                            <CheckCircle2 className="w-6 h-6 text-blue-300" />
                            <span className="text-base font-medium text-blue-50">Dữ liệu bảo mật tuyệt đối</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* CỘT PHẢI - FORM ĐĂNG KÝ */}
            <div className="w-full lg:w-[45%] flex items-center justify-center p-6 bg-white relative">
                <div className="w-full max-w-[500px] relative z-20">
                    <div className="text-center mb-6">
                        <h2 className="text-3xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-600 pb-1">
                            Đăng ký tài khoản
                        </h2>
                        <p className="text-slate-500 mt-2 text-sm">
                            Đã có tài khoản?{" "}
                            <Link href="/auth/login" className="text-blue-700 font-bold hover:underline">
                                Đăng nhập ngay
                            </Link>
                        </p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-4">
                        {error && (
                            <div className="p-3 bg-red-50 border border-red-100 text-red-600 rounded-lg text-sm flex items-start gap-2 animate-in fade-in slide-in-from-top-1">
                                <span>⚠️</span><span>{error}</span>
                            </div>
                        )}

                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Họ và tên</label>
                            <div className="relative group">
                                <User className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                <Input name="fullName" placeholder="Nguyễn Văn A" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.fullName} onChange={handleChange} required />
                            </div>
                        </div>

                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Tên đăng nhập</label>
                            <div className="relative group">
                                <AtSign className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                <Input name="username" placeholder="user123" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.username} onChange={handleChange} required />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-700 uppercase ml-1">Email</label>
                                <div className="relative group">
                                    <Mail className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                    <Input type="email" name="email" placeholder="example@gmail.com" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.email} onChange={handleChange} required />
                                </div>
                            </div>
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-slate-700 uppercase ml-1">Số điện thoại</label>
                                <div className="relative group">
                                    <Phone className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                    <Input type="tel" name="phone" placeholder="09..." className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.phone} onChange={handleChange} required />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Mật khẩu</label>
                            <div className="relative group">
                                <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                <Input name="password" type={showPassword ? "text" : "password"} placeholder="Tối thiểu 6 ký tự" className="pl-12 pr-10 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.password} onChange={handleChange} required />
                                <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-3.5 text-slate-400 hover:text-slate-600">
                                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                                </button>
                            </div>
                        </div>

                        <div className="space-y-1">
                            <label className="text-xs font-bold text-slate-700 uppercase ml-1">Xác nhận mật khẩu</label>
                            <div className="relative group">
                                <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600" />
                                <Input name="confirmPassword" type="password" placeholder="Nhập lại mật khẩu" className="pl-12 h-11 rounded-xl bg-slate-50 border-slate-200 focus:bg-white transition-all" value={formData.confirmPassword} onChange={handleChange} required />
                            </div>
                        </div>

                        <div className="flex items-start space-x-3 py-2">
                            <Checkbox id="terms" className="mt-1 data-[state=checked]:bg-blue-700 data-[state=checked]:border-blue-700" required />
                            <label htmlFor="terms" className="text-xs text-slate-600 leading-normal">
                                Tôi đồng ý với <span className="text-blue-700 font-medium">Điều khoản dịch vụ</span> và <span className="text-blue-700 font-medium">Chính sách bảo mật</span>.
                            </label>
                        </div>

                        <Button type="submit" disabled={isLoading} className="w-full h-11 bg-blue-700 hover:bg-blue-800 text-white font-bold rounded-xl shadow-blue-200 shadow-lg transition-all active:scale-[0.98]">
                            {isLoading ? (
                                <span className="flex items-center gap-2">
                                    <Loader2 className="w-5 h-5 animate-spin" /> Đang xử lý...
                                </span>
                            ) : (
                                <span className="flex items-center gap-2">
                                    Đăng ký ngay <ArrowRight className="w-5 h-5" />
                                </span>
                            )}
                        </Button>
                    </form>
                </div>
            </div>
        </div>
    );
}