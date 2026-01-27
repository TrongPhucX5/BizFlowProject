"use client";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { formatVND } from "@/lib/utils";

interface RecentTenantsProps {
  data?: {
    name: string;
    email: string;
    amount: number;
    initials: string;
    status: string;
  }[];
}

export function RecentTenants({ data = [] }: RecentTenantsProps) {
  if (data.length === 0) {
    return (
      <div className="h-[350px] flex flex-col items-center justify-center text-slate-400">
        <p className="text-sm">Chưa có tenant mới</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {data.map((tenant) => (
        <div key={tenant.email} className="flex items-center group cursor-pointer hover:bg-slate-50 p-2 rounded-lg transition-colors">
          <Avatar className="h-10 w-10 border border-slate-200">
            <AvatarImage src={`https://api.dicebear.com/7.x/initials/svg?seed=${tenant.initials}&backgroundColor=3b82f6`} alt="Avatar" />
            <AvatarFallback>{tenant.initials}</AvatarFallback>
          </Avatar>
          <div className="ml-4 flex-1 space-y-0.5">
            <p className="text-sm font-semibold text-slate-900">{tenant.name}</p>
            <div className="flex items-center gap-2">
              <p className="text-xs text-slate-500">{tenant.email}</p>
              <span className={`text-[10px] px-1.5 py-0.5 rounded-full font-medium ${
                tenant.status === 'Active' ? 'bg-green-100 text-green-700' :
                tenant.status === 'Trial' ? 'bg-blue-100 text-blue-700' :
                'bg-red-100 text-red-700'
              }`}>
                {tenant.status}
              </span>
            </div>
          </div>
          <div className="text-sm font-bold text-slate-900">+{formatVND(tenant.amount)}</div>
        </div>
      ))}
    </div>
  );
}
