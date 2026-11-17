<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<main>
    <section class="auth-box">
        <h2>로그인</h2>
        <p class="form-sub">우리 학교 학생들과 안전하게 거래하세요 🎓</p>
        <form action="${ctx}/user/loginProcess.jsp" method="post" class="card-form">
            <div class="form-group">
                <label for="userId">아이디</label>
                <input type="text" id="userId" name="userId" class="form-control" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn-primary full">로그인</button>
            <p class="auth-link">아직 회원이 아니신가요? <a href="${ctx}/user/signup.jsp">회원가입</a></p>
            <p class="auth-hint">테스트 계정: test / 1234</p>
        </form>
    </section>
</main>
<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
