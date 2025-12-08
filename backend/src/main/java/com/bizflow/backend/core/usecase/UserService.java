package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.User;
import java.util.List;

public interface UserService {
    User createUser(User user);
    List<User> getAllUsers();
}