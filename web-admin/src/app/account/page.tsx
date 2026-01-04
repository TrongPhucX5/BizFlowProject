'use client';

import { useEffect, useState } from 'react';
import { userService, User } from '@/services/user.service';
import styles from '@/styles/account/account.module.css';

export default function AccountPage() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        setLoading(true);
        // Gọi API lấy danh sách người dùng
        const res = await userService.getUsers();
        
        if (res && res.result && Array.isArray(res.result) && res.result.length > 0) {
          // Hiển thị người dùng đầu tiên trong danh sách (thường là Admin)
          setUser(res.result[0]);
          setErrorMsg(null);
        } else {
          setErrorMsg("Không tìm thấy dữ liệu người dùng.");
        }
      } catch (error: any) {
        if (error.response?.status === 403) {
          setErrorMsg("Bạn không có quyền truy cập (403). Vui lòng dùng tài khoản ADMIN.");
        } else {
          setErrorMsg("Lỗi kết nối API. Vui lòng kiểm tra Server.");
        }
      } finally {
        setLoading(false);
      }
    };
    fetchUserData();
  }, []);

  if (loading) return (
    <div className={styles.container}>
      <div className={styles.loadingState}>Đang đồng bộ dữ liệu hệ thống...</div>
    </div>
  );

  if (errorMsg || !user) return (
    <div className={styles.container}>
      <div className={styles.errorCard}>
        <p>{errorMsg || "Không tìm thấy thông tin tài khoản."}</p>
        <button onClick={() => window.location.reload()}>Thử lại</button>
      </div>
    </div>
  );

  return (
    <div className={styles.container}>
      <div className={styles.accountCard}>
        {/* Header: Avatar & Name */}
        <div className={styles.cardHeader}>
          <div className={styles.avatarCircle}>
            {user.fullName.charAt(0).toUpperCase()}
          </div>
          <div className={styles.headerText}>
            <h1>{user.fullName}</h1>
            <span className={styles.roleBadge}>{user.role}</span>
          </div>
        </div>

        {/* Body: Info Grid */}
        <div className={styles.cardBody}>
          <div className={styles.infoGroup}>
            <span className={styles.label}>Tên đăng nhập</span>
            <div className={styles.value}>{user.username}</div>
          </div>

          <div className={styles.infoGroup}>
            <span className={styles.label}>Email liên hệ</span>
            <div className={styles.value}>{user.email || 'Chưa cập nhật'}</div>
          </div>

          <div className={styles.infoGroup}>
            <span className={styles.label}>Số điện thoại</span>
            <div className={styles.value}>{user.phone || 'Chưa cập nhật'}</div>
          </div>

          <div className={styles.infoGroup}>
            <span className={styles.label}>Trạng thái hệ thống</span>
            <div className={`${styles.value} ${user.status === 'ACTIVE' ? styles.statusActive : ''}`}>
              {user.status === 'ACTIVE' ? '● Đang hoạt động' : user.status}
            </div>
          </div>

          {/* Action Buttons */}
          <div className={styles.actions}>
            <button className={styles.btnEdit}>Chỉnh sửa hồ sơ</button>
            <button className={styles.btnSecurity}>Bảo mật & Mật khẩu</button>
          </div>
        </div>
      </div>
    </div>
  );
}