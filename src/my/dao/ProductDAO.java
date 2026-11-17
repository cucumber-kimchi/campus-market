package my.dao;

import java.sql.*;
import java.util.*;

import my.model.ProductDTO;
import my.util.DBUtil;

public class ProductDAO {

    private static final String BASE_SELECT =
        "SELECT p.*, u.name AS seller_name FROM product p " +
        "LEFT JOIN users u ON p.seller_id = u.user_id ";

    private ProductDTO mapRow(ResultSet rs) throws SQLException {
        ProductDTO p = new ProductDTO();
        p.setId(rs.getInt("id"));
        p.setSellerId(rs.getString("seller_id"));
        p.setSellerName(rs.getString("seller_name"));
        p.setTitle(rs.getString("title"));
        p.setPrice(rs.getInt("price"));
        p.setCategory(rs.getString("category"));
        p.setItemCondition(rs.getString("item_condition"));
        p.setDescription(rs.getString("description"));
        p.setImage(rs.getString("image"));
        p.setStatus(rs.getString("status"));
        p.setViewCount(rs.getInt("view_count"));
        p.setWishCount(rs.getInt("wish_count"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    private List<ProductDTO> query(String sql, Object... params) throws SQLException {
        List<ProductDTO> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) ps.setObject(i + 1, params[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /** 인기 상품: 거래완료 제외, 찜*3 + 조회수 순 */
    public List<ProductDTO> getPopularProducts(int limit) throws SQLException {
        return query(BASE_SELECT + "WHERE p.status <> 'DONE' " +
                     "ORDER BY (p.wish_count * 3 + p.view_count) DESC, p.id DESC LIMIT ?", limit);
    }

    /** 최신 등록 상품 */
    public List<ProductDTO> getNewProducts(int limit) throws SQLException {
        return query(BASE_SELECT + "ORDER BY p.created_at DESC, p.id DESC LIMIT ?", limit);
    }

    /**
     * 목록 조회 (카테고리 / 상태 / 검색어 / 정렬)
     * category : all, digital, book, living, etc
     * status   : all, SALE, RESERVED, DONE
     * sort     : new, popular, lowPrice, highPrice
     */
    public List<ProductDTO> getProducts(String category, String status, String keyword, String sort)
            throws SQLException {
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.isEmpty() && !"all".equals(category)) {
            sql.append("AND p.category = ? ");
            params.add(category);
        }
        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            sql.append("AND p.status = ? ");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.title LIKE ? OR p.description LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        if ("popular".equals(sort))        sql.append("ORDER BY (p.wish_count * 3 + p.view_count) DESC");
        else if ("lowPrice".equals(sort))  sql.append("ORDER BY p.price ASC");
        else if ("highPrice".equals(sort)) sql.append("ORDER BY p.price DESC");
        else                               sql.append("ORDER BY p.created_at DESC, p.id DESC");

        return query(sql.toString(), params.toArray());
    }

    public ProductDTO getProduct(int id) throws SQLException {
        List<ProductDTO> list = query(BASE_SELECT + "WHERE p.id = ?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    /** 같은 카테고리의 다른 상품 */
    public List<ProductDTO> getRelatedProducts(String category, int excludeId, int limit) throws SQLException {
        return query(BASE_SELECT + "WHERE p.category = ? AND p.id <> ? AND p.status <> 'DONE' " +
                     "ORDER BY p.created_at DESC LIMIT ?", category, excludeId, limit);
    }

    /** 판매자가 등록한 상품 (status null이면 전체) */
    public List<ProductDTO> getProductsBySeller(String sellerId, String status) throws SQLException {
        if (status == null)
            return query(BASE_SELECT + "WHERE p.seller_id = ? ORDER BY p.created_at DESC", sellerId);
        return query(BASE_SELECT + "WHERE p.seller_id = ? AND p.status = ? ORDER BY p.created_at DESC",
                     sellerId, status);
    }

    public int countBySeller(String sellerId, String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM product WHERE seller_id = ? AND status = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sellerId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** 상품 등록 → 생성된 id 반환 */
    public int insertProduct(ProductDTO p) throws SQLException {
        String sql = "INSERT INTO product (seller_id, title, price, category, item_condition, " +
                     "description, image, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'SALE')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getSellerId());
            ps.setString(2, p.getTitle());
            ps.setInt(3, p.getPrice());
            ps.setString(4, p.getCategory());
            ps.setString(5, p.getItemCondition());
            ps.setString(6, p.getDescription());
            ps.setString(7, p.getImage());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /** 거래 상태 변경 (본인 상품만) */
    public boolean updateStatus(int id, String status, String sellerId) throws SQLException {
        if (!Arrays.asList("SALE", "RESERVED", "DONE").contains(status)) return false;
        String sql = "UPDATE product SET status = ? WHERE id = ? AND seller_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.setString(3, sellerId);
            return ps.executeUpdate() == 1;
        }
    }

    /** 상품 삭제 (본인 상품만) */
    public boolean deleteProduct(int id, String sellerId) throws SQLException {
        String sql = "DELETE FROM product WHERE id = ? AND seller_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, sellerId);
            return ps.executeUpdate() == 1;
        }
    }

    public void increaseViewCount(int id) throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE product SET view_count = view_count + 1 WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
