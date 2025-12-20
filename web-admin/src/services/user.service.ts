// user.service.ts
import axios from "axios";

export const getUsers = async () => {
  // 1. Lấy token ra (giả sử lúc đăng nhập bạn lưu tên là 'accessToken')
  const token = localStorage.getItem("accessToken");

  // 2. Cấu hình Header
  const config = {
    headers: {
      Authorization: `Bearer ${token}`, // Quan trọng nhất là dòng này
      "Content-Type": "application/json",
    },
  };

  // 3. Gọi API có đính kèm 'vé' (config)
  return await axios.get("http://localhost:8080/api/v1/users", config);
};
