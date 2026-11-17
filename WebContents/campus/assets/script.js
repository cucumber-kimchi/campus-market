/* 캠퍼스마켓 공통 스크립트 (CTX, IS_LOGIN 은 footer.jsp 에서 선언) */

// 찜 토글
function toggleHeart(btn, productId) {
    fetch(CTX + '/product/wishlistProcess.jsp?productId=' + productId, { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'login_required') {
                if (confirm('로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?')) {
                    location.href = CTX + '/user/login.jsp';
                }
            } else if (data.status === 'added') {
                btn.classList.add('active');
                showToast('찜 목록에 추가했어요 ♥');
            } else if (data.status === 'removed') {
                btn.classList.remove('active');
                showToast('찜 목록에서 삭제했어요');
            }
            const cnt = document.getElementById('wishCount');
            if (cnt && data.count !== undefined) cnt.textContent = data.count;
        })
        .catch(() => showToast('잠시 후 다시 시도해주세요'));
}

// 하단 토스트 메시지
function showToast(msg) {
    let t = document.getElementById('toast');
    if (!t) {
        t = document.createElement('div');
        t.id = 'toast';
        t.className = 'toast';
        document.body.appendChild(t);
    }
    t.textContent = msg;
    t.classList.add('show');
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.remove('show'), 1800);
}

document.addEventListener('DOMContentLoaded', function () {
    // 맨 위로 버튼
    const topBtn = document.getElementById('scrollToTopBtn');
    if (topBtn) {
        window.addEventListener('scroll', () => {
            topBtn.style.display = window.scrollY > 200 ? 'block' : 'none';
        });
        topBtn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
    }

    // 배너 슬라이더
    const track = document.querySelector('.banner-track');
    if (track) {
        const dots = document.querySelectorAll('.slider-dots .dot');
        const len = track.children.length;
        let idx = 0;
        const slide = i => {
            track.style.transform = 'translateX(-' + (i * 100) + '%)';
            dots.forEach(d => d.classList.remove('active'));
            if (dots[i]) dots[i].classList.add('active');
            idx = i;
        };
        const next = document.querySelector('.next-btn');
        const prev = document.querySelector('.prev-btn');
        if (next) next.addEventListener('click', () => slide((idx + 1) % len));
        if (prev) prev.addEventListener('click', () => slide((idx - 1 + len) % len));
        dots.forEach(d => d.addEventListener('click', () => slide(Number(d.dataset.index))));
        setInterval(() => slide((idx + 1) % len), 5000);
    }

    // 로그인이 필요한 링크 (class="need-login")
    document.querySelectorAll('.need-login').forEach(a => {
        a.addEventListener('click', e => {
            if (!IS_LOGIN) {
                e.preventDefault();
                alert('로그인이 필요한 서비스입니다.');
                location.href = CTX + '/user/login.jsp';
            }
        });
    });
});
