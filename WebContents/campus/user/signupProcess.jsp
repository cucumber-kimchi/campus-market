<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="my.dao.UserDAO, my.model.UserDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath() + "/campus";
    String userId = request.getParameter("userId");

    try {
        UserDAO dao = new UserDAO();
        if (userId == null || !userId.matches("[A-Za-z0-9_]{4,20}")) {
            out.println("<script>alert('아이디는 영문/숫자 4~20자입니다.'); history.back();</script>");
            return;
        }
        if (dao.exists(userId)) {
            out.println("<script>alert('이미 사용 중인 아이디입니다.'); history.back();</script>");
            return;
        }
        UserDTO u = new UserDTO();
        u.setUserId(userId);
        u.setPassword(request.getParameter("password"));
        u.setName(request.getParameter("name"));
        u.setSchool(request.getParameter("school"));
        dao.insert(u);
        out.println("<script>alert('가입을 환영합니다! 로그인해주세요.'); location.href='" + ctx + "/user/login.jsp';</script>");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('가입 중 오류가 발생했습니다.'); history.back();</script>");
    }
%>
