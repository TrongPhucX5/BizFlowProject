"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import axiosClient from "@/lib/axios-client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Checkbox } from "@/components/ui/checkbox";
import { Lock, Mail, ArrowRight, Store, CheckCircle2, Eye, EyeOff, Building2 } from "lucide-react";

// Icon Google chuẩn màu (SVG)
const GoogleIcon = () => (
    <svg viewBox="0 0 24 24" width="24" height="24" xmlns="http://www.w3.org/2000/svg">
      <g transform="matrix(1, 0, 0, 1, 27.009001, -39.23856)">
        <path fill="#4285F4" d="M -3.264 51.509 C -3.264 50.719 -3.334 49.969 -3.454 49.239 L -14.754 49.239 L -14.754 53.749 L -8.284 53.749 C -8.574 55.229 -9.424 56.479 -10.684 57.329 L -10.684 60.329 L -6.824 60.329 C -4.564 58.239 -3.264 55.159 -3.264 51.509 Z" />
        <path fill="#34A853" d="M -14.754 63.239 C -11.514 63.239 -8.804 62.159 -6.824 60.329 L -10.684 57.329 C -11.764 58.049 -13.134 58.489 -14.754 58.489 C -17.884 58.489 -20.534 56.379 -21.484 53.529 L -25.464 53.529 L -25.464 56.619 C -23.494 60.539 -19.444 63.239 -14.754 63.239 Z" />
        <path fill="#FBBC05" d="M -21.484 53.529 C -21.734 52.809 -21.864 52.039 -21.864 51.239 C -21.864 50.439 -21.734 49.669 -21.484 48.949 L -21.484 45.859 L -25.464 45.859 C -26.284 47.479 -26.754 49.299 -26.754 51.239 C -26.754 53.179 -26.284 54.999 -25.464 56.619 L -21.484 53.529 Z" />
        <path fill="#EA4335" d="M -14.754 43.989 C -12.984 43.989 -11.404 44.599 -10.154 45.789 L -6.734 42.369 C -8.804 40.429 -11.514 39.239 -14.754 39.239 C -19.444 39.239 -23.494 41.939 -25.464 45.859 L -21.484 48.949 C -20.534 46.099 -17.884 43.989 -14.754 43.989 Z" />
      </g>
    </svg>
);

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

  const handleGoogleLogin = () => {
    // Chỗ này sau này sẽ gắn link API login Google vào
    // Ví dụ: window.location.href = "http://localhost:8080/oauth2/authorization/google";
    alert("Tính năng đang phát triển!");
  };

  return (
      <div className="flex min-h-screen w-full bg-white font-sans overflow-hidden">
        {/* 1. PHẦN MÀU XANH (GIỮ NGUYÊN) */}
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

        {/* 2. PHẦN FORM ĐĂNG NHẬP (ĐÃ CẬP NHẬT) */}
        <div className="w-full lg:w-[40%] flex items-center justify-center p-8 bg-white relative">
          <div className="absolute top-[-10%] right-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-3xl opacity-50 pointer-events-none"></div>

          <div className="w-full max-w-[450px] relative z-20">

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
                  <div className="p-4 bg-red-50 border border-red-100 text-red-600 rounded-xl text-sm flex items-start gap-3 shadow-sm">
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

            {/* PHẦN ĐĂNG NHẬP GOOGLE MỚI THÊM */}
            <div className="mt-8">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t border-slate-200" />
                </div>
                <div className="relative flex justify-center text-sm uppercase">
                  <span className="bg-white px-4 text-slate-400 font-medium">Hoặc tiếp tục với</span>
                </div>
              </div>

              <div className="mt-6">
                <Button
                    type="button"
                    onClick={handleGoogleLogin}
                    className="w-full h-12 bg-white text-slate-700 font-semibold border border-slate-200 hover:bg-slate-50 hover:border-slate-300 rounded-xl transition-all shadow-sm flex items-center justify-center gap-3"
                >
                  <GoogleIcon />
                  <span>Đăng nhập bằng Google</span>
                </Button>
              </div>
            </div>

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