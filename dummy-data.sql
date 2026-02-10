-- 더미 데이터 대량 삽입 (서울 전역 100개 이상)
-- Supabase SQL Editor에서 실행하세요

INSERT INTO public.hazards (type, description, lat, lng, image_url, created_at) VALUES

-- 강남구 (15개)
('pothole', '강남역 11번 출구 앞 대형 포트홀 발견. 깊이 약 15cm', 37.4979, 127.0276, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '강남대로 교통사고로 인한 정체, 우회 필요', 37.4950, 127.0290, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '30 minutes'),
('pothole', '논현역 인근 포트홀 다수', 37.5105, 127.0223, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '1 hour'),
('other', '신사역 가로수길 도로 공사', 37.5200, 127.0202, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '3 hours'),
('pothole', '압구정로데오역 앞 도로 파손', 37.5274, 127.0393, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '5 hours'),
('accident', '청담대교 남단 접촉사고', 37.5246, 127.0544, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '15 minutes'),
('pothole', '삼성역 코엑스 앞 포트홀', 37.5088, 127.0632, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('other', '선릉역 교차로 신호등 고장', 37.5045, 127.0489, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '4 hours'),
('pothole', '역삼역 강남대로 포트홀 주의', 37.5003, 127.0365, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '6 hours'),
('accident', '양재역 사거리 추돌사고', 37.4843, 127.0344, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '25 minutes'),
('flood', '대치동 은마아파트 앞 침수 위험', 37.4946, 127.0590, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '7 hours'),
('pothole', '도곡역 강남순환로 도로 파손', 37.4918, 127.0540, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '8 hours'),
('other', '개포동 구룡터널 보수 공사', 37.4857, 127.0640, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '일원동 대모산입구역 포트홀', 37.4886, 127.0835, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '수서역 경부고속도로 진입로 사고', 37.4871, 127.1019, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '45 minutes'),

-- 서초구 (12개)
('pothole', '서초역 교차로 포트홀', 37.4837, 127.0108, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '1 hour'),
('accident', '반포대교 남단 추돌사고', 37.5085, 126.9960, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '20 minutes'),
('other', '강남역 12번 출구 공사 중', 37.4981, 127.0280, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '교대역 서초대로 도로 파손', 37.4934, 127.0141, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('flood', '방배동 사거리 침수 주의', 37.4815, 126.9960, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '5 hours'),
('pothole', '남부터미널역 앞 포트홀 다수', 37.4764, 127.0044, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '양재 IC 근처 3중 추돌', 37.4703, 127.0357, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),
('other', '우면산터널 보수작업', 37.4589, 127.0192, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '내곡동 헌릉로 포트홀', 37.4684, 127.0945, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '6 hours'),
('ice', '우면동 고개 결빙 주의', 37.4748, 127.0086, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '8 hours'),
('pothole', '양재천 다리 근처 도로 파손', 37.4850, 127.0267, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('flood', '서리풀공원 지하차도 침수', 37.4900, 127.0089, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '7 hours'),

-- 송파구 (15개)
('pothole', '잠실역 인근 올림픽로 포트홀 다수', 37.5133, 127.1000, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('other', '롯데월드타워 앞 도로 공사 중', 37.5125, 127.1025, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '석촌역 인근 도로 파손 심각', 37.5055, 127.1060, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('flood', '가락시장역 지하차도 침수 위험', 37.4925, 127.1180, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '5 hours'),
('accident', '문정역 교차로 접촉사고', 37.4845, 127.1223, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '35 minutes'),
('pothole', '장지역 중대로 포트홀', 37.4785, 127.1262, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '1 hour'),
('other', '복정역 공사 진행 중', 37.4690, 127.1265, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '3 days'),
('pothole', '송파대로 방이동 구간 포트홀', 37.5115, 127.1150, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '올림픽대교 남단 사고', 37.5160, 127.0890, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '50 minutes'),
('flood', '탄천 범람 주의 - 삼전동', 37.5020, 127.1095, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '6 hours'),
('pothole', '위례신도시 입구 도로 파손', 37.4790, 127.1430, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('other', '마천역 도로 확장 공사', 37.4940, 127.1475, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '5 days'),
('pothole', '오금역 경찰서 사거리 포트홀', 37.5021, 127.1284, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('ice', '위례대로 고가도로 결빙', 37.4843, 127.1380, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '9 hours'),
('accident', '송파IC 진입로 추돌', 37.4968, 127.1042, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),

-- 강서구 (10개)
('pothole', '김포공항역 공항대로 포트홀', 37.5610, 126.8014, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '발산역 사거리 접촉사고', 37.5588, 126.8374, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '40 minutes'),
('pothole', '마곡나루역 앞 도로 파손', 37.5606, 126.8250, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '5 hours'),
('flood', '개화동 한강 범람 주의', 37.5783, 126.7960, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '4 hours'),
('other', '등촌역 도로 보수 공사', 37.5506, 126.8656, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '화곡역 까치산로 포트홀', 37.5412, 126.8465, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '마곡역 교차로 추돌사고', 37.5615, 126.8254, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '30 minutes'),
('pothole', '공항대로 방화대교 진입로 포트홀', 37.5803, 126.8155, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '6 hours'),
('flood', '오쇠동 지하차도 침수', 37.5480, 126.8520, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '7 hours'),
('other', '김포공항 진입로 공사', 37.5630, 126.7950, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '3 days'),

-- 영등포구 (10개)
('pothole', '여의도역 국회대로 포트홀', 37.5219, 126.9244, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('flood', '여의도 한강공원 인근 침수 주의', 37.5285, 126.9340, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '6 hours'),
('pothole', '국회의사당역 2번 출구 도로 파손', 37.5310, 126.9140, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '8 hours'),
('accident', '영등포역 교차로 접촉사고', 37.5155, 126.9070, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '25 minutes'),
('pothole', '신길역 도림로 포트홀 다수', 37.5092, 126.9173, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('other', '당산역 당산철교 보수 공사', 37.5344, 126.9025, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '대림역 신길로 도로 파손', 37.4933, 126.8956, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('flood', '양평동 지하차도 침수 위험', 37.5270, 126.8896, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '5 hours'),
('accident', '선유도역 앞 추돌사고', 37.5346, 126.8936, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),
('pothole', '문래역 영등포로 포트홀', 37.5176, 126.8947, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),

-- 마포구 (12개)
('pothole', '홍대입구역 9번 출구 근처 도로 함몰', 37.5568, 126.9233, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),
('flood', '와우산로 침수 구간, 차량 통행 주의', 37.5510, 126.9270, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '3 hours'),
('accident', '신촌역 로터리 접촉사고 발생', 37.5556, 126.9369, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '15 minutes'),
('pothole', '이대역 3번 출구 포트홀', 37.5563, 126.9455, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '1 hour'),
('other', '공덕역 공덕오거리 공사', 37.5443, 126.9512, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '마포역 마포대로 포트홀', 37.5390, 126.9451, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('accident', '합정역 사거리 추돌사고', 37.5494, 126.9136, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '45 minutes'),
('pothole', '상암동 월드컵로 도로 파손', 37.5795, 126.8900, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '5 hours'),
('flood', '상암DMC 지하차도 침수', 37.5797, 126.8891, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '6 hours'),
('other', '망원역 도로 보수 작업', 37.5555, 126.9104, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '연남동 연희로 포트홀', 37.5660, 126.9270, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '성산대교 북단 접촉사고', 37.5655, 126.9100, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '35 minutes'),

-- 용산구 (8개)
('pothole', '용산역 한강대로 포트홀', 37.5299, 126.9645, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '이촌역 사거리 추돌사고', 37.5220, 126.9653, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '50 minutes'),
('pothole', '한강진역 강변북로 포트홀', 37.5353, 126.9960, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('flood', '이촌한강공원 침수 주의', 37.5185, 126.9700, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '5 hours'),
('other', '삼각지역 도로 공사', 37.5346, 126.9734, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '남영역 한강로 도로 파손', 37.5407, 126.9717, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '한남대교 북단 접촉사고', 37.5363, 127.0070, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),
('pothole', '이태원역 이태원로 포트홀', 37.5345, 126.9945, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '6 hours'),

-- 성동구 (8개)
('pothole', '왕십리역 왕십리로 포트홀', 37.5610, 127.0380, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('other', '성수대교 남단 도로 보수 공사', 37.5445, 127.0410, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '뚝섬역 강변북로 포트홀', 37.5470, 127.0470, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('accident', '성수역 사거리 접촉사고', 37.5445, 127.0560, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '30 minutes'),
('pothole', '금호동 금호로 도로 파손', 37.5505, 127.0200, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('flood', '뚝섬한강공원 침수 위험', 37.5325, 127.0670, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '6 hours'),
('other', '응봉역 도로 확장 공사', 37.5503, 127.0265, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '3 days'),
('pothole', '행당역 행당로 포트홀', 37.5647, 127.0375, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '5 hours'),

-- 광진구 (8개)
('pothole', '건대입구역 앞 큰 포트홀 주의', 37.5403, 127.0695, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '구의역 사거리 추돌사고', 37.5373, 127.0855, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '40 minutes'),
('pothole', '강변역 강변북로 포트홀', 37.5350, 127.0945, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('flood', '광나루한강공원 침수', 37.5305, 127.1145, 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=400', NOW() - INTERVAL '5 hours'),
('other', '군자역 도로 보수 작업', 37.5574, 127.0793, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '아차산역 광나루로 포트홀', 37.5451, 127.1045, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '광진교 남단 접촉사고', 37.5375, 127.0755, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '55 minutes'),
('pothole', '중곡역 능동로 도로 파손', 37.5630, 127.0825, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '6 hours'),

-- 중구 (6개)
('ice', '광화문 사거리 결빙 구간, 미끄러움 주의', 37.5720, 126.9769, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '5 hours'),
('pothole', '명동역 명동길 포트홀', 37.5616, 126.9858, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '을지로입구역 교차로 사고', 37.5660, 126.9820, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '45 minutes'),
('other', '시청역 도로 공사', 37.5663, 126.9779, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '1 day'),
('pothole', '충무로역 퇴계로 포트홀', 37.5614, 126.9943, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('accident', '동대문역사문화공원역 사고', 37.5656, 127.0078, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),

-- 종로구 (8개)
('rockfall', '북악터널 입구 낙석 위험', 37.5944, 126.9743, 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400', NOW() - INTERVAL '1 day'),
('pothole', '광화문역 세종대로 포트홀', 37.5717, 126.9763, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours'),
('accident', '종로3가역 종로 추돌사고', 37.5707, 126.9919, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '35 minutes'),
('other', '청계천 도로 보수 공사', 37.5695, 126.9784, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '2 days'),
('pothole', '안국역 율곡로 포트홀', 37.5760, 126.9850, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('rockfall', '북촌한옥마을 길 낙석', 37.5820, 126.9830, 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400', NOW() - INTERVAL '2 days'),
('pothole', '혜화역 대학로 도로 파손', 37.5819, 127.0017, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('accident', '창경궁로 접촉사고', 37.5785, 127.0010, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '50 minutes'),

-- 강북구 (6개)
('ice', '미아사거리 교차로 결빙', 37.6130, 127.0250, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '10 hours'),
('rockfall', '북한산 우이동 입구 낙석 주의', 37.6570, 127.0120, 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400', NOW() - INTERVAL '12 hours'),
('pothole', '수유역 도봉로 포트홀', 37.6386, 127.0255, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '3 hours'),
('accident', '미아삼거리역 사고', 37.6130, 127.0280, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '1 hour'),
('pothole', '번동 4.19로 도로 파손', 37.6380, 127.0320, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '5 hours'),
('ice', '우이령길 결빙 구간', 37.6680, 127.0050, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '8 hours'),

-- 노원구 (6개)
('ice', '노원역 사거리 블랙아이스', 37.6544, 127.0613, 'https://images.unsplash.com/photo-1612119552770-ec7523a14e92?w=400', NOW() - INTERVAL '7 hours'),
('rockfall', '도봉산역 근처 산사태 위험', 37.6890, 127.0470, 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400', NOW() - INTERVAL '2 days'),
('pothole', '상계역 노원로 포트홀', 37.6543, 127.0733, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '4 hours'),
('accident', '중계역 교차로 추돌사고', 37.6495, 127.0725, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW() - INTERVAL '25 minutes'),
('other', '태릉입구역 도로 공사', 37.6174, 127.0758, 'https://images.unsplash.com/photo-1581094271901-8022df4466f9?w=400', NOW() - INTERVAL '3 days'),
('pothole', '화랑대역 화랑로 포트홀', 37.6170, 127.0775, 'https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=400', NOW() - INTERVAL '2 hours');

-- 데이터 확인
SELECT COUNT(*) as total_hazards FROM public.hazards;
SELECT type, COUNT(*) as count FROM public.hazards GROUP BY type ORDER BY count DESC;
