"use client";

import { useState } from "react";
import { 
  User, Mail, Save, Camera, 
  Phone, AtSign, BadgeCheck, Loader2, Lock, 
  Shield, ShieldCheck
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import axiosClient from "@/lib/axios-client";

export default function SettingsPage() {
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  
  // State quản lý thông tin profile
  const [profile, setProfile] = useState({
    fullName: "Nguyễn Quốc Bảo",
    username: "QuocBao",
    email: "quocbao@gmail.com",
    phone: "0942252521",
    role: "EMPLOYEE",
    avatarUrl: "https://github.com/shadcn.png",
  });

  // State quản lý form đổi mật khẩu
  const [passwordForm, setPasswordForm] = useState({
    oldPassword: "",
    newPassword: "",
    confirmPassword: ""
  });

  // Xử lý đổi mật khẩu
  const handleChangePassword = async () => {
    if (!passwordForm.oldPassword || !passwordForm.newPassword) {
      alert("Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới.");
      return;
    }

    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      alert("Mật khẩu xác nhận không trùng khớp.");
      return;
    }

    if (passwordForm.newPassword.length < 6) {
      alert("Mật khẩu mới phải có ít nhất 6 ký tự.");
      return;
    }

    setIsChangingPassword(true);
    try {
      await axiosClient.patch("/v1/auth/change-password", {
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
      });

      alert("Cập nhật mật khẩu thành công!");
      setPasswordForm({ oldPassword: "", newPassword: "", confirmPassword: "" });
    } catch (error: any) {
      const message = error.response?.data?.message || "Đã xảy ra lỗi, vui lòng thử lại.";
      alert(message);
    } finally {
      setIsChangingPassword(false);
    }
  };

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto space-y-8 animate-in fade-in duration-500">
      {/* HEADER */}
      <div className="space-y-1">
        <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Cài đặt hệ thống</h1>
        <p className="text-slate-500 font-medium">Quản lý thông tin cá nhân và bảo mật tài khoản</p>
      </div>

      <Tabs defaultValue="user" className="space-y-6">
        <TabsList className="bg-slate-100/50 p-1.5 border border-slate-200 h-auto rounded-2xl flex-wrap justify-start inline-flex">
          <TabsTrigger value="user" className="flex items-center gap-2 px-6 py-2.5 rounded-xl data-[state=active]:bg-white data-[state=active]:shadow-sm">
            <User size={18} /> <span className="font-semibold">Người dùng</span>
          </TabsTrigger>
          <TabsTrigger value="security" className="flex items-center gap-2 px-6 py-2.5 rounded-xl data-[state=active]:bg-white data-[state=active]:shadow-sm">
            <Shield size={18} /> <span className="font-semibold">Bảo mật</span>
          </TabsTrigger>
        </TabsList>

        {/* --- TAB NGƯỜI DÙNG --- */}
        <TabsContent value="user" className="m-0">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Card className="lg:col-span-1 border-none shadow-sm ring-1 ring-slate-200">
              <CardContent className="pt-12 pb-12 flex flex-col items-center">
                <div className="relative group cursor-pointer">
                  <Avatar className="h-32 w-32 border-4 border-white shadow-xl">
                    <AvatarImage src={profile.avatarUrl} className="object-cover" />
                    <AvatarFallback className="text-3xl bg-blue-600 text-white font-bold">NB</AvatarFallback>
                  </Avatar>
                  <div className="absolute bottom-1 right-1 p-2 bg-blue-600 rounded-full text-white border-2 border-white shadow-lg">
                    <Camera size={16} />
                  </div>
                </div>
                <div className="mt-6 text-center">
                  <h3 className="text-2xl font-bold text-slate-900">{profile.fullName}</h3>
                  <div className="inline-flex items-center gap-1.5 mt-2 px-3 py-1 bg-blue-50 text-blue-600 rounded-lg text-[11px] font-black uppercase tracking-widest border border-blue-100">
                    {profile.role} <BadgeCheck size={14} />
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="lg:col-span-2 border-none shadow-sm ring-1 ring-slate-200">
              <CardHeader className="border-b border-slate-50">
                <CardTitle className="text-xl">Thông tin chi tiết</CardTitle>
                <CardDescription>Cập nhật tên hiển thị và địa chỉ liên lạc của bạn.</CardDescription>
              </CardHeader>
              <CardContent className="pt-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                      <User size={15} className="text-blue-500" /> Họ và tên *
                    </label>
                    <Input defaultValue={profile.fullName} className="h-12 rounded-xl" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                      <Mail size={15} className="text-blue-500" /> Email
                    </label>
                    <Input value={profile.email} readOnly className="h-12 rounded-xl bg-slate-50 text-slate-400" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                      <AtSign size={15} className="text-blue-500" /> Tên đăng nhập
                    </label>
                    <Input value={profile.username} readOnly className="h-12 rounded-xl bg-slate-50 text-slate-400" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                      <Phone size={15} className="text-blue-500" /> Số điện thoại *
                    </label>
                    <Input defaultValue={profile.phone} className="h-12 rounded-xl" />
                  </div>
                </div>
                <div className="flex justify-end pt-8 border-t border-slate-50 mt-8">
                  <Button className="bg-blue-600 hover:bg-blue-700 text-white px-8 h-12 rounded-2xl font-bold transition-all active:scale-95">
                    <Save className="mr-2 h-5 w-5" /> Lưu thay đổi
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* --- TAB BẢO MẬT --- */}
        <TabsContent value="security" className="m-0">
          <div className="max-w-2xl mx-auto">
            <Card className="border-none shadow-sm ring-1 ring-slate-200">
              <CardHeader>
                <div className="flex items-center gap-2">
                  <Lock size={18} className="text-blue-600" />
                  <CardTitle className="text-lg">Đổi mật khẩu</CardTitle>
                </div>
                <CardDescription>Cập nhật mật khẩu định kỳ để bảo vệ tài khoản</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <label className="text-sm font-semibold">Mật khẩu hiện tại</label>
                  <Input 
                    type="password" 
                    placeholder="••••••••" 
                    className="h-11 rounded-xl"
                    value={passwordForm.oldPassword}
                    onChange={(e) => setPasswordForm({...passwordForm, oldPassword: e.target.value})}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold">Mật khẩu mới</label>
                  <Input 
                    type="password" 
                    placeholder="••••••••" 
                    className="h-11 rounded-xl"
                    value={passwordForm.newPassword}
                    onChange={(e) => setPasswordForm({...passwordForm, newPassword: e.target.value})}
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold">Xác nhận mật khẩu mới</label>
                  <Input 
                    type="password" 
                    placeholder="••••••••" 
                    className="h-11 rounded-xl"
                    value={passwordForm.confirmPassword}
                    onChange={(e) => setPasswordForm({...passwordForm, confirmPassword: e.target.value})}
                  />
                </div>
                <Button 
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white h-12 rounded-xl font-bold mt-2"
                  onClick={handleChangePassword}
                  disabled={isChangingPassword}
                >
                  {isChangingPassword ? (
                    <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  ) : (
                    <Shield size={18} className="mr-2" />
                  )}
                  {isChangingPassword ? "Đang xử lý..." : "Cập nhật mật khẩu"}
                </Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}