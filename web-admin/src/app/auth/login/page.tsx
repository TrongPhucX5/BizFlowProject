"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Lock, Mail, ArrowRight, Store, CheckCircle2, Eye, EyeOff, Building2 } from "lucide-react";



interface LoginRequest {
  username: string;
  password: string;
}

export default function LoginPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState<LoginRequest>({
    username: "",
    password: "",
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (error) setError("");
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const response = await axiosClient.post("/v1/auth/login", formData);
      // Kết cấu response: response.data.result (chứa token, user...)
      const result = response.data?.result;

      if (result?.token) {
        // 0. Xóa dữ liệu cũ
        localStorage.clear();

        // 1. Lưu Tokens
        localStorage.setItem("accessToken", result.token);
        if (result.refreshToken) {
          localStorage.setItem("refreshToken", result.refreshToken);
        }

        // 2. XỬ LÝ DỮ LIỆU NGƯỜI DÙNG (Lấy từ object 'user' lồng bên trong LoginResponse)
        const userData = result.user || {}; 
        
        // Cập nhật đầy đủ các trường để trang Account hiển thị
        const fullName = userData.fullName || result.fullName || formData.username;
        const email = userData.email || result.email || "";
        const phone = userData.phone || result.phone || "";
        const storeName = userData.storeName || result.storeName || "BizFlow Store";
        const userRole = (userData.role || result.role || "EMPLOYEE").toUpperCase();
        const userId = userData.id || result.userId;

        localStorage.setItem("userFullName", fullName);
        localStorage.setItem("userEmail", email);
        localStorage.setItem("userPhone", phone); // <--- QUAN TRỌNG NHẤT
        localStorage.setItem("username", formData.username);
        localStorage.setItem("storeName", storeName);
        localStorage.setItem("userRole", userRole);
        if (userId) localStorage.setItem("userId", userId.toString());

        // 3. Kích hoạt sự kiện để các Component khác (như Sidebar/Navbar) cập nhật ngay
        window.dispatchEvent(new Event("storage"));

        // 4. Điều hướng
        if (userRole === "ADMIN") {
          router.push("/admin/dashboard");
        } else {
          router.push("/dashboard");
        }
        
        router.refresh(); 
      } else {
        setError("Đăng nhập thất bại. Không nhận được phản hồi hợp lệ.");
      }
    } catch (err: any) {
      setError(err.response?.data?.message || "Sai tài khoản hoặc mật khẩu.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    alert("Tính năng đang phát triển!");
  };

  return (
    <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
      {/* CỘT TRÁI - BRANDING */}
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
          <h1 className="text-5xl xl:text-6xl font-extrabold mb-8 leading-tight tracking-tight">
            Quản lý cửa hàng <br/>
            <span className="text-blue-200">Hiệu quả hơn.</span>
          </h1>
          <p className="text-blue-100 text-xl max-w-lg mb-10 leading-relaxed font-light">
            Giải pháp chuyển đổi số toàn diện từ quản lý kho đến chăm sóc khách hàng.
          </p>
          <div className="space-y-6">
            <div className="flex items-center gap-4">
              <div className="p-2 bg-blue-600/80 rounded-full ring-2 ring-blue-500/50">
                <CheckCircle2 className="w-6 h-6 text-white" />
              </div>
              <span className="text-lg font-medium text-blue-50">Báo cáo doanh thu thời gian thực</span>
            </div>
          </div>
        </div>
      </div>

      {/* CỘT PHẢI - LOGIN FORM */}
      <div className="w-full lg:w-[40%] flex items-center justify-center p-8 bg-white relative">
        <div className="w-full max-w-[450px] relative z-20">
          <div className="text-center mb-10">
            <h2 className="text-4xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-600 pb-1">
              Đăng nhập
            </h2>
            <p className="text-slate-500 mt-3 text-base">Chào mừng bạn quay trở lại!</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <div className="p-4 bg-red-50 border border-red-100 text-red-600 rounded-xl text-sm flex items-start gap-3 animate-in fade-in zoom-in duration-300">
                <span>⚠️ {error}</span>
              </div>
            )}

            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700 ml-1">Tên đăng nhập / Email</label>
              <div className="relative group">
                <Mail className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                <Input
                  name="username"
                  placeholder="Nhập tài khoản (VD: QuocBao)"
                  className="pl-12 h-12 rounded-xl border-slate-200 bg-slate-50/50 focus:bg-white transition-all focus:ring-2 focus:ring-blue-100"
                  value={formData.username}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-semibold text-slate-700 ml-1">Mật khẩu</label>
              <div className="relative group">
                <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                <Input
                  name="password"
                  type={showPassword ? "text" : "password"}
                  placeholder="Nhập mật khẩu"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  className="pl-12 pr-12 h-12 rounded-xl border-slate-200 bg-slate-50/50 focus:bg-white transition-all focus:ring-2 focus:ring-blue-100"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-3.5 text-slate-400 hover:text-blue-600 transition-colors"
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              </div>
            </div>

            <Button
              type="submit"
              disabled={isLoading}
              className="w-full h-12 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-lg transition-all active:scale-[0.98]"
            >
              {isLoading ? "Đang xử lý..." : "Đăng nhập ngay"}
              {!isLoading && <ArrowRight className="ml-2 w-5 h-5" />}
            </Button>
          </form>

      

          <div className="mt-10 text-center">
            <p className="text-slate-500 text-sm">
              Bạn chưa có tài khoản?{" "}
              <Link href="/auth/register" className="text-blue-700 font-bold hover:underline underline-offset-4">
                Đăng ký ngay
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}