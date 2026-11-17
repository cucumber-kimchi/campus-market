<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="my.dao.WishlistDAO, my.dao.ProductDAO, my.model.ProductDTO" %>
<%
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
        out.print("{\"status\":\"login_required\"}");
        return;
    }
    try {
        int productId = Integer.parseInt(request.getParameter("productId"));
        String result = new WishlistDAO().toggle(userID, productId);
        ProductDTO p = new ProductDAO().getProduct(productId);
        out.print("{\"status\":\"" + result + "\",\"count\":" + (p == null ? 0 : p.getWishCount()) + "}");
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\"}");
    }
%>
