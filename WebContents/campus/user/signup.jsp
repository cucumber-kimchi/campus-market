<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원가입 - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />
<main>
    <section class="auth-box">
        <h2>회원가입</h2>
        <p class="form-sub">같은 학교 학생끼리만 거래할 수 있어요</p>
        <form action="${ctx}/user/signupProcess.jsp" method="post" class="card-form"
              onsubmit="if(this.password.value!==this.password2.value){alert('비밀번호가 일치하지 않습니다.');return false;}">
            <div class="form-group">
                <label for="userId">아이디</label>
                <input type="text" id="userId" name="userId" class="form-control" pattern="[A-Za-z0-9_]{4,20}"
                       title="영문/숫자 4~20자" required>
            </div>
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" class="form-control" minlength="4" required>
            </div>
            <div class="form-group">
                <label for="password2">비밀번호 확인</label>
                <input type="password" id="password2" name="password2" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="name">이름(닉네임)</label>
                <input type="text" id="name" name="name" class="form-control" maxlength="20" required>
            </div>
            <div class="form-group">
                <label for="school">학교</label>
                <input type="text" id="school" name="school" class="form-control" placeholder="예) 한국공학대학교" required>
            </div>
            <button type="submit" class="btn-primary full">가입하기</button>
            <p class="auth-link">이미 회원이신가요? <a href="${ctx}/user/login.jsp">로그인</a></p>
        </form>
    </section>
</main>
<jsp:include page="/campus/common/footer.jsp" />
</body>
</html>
