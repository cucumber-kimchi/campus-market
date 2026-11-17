<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="my.dao.ProductDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath() + "/campus";
    String userID = (String) session.getAttribute("userID");
    if (userID == null) { response.sendRedirect(ctx + "/user/login.jsp"); return; }

    int id = Integer.parseInt(request.getParameter("id"));
    String status = request.getParameter("status");
    String redirect = request.getParameter("redirect");

    boolean ok = false;
    try { ok = new ProductDAO().updateStatus(id, status, userID); } catch (Exception e) { e.printStackTrace(); }

    if (!ok) {
        out.println("<script>alert('상태를 변경할 수 없습니다.'); history.back();</script>");
        return;
    }
    if ("mypage".equals(redirect)) response.sendRedirect(ctx + "/user/mypage.jsp?tab=" + request.getParameter("tab"));
    else response.sendRedirect(ctx + "/product/detail.jsp?id=" + id);
%>
