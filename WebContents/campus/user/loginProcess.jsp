<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="my.dao.UserDAO, my.model.UserDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath() + "/campus";
    UserDTO user = null;
    try {
        user = new UserDAO().login(request.getParameter("userId"), request.getParameter("password"));
    } catch (Exception e) { e.printStackTrace(); }

    if (user == null) {
        out.println("<script>alert('아이디 또는 비밀번호가 올바르지 않습니다.'); history.back();</script>");
        return;
    }
    session.setAttribute("userID", user.getUserId());
    session.setAttribute("userName", user.getName());
    session.setAttribute("userSchool", user.getSchool());
    response.sendRedirect(ctx + "/index.jsp");
%>
