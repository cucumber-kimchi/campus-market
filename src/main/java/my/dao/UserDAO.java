package my.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.*;

import my.model.UserDTO;
import my.util.DBUtil;

public class UserDAO {

    /** 비밀번호 SHA-256 해시 */
    public static String hash(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** 로그인 성공 시 UserDTO, 실패 시 null */
    public UserDTO login(String userId, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ? AND password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, hash(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                UserDTO u = new UserDTO();
                u.setUserId(rs.getString("user_id"));
                u.setName(rs.getString("name"));
                u.setSchool(rs.getString("school"));
                return u;
            }
        }
    }

    public boolean exists(String userId) throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE user_id = ?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean insert(UserDTO u) throws SQLException {
        String sql = "INSERT INTO users (user_id, password, name, school) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, u.getUserId());
            ps.setString(2, hash(u.getPassword()));
            ps.setString(3, u.getName());
            ps.setString(4, u.getSchool());
            return ps.executeUpdate() == 1;
        }
    }
}
