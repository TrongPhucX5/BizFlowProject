import axiosClient from "@/lib/axios-client";

export const userService = {
  getUsers: async () => {
    const response = await axiosClient.get("/users");
    return response.data; // Trả về {code, message, result}
  },
};
