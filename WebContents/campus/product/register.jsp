<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (session.getAttribute("userID") == null) {
        out.println("<script>alert('로그인 후 상품을 등록할 수 있어요.'); location.href='"
                    + request.getContextPath() + "/campus/user/login.jsp';</script>");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>상품 등록 - 캠퍼스마켓</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/campus/assets/style.css">
</head>
<body>
<jsp:include page="/campus/common/header.jsp"><jsp:param name="menu" value="" /></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}/campus" />

<main>
    <section class="form-page">
        <h2 class="section-title-main">상품 등록</h2>
        <p class="form-sub">기본 정보만 입력하고 <b>AI로 판매글 작성</b>을 누르면 제목과 상세 설명을 자동으로 채워드려요.</p>

        <form id="registerForm" action="${ctx}/product/registerProcess.jsp" method="post"
              enctype="multipart/form-data" class="card-form">

            <!-- 1. 이미지 -->
            <div class="form-group">
                <label>상품 이미지</label>
                <label class="image-upload" id="imageBox">
                    <input type="file" name="image" id="imageInput" accept="image/*" hidden>
                    <span id="imagePlaceholder">📷<br>사진 올리기</span>
                    <img id="imagePreview" alt="" hidden>
                </label>
            </div>

            <!-- 2. 기본 정보 (AI 입력값) -->
            <div class="form-row">
                <div class="form-group">
                    <label for="name">상품명 <em>*</em></label>
                    <input type="text" id="name" class="form-control" placeholder="예) 아이패드 9세대 64GB" maxlength="50" required>
                </div>
                <div class="form-group">
                    <label for="category">카테고리 <em>*</em></label>
                    <select name="category" id="category" class="form-control" required>
                        <option value="">선택하세요</option>
                        <option value="digital">디지털기기</option>
                        <option value="book">도서・교재</option>
                        <option value="living">생활용품</option>
                        <option value="etc">기타</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="price">가격 <em>*</em></label>
                    <div class="input-suffix">
                        <input type="number" name="price" id="price" class="form-control" min="0" step="100" placeholder="0" required>
                        <span>원</span>
                    </div>
                </div>
                <div class="form-group">
                    <label>상품 상태 <em>*</em></label>
                    <div class="radio-chips">
                        <label><input type="radio" name="itemCondition" value="새상품" required><span>새상품</span></label>
                        <label><input type="radio" name="itemCondition" value="거의 새것"><span>거의 새것</span></label>
                        <label><input type="radio" name="itemCondition" value="사용감 있음"><span>사용감 있음</span></label>
                        <label><input type="radio" name="itemCondition" value="하자 있음"><span>하자 있음</span></label>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="features">주요 특징</label>
                <textarea id="features" class="form-control" rows="3"
                          placeholder="예) 작년 3월 구매, 필기용으로만 사용, 케이스·필름 포함, 정문 직거래 희망"></textarea>
            </div>

            <!-- 3. AI 생성 -->
            <div class="ai-box">
                <div>
                    <strong>🤖 AI 판매글 자동 작성</strong>
                    <p>위 정보를 바탕으로 제목과 상세 설명을 만들어요. 생성 후 자유롭게 수정할 수 있어요.</p>
                </div>
                <button type="button" id="aiBtn" class="btn-ai">AI로 판매글 작성</button>
            </div>

            <!-- 4. 최종 게시물 -->
            <div class="form-group">
                <label for="title">게시글 제목 <em>*</em></label>
                <input type="text" name="title" id="title" class="form-control" maxlength="100" required
                       placeholder="AI로 생성하거나 직접 입력하세요">
            </div>
            <div class="form-group">
                <label for="description">상세 설명 <em>*</em></label>
                <textarea name="description" id="description" class="form-control" rows="9" required
                          placeholder="AI로 생성하거나 직접 입력하세요"></textarea>
            </div>

            <div class="form-buttons">
                <a href="javascript:history.back()" class="btn-outline">취소</a>
                <button type="submit" class="btn-primary">등록하기</button>
            </div>
        </form>
    </section>
</main>

<jsp:include page="/campus/common/footer.jsp" />

<script>
// 이미지 미리보기
document.getElementById('imageInput').addEventListener('change', function () {
    const file = this.files[0];
    const preview = document.getElementById('imagePreview');
    const holder = document.getElementById('imagePlaceholder');
    if (!file) { preview.hidden = true; holder.hidden = false; return; }
    if (file.size > 10 * 1024 * 1024) { alert('이미지는 10MB 이하만 올릴 수 있어요.'); this.value = ''; return; }
    preview.src = URL.createObjectURL(file);
    preview.hidden = false;
    holder.hidden = true;
});

// AI 판매글 생성
document.getElementById('aiBtn').addEventListener('click', function () {
    const name = document.getElementById('name').value.trim();
    const price = document.getElementById('price').value.trim();
    const condition = (document.querySelector('input[name="itemCondition"]:checked') || {}).value || '';
    const categorySel = document.getElementById('category');
    const features = document.getElementById('features').value.trim();

    if (!name || !price || !condition) {
        alert('상품명, 가격, 상품 상태를 먼저 입력해주세요.');
        return;
    }

    const titleEl = document.getElementById('title');
    const descEl = document.getElementById('description');
    if ((titleEl.value || descEl.value) && !confirm('이미 작성한 제목/설명을 AI 결과로 바꿀까요?')) return;

    const btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner"></span> 작성 중...';

    const body = new URLSearchParams({
        name: name,
        price: price,
        condition: condition,
        category: categorySel.options[categorySel.selectedIndex].text,
        features: features
    });

    fetch(CTX + '/product/aiGenerate.jsp', { method: 'POST', body: body })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'ok') {
                titleEl.value = data.title;
                descEl.value = data.description;
                showToast(data.source === 'ai' ? 'AI가 판매글을 작성했어요 ✨' : '기본 템플릿으로 작성했어요 (AI 키 미설정)');
            } else {
                alert(data.message || '생성에 실패했어요. 다시 시도해주세요.');
            }
        })
        .catch(() => alert('서버와 통신 중 오류가 발생했어요.'))
        .finally(() => {
            btn.disabled = false;
            btn.textContent = '다시 생성하기';
        });
});
</script>
</body>
</html>
