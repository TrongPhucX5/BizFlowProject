"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
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
      if (response.data?.result?.token) {
        localStorage.setItem("accessToken", response.data.result.token);
        if (response.data.result.refreshToken) {
          localStorage.setItem("refreshToken", response.data.result.refreshToken);
        }
        router.push("/");
      } else {
        setError("Đăng nhập thất bại. Vui lòng thử lại.");
      }
    } catch (err: any) {
      setError(err.response?.data?.message || "Có lỗi xảy ra. Vui lòng thử lại.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
      <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
        {/* 1. PHẦN MÀU XANH (BRANDING)
        - lg:rounded-r-[80px]: Đây là chìa khóa để bo tròn góc giao nhau.
        - mr-[-20px]: Tạo hiệu ứng lồng ghép nhẹ (tùy chọn, ở đây mình giữ bo tròn thuần túy).
      */}
        <div className="hidden lg:flex lg:w-[60%] bg-blue-700 flex-col justify-center px-20 xl:px-32 text-white relative lg:rounded-r-[80px] z-10 shadow-2xl">

          {/* Background Patterns */}
          <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_30%_20%,_rgba(255,255,255,0.1)_0%,_transparent_50%)] rounded-r-[80px]"></div>
          <div className="absolute top-10 right-20 opacity-10 transform rotate-12">
            <Building2 size={400} strokeWidth={0.5} />
          </div>

          {/* Nội dung Branding */}
          <div className="z-10 relative">
            <div className="flex items-center gap-3 mb-10">
              <div className="p-2.5 bg-white/10 backdrop-blur-sm rounded-xl border border-white/20 shadow-inner">
                <Store className="w-8 h-8 text-white" />
              </div>
              <span className="text-3xl font-bold tracking-tight">BizFlow</span>
            </div>

            <h1 className="text-5xl xl:text-6xl font-extrabold mb-8 leading-tight tracking-tight drop-shadow-sm">
              Quản lý cửa hàng <br/>
              <span className="text-blue-200">Hiệu quả hơn.</span>
            </h1>

            <p className="text-blue-100 text-xl max-w-lg mb-10 leading-relaxed font-light">
              Giải pháp chuyển đổi số toàn diện: Từ quản lý kho, công nợ đến chăm sóc khách hàng tự động bằng AI.
            </p>

            <div className="space-y-6">
              <div className="flex items-center gap-4 group cursor-default">
                <div className="p-2 bg-blue-600/80 rounded-full ring-2 ring-blue-500/50 group-hover:bg-blue-500 transition-all">
                  <CheckCircle2 className="w-6 h-6 text-white" />
                </div>
                <span className="text-lg font-medium text-blue-50">Báo cáo doanh thu thời gian thực</span>
              </div>
              <div className="flex items-center gap-4 group cursor-default">
                <div className="p-2 bg-blue-600/80 rounded-full ring-2 ring-blue-500/50 group-hover:bg-blue-500 transition-all">
                  <CheckCircle2 className="w-6 h-6 text-white" />
                </div>
                <span className="text-lg font-medium text-blue-50">Trợ lý ảo AI soạn đơn hàng</span>
              </div>
            </div>
          </div>

          <div className="absolute bottom-8 left-20 text-sm text-blue-300/60 font-medium">
            © 2025 BizFlow Project.
          </div>
        </div>

        {/* 2. PHẦN FORM ĐĂNG NHẬP */}
        <div className="w-full lg:w-[40%] flex items-center justify-center p-8 bg-white relative">
          {/* Trang trí nền mờ bên phải để form bớt đơn điệu */}
          <div className="absolute top-[-10%] right-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

          <div className="w-full max-w-[450px] relative z-20">

            {/* TIÊU ĐỀ MỚI: ĐĂNG NHẬP */}
            <div className="text-center mb-10">
              <h2 className="text-4xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-blue-700 to-indigo-600 pb-1">
                Đăng nhập
              </h2>
              <p className="text-slate-500 mt-3 text-base">
                Chào mừng bạn quay trở lại với BizFlow!
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">

              {error && (
                  <div className="p-4 bg-red-50 border border-red-100 text-red-600 rounded-xl text-sm flex items-start gap-3 animate-in fade-in slide-in-from-top-2 shadow-sm">
                    <span className="text-lg">⚠️</span>
                    <span>{error}</span>
                  </div>
              )}

              <div className="space-y-2">
                <label className="text-sm font-semibold text-slate-700 ml-1">Tên đăng nhập / Email</label>
                <div className="relative group">
                  <Mail className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                  <Input
                      name="username"
                      placeholder="admin@bizflow.com"
                      className="pl-12 h-12 rounded-xl border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all text-base shadow-sm"
                      value={formData.username}
                      onChange={handleChange}
                      required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between items-center ml-1">
                  <label className="text-sm font-semibold text-slate-700">Mật khẩu</label>
                  <Link href="/auth/forgot-password" className="text-sm text-blue-600 font-bold hover:text-blue-700 hover:underline transition-all">
                    Quên mật khẩu?
                  </Link>
                </div>
                <div className="relative group">
                  <Lock className="absolute left-4 top-3.5 w-5 h-5 text-slate-400 group-focus-within:text-blue-600 transition-colors" />
                  <Input
                      name="password"
                      type={showPassword ? "text" : "password"}
                      placeholder="Nhập mật khẩu"
                      value={formData.password}
                      onChange={handleChange}
                      required
                      className="pl-12 pr-12 h-12 rounded-xl border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all text-base shadow-sm"
                  />
                  <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-4 top-3.5 text-slate-400 hover:text-slate-600 transition-colors p-1 rounded-md hover:bg-slate-100"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              <div className="flex items-center space-x-3 py-1 ml-1">
                <Checkbox id="remember" className="w-5 h-5 border-slate-300 data-[state=checked]:bg-blue-600 data-[state=checked]:border-blue-600 rounded shadow-sm" />
                <label htmlFor="remember" className="text-sm font-medium text-slate-600 cursor-pointer select-none">
                  Ghi nhớ đăng nhập
                </label>
              </div>

              <Button
                  type="submit"
                  disabled={isLoading}
                  className="w-full h-12 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-bold text-base rounded-xl shadow-lg shadow-blue-600/30 hover:shadow-blue-600/50 transition-all duration-300 transform hover:-translate-y-0.5"
              >
                {isLoading ? "Đang xử lý..." : "Đăng nhập ngay"}
                {!isLoading && <ArrowRight className="ml-2 w-5 h-5" />}
              </Button>
            </form>

            <div className="mt-10 text-center">
              <p className="text-slate-500 text-sm">
                Bạn chưa có tài khoản?{" "}
                <Link href="/auth/register" className="text-blue-700 font-bold hover:underline transition-all">
                  Đăng ký
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>
  );
}