package my.dao;

import java.sql.*;
import java.util.*;

import my.model.ProductDTO;
import my.util.DBUtil;

public class WishlistDAO {

    /** 로그인 사용자가 찜한 상품 id 집합 */
    public Set<Integer> getWishlistProductIdSet(String userId) throws SQLException {
        Set<Integer> set = new HashSet<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT product_id FROM wishlist WHERE user_id = ?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) set.add(rs.getInt(1));
            }
        }
        return set;
    }

    /**
     * 찜 토글. 추가되면 "added", 삭제되면 "removed"
     * product.wish_count 도 함께 갱신 (트랜잭션)
     */
    public String toggle(String userId, int productId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean exists;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM wishlist WHERE user_id = ? AND product_id = ?")) {
                    ps.setString(1, userId);
                    ps.setInt(2, productId);
                    try (ResultSet rs = ps.executeQuery()) { exists = rs.next(); }
                }

                String result;
                if (exists) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM wishlist WHERE user_id = ? AND product_id = ?")) {
                        ps.setString(1, userId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE product SET wish_count = GREATEST(wish_count - 1, 0) WHERE id = ?")) {
                        ps.setInt(1, productId);
                        ps.executeUpdate();
                    }
                    result = "removed";
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO wishlist (user_id, product_id) VALUES (?, ?)")) {
                        ps.setString(1, userId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE product SET wish_count = wish_count + 1 WHERE id = ?")) {
                        ps.setInt(1, productId);
                        ps.executeUpdate();
                    }
                    result = "added";
                }
                conn.commit();
                return result;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /** 찜 목록 상품 */
    public List<ProductDTO> getWishlistProducts(String userId) throws SQLException {
        List<ProductDTO> list = new ArrayList<>();
        ProductDAO dao = new ProductDAO();
        for (Integer id : getWishlistProductIdSet(userId)) {
            ProductDTO p = dao.getProduct(id);
            if (p != null) list.add(p);
        }
        return list;
    }
}
