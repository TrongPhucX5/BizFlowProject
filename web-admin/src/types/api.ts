export interface Product {
  id: number;
  sku: string;
  name: string;
  unitId?: number;
  unitName?: string; // <--- Thêm dòng này
  costPrice?: number;
  price: number;
  description?: string;
  status?: "ACTIVE" | "INACTIVE" | "DISCONTINUED"; // Hoặc string
  imageUrl?: string;
  categoryId?: number;
  stock?: number; // <--- Thêm dòng này
  reorderLevel?: number; // <--- Thêm dòng này
  storeId?: number;
}

// Khớp với ApiResponse bên Java
export interface ApiResponse<T> {
  code: number;
  message: string;
  result: T;
  timestamp: string;
}

// Khớp với Page<ProductDTO> bên Java
export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}
