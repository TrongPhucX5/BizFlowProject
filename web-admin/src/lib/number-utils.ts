export function numberToVietnameseText(amount: number): string {
    if (amount === 0) return "Không đồng";

    const units = ["", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"];
    const tens = ["", "mười", "hai mươi", "ba mươi", "bốn mươi", "năm mươi", "sáu mươi", "bảy mươi", "tám mươi", "chín mươi"];
    const scales = ["", "nghìn", "triệu", "tỷ", "nghìn tỷ"];

    // Simple implementation for demo purposes (can be replaced with a library like 'n-vi')
    // This is a simplified version for common amounts in orders.
    // For production, use a dedicated library.

    if (amount > 1000000000000) return "Số tiền quá lớn";

    // Using a simplified heuristic for demo or suggest using 'n-vi' package if installed
    // For now, I'll return a placeholder logic or if small number

    // Actually, let's just return a placeholder that says "Please implement number reading lib" or basic logic
    // But user wants "numberToVietnameseWords". 

    // Let's implement a basic reader for up to billions.

    const readGroup = (n: number) => {
        // 000 - 999
        if (n === 0) return "";
        let s = "";

        const u = n % 10;
        const t = Math.floor((n / 10) % 10);
        const h = Math.floor(n / 100);

        if (h > 0) {
            s += units[h] + " trăm ";
        } else if (n > 0 && n < 100) {
            // Handle case like 1005 (mot nghin khong tram linh nam) not fully in simple group logic
        }

        // Simple basic reader
        return "Demo: " + amount + " đồng";
    };

    // FOR THE SAKE OF SPEED AND ACCURACY WITHOUT EXTERNAL LIBS, 
    // I will use a minimal functional snippet for reading numbers if possible, 
    // OR standard approach: just rely on User Input but Auto-generate a hint.

    // However, I will write a simple robust one here properly.

    const str = amount.toString();
    // Falling back to a simpler "format number" for now if library not available?
    // No, let's make it work.

    return readNumber(amount);
}

const defaultNumbers = ' hai ba bốn năm sáu bảy tám chín';
const chuHangDonVi = ('1 một' + defaultNumbers).split(' ');
const chuHangChuc = ('lẻ mười' + defaultNumbers).split(' ');
const chuHangTram = ('không một' + defaultNumbers).split(' ');

function convert_block_three(number: number) {
    if (number == 0) return '';
    let tram = Math.floor(number / 100);
    let chuc = Math.floor((number % 100) / 10);
    let donvi = number % 10;
    let ketqua = '';

    if (tram > 0 || (tram == 0 && number > 1000)) { // Simple cheat for context
        ketqua += chuHangTram[tram] + ' trăm';
        if (chuc == 0 && donvi != 0) ketqua += ' linh';
    }

    // Fix logic properly
    // Since this is complex to write from scratch without errors in one go, 
    // I will recommend the user to use a library or simply assume a mock function.
    // BUT the user expects me to fix it.

    // I will provide a clean "utils/number-to-text" file.
    return "";
}

// RE-WRITING properly
const docSo = (so: number) => {
    const mangSo = ['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
    const hang = ['ty', 'triệu', 'nghìn', 'đồng'];
    // ... Implementation might be too long for this snippet.

    // Alternative: Just return the number for now and note it.
    return so.toLocaleString() + " đồng (Tự điền)";
}

// REAL IMPLEMENTATION
const DocSo3ChuSo = (baso: number) => {
    const ChuSo = [" không ", " một ", " hai ", " ba ", " bốn ", " năm ", " sáu ", " bảy ", " tám ", " chín "];
    let tram, chuc, donvi;
    let KetQua = "";
    tram = Math.floor(baso / 100);
    chuc = Math.floor((baso % 100) / 10);
    donvi = baso % 10;
    if (tram == 0 && chuc == 0 && donvi == 0) return "";
    if (tram != 0) {
        KetQua += ChuSo[tram] + " trăm ";
        if ((chuc == 0) && (donvi != 0)) KetQua += " linh ";
    }
    if ((chuc != 0) && (chuc != 1)) {
        KetQua += ChuSo[chuc] + " mươi";
        if ((chuc == 0) && (donvi != 0)) KetQua = KetQua + " linh ";
    }
    if (chuc == 1) KetQua += " mười ";
    switch (donvi) {
        case 1:
            if ((chuc != 0) && (chuc != 1)) {
                KetQua += " mốt ";
            }
            else {
                KetQua += ChuSo[donvi];
            }
            break;
        case 5:
            if (chuc == 0) {
                KetQua += ChuSo[donvi];
            }
            else {
                KetQua += " lăm ";
            }
            break;
        default:
            if (donvi != 0) {
                KetQua += ChuSo[donvi];
            }
            break;
    }
    return KetQua;
}

export const readNumber = (SoTien: number) => {
    const Tien = ["", " nghìn", " triệu", " tỷ", " nghìn tỷ", " triệu tỷ"];
    let lan = 0;
    let i = 0;
    let so = 0;
    let KetQua = "";
    let tmp = "";
    let ViTri = new Array();
    if (SoTien < 0) return "Số tiền âm !";
    if (SoTien == 0) return "Không đồng !";
    if (SoTien > 0) {
        so = SoTien;
    }
    else {
        so = -SoTien;
    }
    if (SoTien > 8999999999999999) {
        //SoTien = 0;
        return "Số quá lớn!";
    }
    ViTri[5] = Math.floor(so / 1000000000000000);
    if (isNaN(ViTri[5]))
        ViTri[5] = 0;
    so = so - parseFloat(ViTri[5].toString()) * 1000000000000000;
    ViTri[4] = Math.floor(so / 1000000000000);
    if (isNaN(ViTri[4]))
        ViTri[4] = 0;
    so = so - parseFloat(ViTri[4].toString()) * 1000000000000;
    ViTri[3] = Math.floor(so / 1000000000);
    if (isNaN(ViTri[3]))
        ViTri[3] = 0;
    so = so - parseFloat(ViTri[3].toString()) * 1000000000;
    ViTri[2] = Math.floor(so / 1000000);
    if (isNaN(ViTri[2]))
        ViTri[2] = 0;
    so = so - parseFloat(ViTri[2].toString()) * 1000000;
    ViTri[1] = Math.floor(so / 1000);
    if (isNaN(ViTri[1]))
        ViTri[1] = 0;
    so = so - parseFloat(ViTri[1].toString()) * 1000;
    ViTri[0] = Math.floor(so);
    if (isNaN(ViTri[0]))
        ViTri[0] = 0;
    if (ViTri[5] > 0) {
        lan = 5;
    }
    else if (ViTri[4] > 0) {
        lan = 4;
    }
    else if (ViTri[3] > 0) {
        lan = 3;
    }
    else if (ViTri[2] > 0) {
        lan = 2;
    }
    else if (ViTri[1] > 0) {
        lan = 1;
    }
    else {
        lan = 0;
    }
    for (i = lan; i >= 0; i--) {
        tmp = DocSo3ChuSo(ViTri[i]);
        KetQua += tmp;
        if (ViTri[i] > 0) KetQua += Tien[i];
        if ((i > 0) && (tmp.length > 0)) KetQua += ',';
    }
    if (KetQua.substring(KetQua.length - 1) == ',') {
        KetQua = KetQua.substring(0, KetQua.length - 1);
    }
    KetQua = KetQua.substring(1, 2).toUpperCase() + KetQua.substring(2);
    // Remove extra spaces
    KetQua = KetQua.replace(/\s+/g, ' ').trim();
    if (KetQua.endsWith(",")) KetQua = KetQua.slice(0, -1);

    return KetQua + " đồng";
}
