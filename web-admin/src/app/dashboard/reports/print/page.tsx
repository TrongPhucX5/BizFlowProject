"use client";

import React, { useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { ReceiptVoucher } from "@/components/vouchers/ReceiptVoucher";
import { PaymentVoucher } from "@/components/vouchers/PaymentVoucher";

function PrintContent() {
    const searchParams = useSearchParams();
    const type = searchParams.get("type"); // 'receipt' or 'payment'

    // Map search params to data object
    const data = {
        date: searchParams.get("date") ? new Date(searchParams.get("date")!) : new Date(),
        bookNo: searchParams.get("bookNo") || "",
        voucherNo: searchParams.get("voucherNo") || "",
        personName: searchParams.get("personName") || "",
        address: searchParams.get("address") || "",
        reason: searchParams.get("reason") || "",
        amount: searchParams.get("amount") ? Number(searchParams.get("amount")) : undefined,
        amountInWords: searchParams.get("amountInWords") || "",
        attachedDocs: searchParams.get("attachedDocs") || "",
        receiverName: searchParams.get("receiverName") || "",
        payerName: searchParams.get("payerName") || "",
        // payerName is for receipt (người nộp)
        // receiverName is for payment (người nhận)
        // But for receipt, receiver is usually the company (unsigned?) or cashier.
        // Let's just pass what we have.
        directorName: searchParams.get("directorName") || "",
        preparerName: searchParams.get("preparerName") || "",
        cashierName: searchParams.get("cashierName") || "",
    };

    useEffect(() => {
        // Auto print when loaded
        if (type) {
            setTimeout(() => {
                window.print();
            }, 500);
        }
    }, [type]);

    if (!type) {
        return <div>Missing voucher type. Please close this window.</div>;
    }

    return (
        <div className="min-h-screen bg-white">
            {type === "receipt" && <ReceiptVoucher data={data} />}
            {type === "payment" && <PaymentVoucher data={data} />}
        </div>
    );
}

export default function PrintPage() {
    return (
        <Suspense fallback={<div>Loading...</div>}>
            <PrintContent />
        </Suspense>
    );
}
