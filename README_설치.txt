이탈리아·슬로베니아 여행 PWA

[설치 방법]
1. 이 폴더의 파일 전체를 GitHub Pages 또는 Netlify에 업로드합니다.
2. 스마트폰에서 생성된 HTTPS 주소로 접속합니다.
3. Android/Chrome: '앱 설치' 버튼 또는 브라우저 메뉴 → 앱 설치
4. iPhone/Safari: 공유 버튼 → 홈 화면에 추가

[주의]
- HTML 파일을 폰에서 직접 여는 file:// 방식에서는 서비스워커/PWA 설치가 작동하지 않습니다.
- 지도 타일과 관광지 외부 링크는 인터넷 연결이 필요합니다.
- 입력한 일정은 해당 브라우저 기기의 localStorage에 저장됩니다.
- 기기 간 동기화는 아직 지원하지 않습니다.

[아이콘]
피렌체 풍경 + 하트 동선 + 작은 토끼 캐릭터 버전으로 적용됨.


[실시간 동기화 설정]
1. Supabase → Authentication → URL Configuration
2. Site URL: https://leeganu.github.io/italy-trip/
3. Redirect URLs: https://leeganu.github.io/italy-trip/**
4. Supabase → SQL Editor → New query
5. SUPABASE_설정.sql 내용을 전부 붙여넣고 Run
6. 이 ZIP 안의 파일을 GitHub 저장소에 덮어쓰기
7. 앱에서 ☁️ 동기화 → 이메일 로그인
8. 첫 기기: 새 여행방 만들기 → 6자리 초대코드 복사
9. 두 번째 기기: 이메일 로그인 → 초대코드 입력 → 참여

보안: anon/public 키만 웹앱에 들어가며 service_role 키는 사용하지 않음. RLS로 여행방 멤버만 데이터를 읽고 수정할 수 있음.
동시 편집: 두 기기에서 정확히 같은 순간 서로 다른 항목을 수정하면 마지막 저장이 우선될 수 있음.


[작은 화면 UI 개편]
- 모바일 첫 화면을 짧게 압축
- 동기화 버튼만 전면 배치, 나머지 기능은 '관리' 메뉴로 이동
- 가로 14일 바 대신 세로형 전체 여정을 기본 표시
- 기존 14일 바는 '14일 전체 바 일정 보기'에서 필요할 때만 펼침
- 도시 카드·일정 카드·예약 입력칸 크기를 작은 휴대폰에 맞게 축소
