import os
import json
import re
from datetime import datetime
import google.generativeai as genai
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from typing import List

# ==============================================================================
# 1. CẤU HÌNH & KHỞI TẠO
# ==============================================================================

# Load biến môi trường từ file .env
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("❌ LỖI NGHIÊM TRỌNG: Không tìm thấy GEMINI_API_KEY trong file .env")
    print("👉 Hãy tạo file .env và thêm dòng: GEMINI_API_KEY=AIzaSy...")
else:
    genai.configure(api_key=api_key)
    print(f"✅ Đã tải API Key thành công (Đuôi: ...{api_key[-5:]})")

# Chọn Model: Dùng 'gemini-1.5-flash' là chuẩn nhất, nhanh và Free.
# Nếu muốn thử bản mới hơn (nhưng có thể chưa ổn định), đổi thành 'gemini-2.0-flash-exp'
model = genai.GenerativeModel('gemini-2.5-flash')

app = FastAPI()

# ==============================================================================
# 2. ĐỊNH NGHĨA MODEL DỮ LIỆU (Data Transfer Object)
# ==============================================================================
class ChatMessage(BaseModel):
    role: str
    content: str

class AIRequest(BaseModel):
    message: str
    history: List[ChatMessage] = []
    products: List[str] = []

# ==============================================================================
# 3. CÁC HÀM TIỆN ÍCH (HELPER FUNCTIONS)
# ==============================================================================
def get_current_time_vn():
    """Lấy thời gian hiện tại chuẩn Việt Nam"""
    now = datetime.now()
    days_vn = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"]
    weekday = days_vn[now.weekday()]
    return f"{weekday}, ngày {now.strftime('%d/%m/%Y')} (Giờ hiện tại: {now.strftime('%H:%M:%S')})"

def clean_json_string(text: str):
    """Làm sạch chuỗi JSON nếu AI trả về kèm Markdown"""
    text = text.strip()
    # Loại bỏ ```json và ``` nếu có
    if text.startswith("```json"):
        text = text[7:]
    if text.startswith("```"):
        text = text[3:]
    if text.endswith("```"):
        text = text[:-3]
    return text.strip()

# ==============================================================================
# 4. API ENDPOINT CHÍNH
# ==============================================================================
@app.post("/analyze-order")
async def analyze_order(req: AIRequest):
    print(f"\n📩 [JAVA GỬI SANG]: {req.message}")
    
    try:
        # 1. Chuẩn bị dữ liệu context
        current_time = get_current_time_vn()
        product_menu = "\n".join(req.products) if req.products else "(Danh sách sản phẩm trống - Hãy báo khách đợi cập nhật)"
        
        # Xử lý lịch sử chat (Chỉ lấy 5 tin gần nhất để tiết kiệm token và nhanh hơn)
        recent_history = req.history[-10:] if len(req.history) > 10 else req.history
        history_text = ""
        for msg in recent_history:
            role = "KHÁCH" if msg.role == "user" else "AI"
            history_text += f"{role}: {msg.content}\n"

        # 2. Xây dựng Prompt (Kịch bản cho AI)
        prompt = f"""
        Bạn là Trợ lý Ảo chuyên nghiệp của hệ thống quản lý vật liệu xây dựng BizFlow.
        
        🔰 THÔNG TIN QUAN TRỌNG (HÃY ĐỌC KỸ):
        - Thời gian thực tế: {current_time}
        - Nhiệm vụ: Hỗ trợ bán hàng, kiểm tra kho, xem báo cáo.
        
        📦 DANH SÁCH SẢN PHẨM TRONG KHO:
        {product_menu}
        -----------------------------------
        
        💬 LỊCH SỬ TRÒ CHUYỆN:
        {history_text}
        
        👤 KHÁCH HÀNG VỪA NÓI: "{req.message}"
        
        🛑 YÊU CẦU ĐẦU RA (JSON FORMAT ONLY):
        Tuyệt đối chỉ trả về JSON thuần, không giải thích thêm.
        
        1. TRƯỜNG HỢP MUA HÀNG (Tạo đơn):
           - Phải khớp tên sản phẩm khách nói với danh sách kho ở trên.
           - Nếu khách nói "xi măng" chung chung, hãy chọn loại phổ biến nhất hoặc hỏi lại.
           Example: {{ "is_order": true, "is_report": false, "reply": "Dạ, em đã lên đơn...", "data": {{ "customerName": "Tên Khách (hoặc Khách lẻ)", "items": [{{ "productName": "Xi măng Hà Tiên", "quantity": 10 }}] }} }}

        2. TRƯỜNG HỢP XEM BÁO CÁO (Doanh thu, Top sản phẩm):
           Example: {{ "is_order": false, "is_report": true, "reply": "Dạ, đây là tình hình kinh doanh...", "data": {{ "reportType": "REVENUE" (hoặc "TOP_PRODUCT"), "timeRange": "TODAY" (hoặc "MONTH") }} }}

        3. TRƯỜNG HỢP CHAT THƯỜNG (Hỏi giờ, chào hỏi, tư vấn):
           Example: {{ "is_order": false, "is_report": false, "reply": "Câu trả lời của bạn (ngắn gọn, thân thiện)...", "data": null }}
        """

        # 3. Gọi Google Gemini
        response = model.generate_content(prompt)
        raw_text = response.text
        
        # 4. Xử lý kết quả trả về
        clean_text = clean_json_string(raw_text)
        print(f"🤖 [AI TRẢ LỜI]: {clean_text}") 

        return json.loads(clean_text)

    except json.JSONDecodeError:
        print("❌ LỖI JSON: AI trả về định dạng sai.")
        return {
            "is_order": False,
            "is_report": False,
            "reply": "Xin lỗi, tôi gặp chút trục trặc khi xử lý dữ liệu. Bạn nói lại được không?",
            "data": None
        }
    except Exception as e:
        print(f"❌ LỖI SERVER: {str(e)}")
        return {
            "is_order": False,
            "is_report": False,
            "reply": "Hệ thống đang bảo trì giây lát.",
            "data": None
        }

# Lệnh chạy server (lưu ý cho người dùng):
# uvicorn main:app --reload --port 8000