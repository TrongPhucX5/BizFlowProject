"use client";

import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";
import { formatVND } from "@/lib/utils";

interface OverviewChartProps {
  data?: { name: string; total: number }[];
}

export function OverviewChart({ data = [] }: OverviewChartProps) {
  if (data.length === 0) {
    return (
      <div className="h-[350px] flex flex-col items-center justify-center bg-slate-50/50 rounded-lg border border-dashed border-slate-200">
        <p className="text-sm text-slate-400">Không có dữ liệu doanh thu</p>
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={350}>
      <BarChart data={data} margin={{ top: 20, right: 30, left: 20, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
        <XAxis
          dataKey="name"
          stroke="#64748b"
          fontSize={12}
          tickLine={false}
          axisLine={false}
          tick={{ dy: 10 }}
        />
        <YAxis
          stroke="#64748b"
          fontSize={12}
          tickLine={false}
          axisLine={false}
          tickFormatter={(value) => `${(value / 1000000).toFixed(0)}tr`}
        />
        <Tooltip
          cursor={{ fill: '#f1f5f9' }}
          content={({ active, payload, label }) => {
            if (active && payload && payload.length) {
              return (
                <div className="rounded-lg border bg-white p-3 shadow-lg ring-1 ring-black/5">
                  <p className="text-sm font-semibold text-slate-900 mb-1">{label}</p>
                  <div className="flex items-center gap-2">
                    <div className="h-3 w-3 rounded-full bg-blue-600" />
                    <span className="text-sm text-slate-600">
                      Doanh thu: <span className="font-bold text-slate-900">{formatVND(payload[0].value as number)}</span>
                    </span>
                  </div>
                </div>
              );
            }
            return null;
          }}
        />
        <Bar
          dataKey="total"
          fill="#2563eb"
          radius={[6, 6, 0, 0]}
          barSize={40}
        />
      </BarChart>
    </ResponsiveContainer>
  );
}
