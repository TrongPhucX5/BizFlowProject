import React from "react";
import { format } from "date-fns";

export interface VoucherProps {
    data?: {
        date?: Date;
        bookNo?: string;
        voucherNo?: string;
        personName?: string;
        address?: string;
        reason?: string;
        amount?: number;
        amountInWords?: string;
        attachedDocs?: string;
        receiverName?: string; // Người nhận tiền
        payerName?: string;
        preparerName?: string;
        directorName?: string;
        cashierName?: string;
        status?: string;
    };
}

export const ReceiptVoucher: React.FC<VoucherProps> = ({ data }) => {
    const currentDate = data?.date || new Date();
    const day = currentDate.getDate();
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();
    const status = data?.status || "DRAFT";

    return (
        <div
            className="p-10 max-w-[210mm] mx-auto bg-white text-black text-sm leading-relaxed box-border relative"
            style={{ fontFamily: '"Times New Roman", Times, serif' }}
        >
            {/* Watermark for DRAFT/CANCELED */}
            {status !== "CONFIRMED" && (
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none opacity-10 z-0">
                    <h1 className="text-[100px] font-bold uppercase -rotate-45 text-black border-4 border-black p-4 rounded-xl">
                        {status === "CANCELED" ? "ĐÃ HỦY" : "BẢN NHÁP"}
                    </h1>
                </div>
            )}

            {/* Header */}
            <div className="flex justify-between items-start mb-4 relative z-10">
                <div className="w-[60%]">
                    <p className="font-bold text-[13px] uppercase">
                        Hộ, cá nhân kinh doanh: {data?.personName ? "Cửa hàng BizFlow" : "..................................."}
                    </p>
                    <p className="text-[13px]">
                        Địa chỉ: {data?.address ? "TK20/12 Nguyễn Cảnh Chân, P. Cầu Kho, Quận 1, TP.HCM" : "........................................................................................."}
                    </p>
                </div>
                <div className="w-[40%] text-center">
                    <p className="font-bold text-[13px]">Mẫu số 01 - TT</p>
                    <p className="italic text-[11px] mb-1">
                        (Ban hành kèm theo Thông tư số 88/2021/TT-BTC <br />
                        ngày 11 tháng 10 năm 2021 của Bộ trưởng Bộ Tài chính)
                    </p>
                    <div className="text-left ml-8 text-[13px]">
                        <p>
                            Quyển số: <span className="font-bold">{data?.bookNo || "............"}</span>
                        </p>
                        <p>
                            Số: <span className="font-bold">{data?.voucherNo || "............"}</span>
                        </p>
                    </div>
                </div>
            </div>

            {/* Title */}
            <div className="text-center mb-6 relative z-10">
                <h1 className="text-3xl font-bold uppercase mb-1">Phiếu Thu</h1>
                <p className="italic text-[13px]">
                    Ngày {day} tháng {month} năm {year}
                </p>
            </div>

            {/* Content */}
            <div className="space-y-2 mb-6 text-[14px] relative z-10">
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[160px]">Họ và tên người nộp tiền:</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 font-bold uppercase pl-2">
                        {data?.personName}
                    </span>
                </div>
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[50px]">Địa chỉ:</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 pl-2">
                        {data?.address}
                    </span>
                </div>
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[65px]">Lý do nộp:</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 pl-2">
                        {data?.reason}
                    </span>
                </div>
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[50px]">Số tiền:</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 font-bold pl-2">
                        {data?.amount ? data.amount.toLocaleString() : "..................................."}
                    </span>
                    <span className="ml-1 font-bold">VNĐ</span>
                </div>
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[95px]">(Viết bằng chữ):</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 italic pl-2">
                        {data?.amountInWords}
                    </span>
                </div>
                <div className="flex items-end">
                    <span className="whitespace-nowrap min-w-[65px]">Kèm theo:</span>
                    <span className="border-b border-dotted border-black flex-grow ml-1 pl-2">
                        {data?.attachedDocs && Number(data.attachedDocs) > 0 ? `${data.attachedDocs} chứng từ gốc` : ".......................................... Chứng từ gốc"}
                    </span>
                </div>
            </div>

            {/* Signatures */}
            <div className="grid grid-cols-4 gap-2 text-center mt-8 mb-24 text-[13px] relative z-10">
                <div>
                    <p className="font-bold uppercase text-[11px]">Người đại diện<br />hộ kinh doanh</p>
                    <p className="italic text-[11px]">(Ký, họ tên, đóng dấu)</p>
                    <div className="h-20"></div>
                    <p className="font-bold mt-2">{data?.directorName}</p>
                </div>
                <div>
                    <p className="font-bold uppercase text-[11px]">Người lập biểu</p>
                    <p className="italic text-[11px]">(Ký, họ tên)</p>
                    <div className="h-20"></div>
                    <p className="font-bold mt-2">{data?.preparerName}</p>
                </div>
                <div>
                    <p className="font-bold uppercase text-[11px]">Người nộp tiền</p>
                    <p className="italic text-[11px]">(Ký, họ tên)</p>
                    <div className="h-20"></div>
                    <p className="font-bold mt-2">{data?.payerName}</p>
                </div>
                <div>
                    <p className="font-bold uppercase text-[11px]">Thủ quỹ</p>
                    <p className="italic text-[11px]">(Ký, họ tên)</p>
                    <div className="h-20"></div>
                    <p className="font-bold mt-2">{data?.cashierName}</p>
                </div>
            </div>

            {/* Footer */}
            <div className="flex items-end mt-4 text-[13px] relative z-10">
                <span className="whitespace-nowrap">Đã nhận đủ số tiền (viết bằng chữ):</span>
                <span className="border-b border-dotted border-black flex-grow ml-2 italic pl-2">
                    {data?.amountInWords}
                </span>
            </div>

            {/* Audit Info Micro-footer */}
            <div className="fixed bottom-2 right-2 text-[10px] text-gray-400 font-sans">
                Generated by BizFlow – {format(new Date(), "dd/MM/yyyy HH:mm")}
            </div>
        </div>
    );
};
