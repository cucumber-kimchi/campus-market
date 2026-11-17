<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="my.dao.ProductDAO" %>
<%
    String ctx = request.getContextPath() + "/campus";
    String userID = (String) session.getAttribute("userID");
    if (userID == null) { response.sendRedirect(ctx + "/user/login.jsp"); return; }

    boolean ok = false;
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        ok = new ProductDAO().deleteProduct(id, userID);
    } catch (Exception e) { e.printStackTrace(); }

    if (ok) out.println("<script>alert('삭제되었습니다.'); location.href='" + ctx + "/user/mypage.jsp';</script>");
    else    out.println("<script>alert('삭제할 수 없습니다.'); history.back();</script>");
%>
