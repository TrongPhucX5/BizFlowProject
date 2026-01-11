import axiosClient from "@/lib/axios-client";

export const getUsers = async () => {
  const response = await axiosClient.get("/users");
  return response.data;
};

export const userService = {
  getUsers,
};
