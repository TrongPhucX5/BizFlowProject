import os
import json
import google.generativeai as genai
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from typing import List

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=api_key)

# LƯU Ý: Nếu chạy lỗi model, hãy đổi '2.5' thành '1.5' hoặc '2.0-flash-exp'
model = genai.GenerativeModel('models/gemini-2.5-flash')
app = FastAPI()

class ChatMessage(BaseModel):
    role: str
    content: str

class AIRequest(BaseModel):
    message: str
    history: List[ChatMessage] = []
    products: List[str] = []

@app.post("/analyze-order")
async def analyze_order(req: AIRequest):
    print(f"\n📩 User: {req.message}")
    
    try:
        product_menu = "\n".join(req.products) if req.products else "(Chưa cập nhật)"
        history_text = ""
        for msg in req.history:
            role = "USER" if msg.role == "user" else "AI"
            history_text += f"{role}: {msg.content}\n"

        # --- PROMPT LEVEL 4: BÁO CÁO & PHÂN TÍCH ---
        prompt = f"""
        Bạn là Trợ lý Quản lý BizFlow.
        
        MENU:
        {product_menu}
        
        LỊCH SỬ:
        {history_text}
        USER: {req.message}
        
        NHIỆM VỤ:
        Phân tích ý định người dùng và trả về JSON (Không Markdown).
        
        1. MUA HÀNG (Tạo đơn):
           {{ "is_order": true, "is_report": false, "reply": "Ok lên đơn...", "data": {{ "customerName": "...", "items": [...] }} }}
        
        2. BÁO CÁO DOANH THU (Hỏi tiền, doanh số, bán được bao nhiêu...):
           {{ 
             "is_order": false, 
             "is_report": true, 
             "reply": "Dưới đây là tình hình kinh doanh:",
             "data": {{ 
                "reportType": "REVENUE", 
                "timeRange": "TODAY" (hoặc "MONTH", "ALL" tùy câu hỏi)
             }} 
           }}

        3. BÁO CÁO SẢN PHẨM (Hỏi cái gì bán chạy, top sản phẩm...):
           {{ 
             "is_order": false, 
             "is_report": true, 
             "reply": "Các sản phẩm bán tốt nhất:",
             "data": {{ 
                "reportType": "TOP_PRODUCT", 
                "timeRange": "TODAY" (hoặc "MONTH", "ALL")
             }} 
           }}

        4. CHAT THƯỜNG:
           {{ "is_order": false, "is_report": false, "reply": "...", "data": null }}
        """

        response = model.generate_content(prompt)
        clean_text = response.text.replace("```json", "").replace("```", "").strip()
        
        try:
            return json.loads(clean_text)
        except:
            return { "is_order": False, "is_report": False, "reply": clean_text, "data": None }

    except Exception as e:
        print(f"❌ Lỗi: {e}")
        return { "is_order": False, "reply": "Lỗi AI Service.", "data": None }