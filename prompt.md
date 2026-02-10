# Project: 실시간 도로 위험 제보 및 사고 예방 웹앱 (Svelte + Firebase + Leaflet)

당신은 Svelte와 Firebase 전문가로서 아래 요구사항을 바탕으로 실제 작동하는 프로토타입 코드를 작성해야 합니다.

## 1. 프로젝트 목표 및 특징
- 사용자가 도로 위 위험 요소(낙석, 포트홀 등)를 실시간 제보하고 공유함.
- **로그인 없이** 누구나 익명으로 즉시 제보 가능.
- **Leaflet.js**와 OpenStreetMap을 사용하여 지도를 구현 (기업 API 키 없이 구현).
- 위험 지역 근처 접근 시 실시간 거리 계산 및 경고 알림.

## 2. 기술 스택
- Framework: Svelte
- Database/Storage: Firebase (Firestore & Storage)
- Map Library: Leaflet.js (OpenStreetMap 타일 사용)
- Styling: CSS (운전 중 시인성을 위해 버튼과 UI를 크게 설계)

## 3. 핵심 구현 요청 사항

### [Step 1: Firebase & Leaflet 초기 설정]
- Firebase `db`, `storage` 인스턴스 설정 (익명 접근 허용 규칙 전제).
- Leaflet 지도 초기화 및 사용자 현재 위치(GPS) 추적 마커 표시.

### [Step 2: 실시간 데이터 동기화]
- Firestore의 `hazards` 컬렉션을 `onSnapshot`으로 구독.
- 새로운 제보가 들어오면 Leaflet 지도 위에 커스텀 마커를 실시간으로 추가/업데이트.

### [Step 3: 사진 제보 폼 (UI/UX)]
- 사진 파일 선택 -> Firebase Storage 업로드 -> Firestore에 위치 데이터와 함께 저장.
- 저장 필드: `{ type, description, lat, lng, imageUrl, timestamp }`
- 하단 고정형 대형 버튼으로 제보 폼 호출.

### [Step 4: 사고 예방 거리 계산]
- Haversine 공식을 사용하여 실시간 위치와 모든 마커 사이의 거리($m$) 계산.
- 마커와 500m 이내로 인접할 경우 시각적 경고(UI 상단 바 색상 변경 등) 구현.

## 4. 코드 작성 가이드
- Svelte 컴포넌트 구조로 작성해줘.
- Leaflet CSS가 제대로 로드되도록 `<svelte:head>` 태그를 포함해줘.
- 별도의 백엔드 없이 프론트엔드 코드만으로 완결성 있게 작성해줘.