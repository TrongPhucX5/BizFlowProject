import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load key
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("❌ LỖI: Không tìm thấy Key trong file .env")
else:
    print(f"✅ Đã tìm thấy Key: {api_key[:5]}... (ẩn bớt)")
    genai.configure(api_key=api_key)

    print("\n🔍 Đang hỏi Google danh sách Model...")
    try:
        # Lấy danh sách model
        models = genai.list_models()
        found = False
        for m in models:
            # Chỉ lấy những model hỗ trợ tạo văn bản (generateContent)
            if 'generateContent' in m.supported_generation_methods:
                print(f"👉 {m.name}")
                found = True
        
        if not found:
            print("⚠️ Không tìm thấy model nào hỗ trợ generateContent.")
            
    except Exception as e:
        print(f"❌ Có lỗi xảy ra: {e}")