<script>
  import { onMount, onDestroy } from 'svelte';
  import L from 'leaflet';
  import 'leaflet-routing-machine';
  import { supabase } from './lib/supabase';
  import { analyzeRoutesWithAI } from './lib/gemini';
  import { AlertTriangle, Camera, X, MapPin, Navigation, Route, ShoppingBag } from 'lucide-svelte';

  // 상태 변수
  let map = null;
  let userMarker = null;
  let userLocation = { lat: 37.5665, lng: 126.9780 }; // 서울 기본 위치
  let hazardMarkers = [];
  let hazards = [];
  let showReportForm = false;
  let isNearHazard = false;
  let nearestHazardDistance = Infinity;
  let watchId = null;
  let realtimeChannel = null;

  // 사용자 포인트 (로그인 없이 로컬 스토리지 사용)
  let userPoints = 0;
  let showPointsGainModal = false;
  let pointsGainedMessage = '';

  // 상품 거래 모달
  let showShopModal = false;
  let shopProducts = [
    {
      id: 1,
      name: '피자 쿠폰',
      image: '/src/assets/피자.jpg',
      points: 150,
      category: 'food',
      description: '인기 피자 브랜드 할인 쿠폰'
    },
    {
      id: 2,
      name: '치킨 쿠폰',
      image: '/src/assets/치킨.jpg',
      points: 120,
      category: 'food',
      description: '맛있는 치킨 할인 쿠폰'
    },
    {
      id: 3,
      name: '베라 쿠폰',
      image: '/src/assets/베라.webp',
      points: 100,
      category: 'food',
      description: '베라 브랜드 할인 쿠폰'
    },
    {
      id: 4,
      name: '찜닭 쿠폰',
      image: '/src/assets/찜닭.webp',
      points: 130,
      category: 'food',
      description: '찜닭 맛집 할인 쿠폰'
    },
    {
      id: 5,
      name: '올리브영 상품권',
      image: '/src/assets/올리브영상품권.jpg',
      points: 200,
      category: 'giftcard',
      description: '올리브영 10,000원 상품권'
    },
    {
      id: 6,
      name: '문화상품권',
      image: '/src/assets/문화상품권.jpg',
      points: 180,
      category: 'giftcard',
      description: '문화상품권 10,000원권'
    }
  ];

  // 네비게이션 관련

  // 네비게이션 관련
  let showNavigationPanel = false;
  let destinationAddress = '';
  let destinationCoords = null;
  let routingControl = null;
  let currentRoute = null;
  let routeHazards = [];
  let isNavigating = false;
  let alternativeRoutes = [];
  let showRouteSelection = false;
  let useSafeRoute = true; // 안전한 경로 사용 여부
  let currentRouteIndex = 0; // 현재 사용 중인 경로 인덱스
  let routeLine = null; // 경로 라인 (polyline)
  let aiRecommendation = null; // Gemini AI 추천
  let isAnalyzingWithAI = false; // AI 분석 중

  // 폼 데이터
  let reportType = 'pothole';
  let reportDescription = '';
  let reportImage = null;
  let reportImagePreview = null;
  let isSubmitting = false;

  const hazardTypes = [
    { value: 'pothole', label: '포트홀', color: '#ef4444', severity: 3 },
    { value: 'rockfall', label: '낙석', color: '#f97316', severity: 5 },
    { value: 'ice', label: '결빙', color: '#3b82f6', severity: 4 },
    { value: 'flood', label: '침수', color: '#06b6d4', severity: 5 },
    { value: 'accident', label: '사고', color: '#dc2626', severity: 10 },
    { value: 'other', label: '기타', color: '#8b5cf6', severity: 2 }
  ];

  // 경로의 총 위험도 계산 (개수 x 심각도)
  function calculateRouteDanger(hazards) {
    return hazards.reduce((total, hazard) => {
      const type = hazardTypes.find(t => t.value === hazard.type);
      return total + (type?.severity || 1);
    }, 0);
  }

  // Haversine 공식으로 두 좌표 사이의 거리 계산 (미터 단위)
  function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // 지구 반지름 (미터)
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // 거리 (미터)
  }

  // 점과 선분 사이의 최단 거리 계산
  function distanceToSegment(px, py, x1, y1, x2, y2) {
    const A = px - x1;
    const B = py - y1;
    const C = x2 - x1;
    const D = y2 - y1;

    const dot = A * C + B * D;
    const lenSq = C * C + D * D;
    let param = -1;

    if (lenSq !== 0) param = dot / lenSq;

    let xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    return calculateDistance(px, py, xx, yy);
  }

  // 경로와 위험 지역 교차 체크
  function checkRouteHazards(route) {
    if (!route || !route.coordinates) return [];

    const foundHazards = [];
    const coordinates = route.coordinates;

    hazards.forEach(hazard => {
      let minDistance = Infinity;

      // 경로의 각 선분에 대해 위험 지역까지의 최단 거리 계산
      for (let i = 0; i < coordinates.length - 1; i++) {
        const segStart = coordinates[i];
        const segEnd = coordinates[i + 1];

        const distance = distanceToSegment(
          hazard.lat,
          hazard.lng,
          segStart.lat,
          segStart.lng,
          segEnd.lat,
          segEnd.lng
        );

        minDistance = Math.min(minDistance, distance);
      }

      // 경로로부터 50m 이내에 위험 지역이 있으면 경고 (더 엄격하게)
      if (minDistance <= 50) {
        foundHazards.push({
          ...hazard,
          distanceFromRoute: Math.round(minDistance)
        });
      }
    });

    return foundHazards;
  }

  // 모든 위험 지역과의 거리 체크
  function checkProximityToHazards() {
    let minDistance = Infinity;

    hazards.forEach(hazard => {
      const distance = calculateDistance(
        userLocation.lat,
        userLocation.lng,
        hazard.lat,
        hazard.lng
      );

      if (distance < minDistance) {
        minDistance = distance;
      }
    });

    nearestHazardDistance = minDistance;
    isNearHazard = minDistance <= 500; // 500m 이내
  }

  // 사용자 위치 업데이트
  function updateUserLocation(lat, lng) {
    userLocation = { lat, lng };

    if (map) {


      if (userMarker) {
        userMarker.setLatLng([lat, lng]);
      } else {
        // 사용자 마커 생성 (파란색 원)
        userMarker = L.circleMarker([lat, lng], {
          color: '#3b82f6',
          fillColor: '#60a5fa',
          fillOpacity: 0.8,
          radius: 10,
          weight: 3
        }).addTo(map);

        userMarker.bindPopup('현재 위치');
      }
    }

    checkProximityToHazards();
  }

  // 위험 마커 생성
  function createHazardMarker(hazard) {
    const typeInfo = hazardTypes.find(t => t.value === hazard.type) || hazardTypes[0];

    // 커스텀 아이콘 생성
    const icon = L.divIcon({
      className: 'custom-hazard-marker',
      html: `
        <div style="
          background-color: ${typeInfo.color};
          width: 40px;
          height: 40px;
          border-radius: 50%;
          border: 3px solid white;
          box-shadow: 0 2px 8px rgba(0,0,0,0.3);
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 20px;
        ">
          ⚠️
        </div>
      `,
      iconSize: [40, 40],
      iconAnchor: [20, 20]
    });

    const marker = L.marker([hazard.lat, hazard.lng], { icon }).addTo(map);

    // 팝업 내용
    let popupContent = `
      <div style="min-width: 200px;">
        <h3 style="font-weight: 600; font-size: 16px; margin-bottom: 8px; color: ${typeInfo.color};">
          ${typeInfo.label}
        </h3>
        <p style="margin-bottom: 8px; color: #4b5563;">
          ${hazard.description || '설명 없음'}
        </p>
    `;

    if (hazard.image_url) {
      popupContent += `
        <img src="${hazard.image_url}"
             style="width: 100%; height: 150px; object-fit: cover; border-radius: 8px; margin-bottom: 8px;"
             alt="위험 사진" />
      `;
    }

    popupContent += `
        <p style="font-size: 12px; color: #9ca3af;">
          ${new Date(hazard.created_at).toLocaleString('ko-KR')}
        </p>
      </div>
    `;

    marker.bindPopup(popupContent);

    return marker;
  }

  // 위험 데이터 로드
  async function loadHazards() {
    const { data, error } = await supabase
      .from('hazards')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('데이터 로드 오류:', error);
      return;
    }

    // 기존 마커 제거
    hazardMarkers.forEach(marker => marker.remove());
    hazardMarkers = [];
    hazards = data || [];

    // 새로운 마커 추가
    hazards.forEach(hazard => {
      if (map) {
        const marker = createHazardMarker(hazard);
        hazardMarkers.push(marker);
      }
    });

    checkProximityToHazards();

    // 경로가 있으면 다시 체크
    if (currentRoute) {
      routeHazards = checkRouteHazards(currentRoute);
    }
  }

  // 실시간 구독
  function subscribeToHazards() {
    realtimeChannel = supabase
      .channel('hazards-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'hazards'
        },
        (payload) => {
          console.log('실시간 업데이트:', payload);
          loadHazards();
        }
      )
      .subscribe();
  }

  // 주소를 좌표로 변환 (Nominatim API 사용)
  async function geocodeAddress(address) {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&countrycodes=kr&limit=1`
      );
      const data = await response.json();

      if (data.length > 0) {
        return {
          lat: parseFloat(data[0].lat),
          lng: parseFloat(data[0].lon)
        };
      }
      return null;
    } catch (error) {
      console.error('주소 검색 오류:', error);
      return null;
    }
  }

  // 경로 토글 (안전 경로 ↔ 빠른 경로)
  function toggleRoute() {
    if (alternativeRoutes.length < 2) return;

    // 가장 안전한 경로와 가장 빠른 경로 찾기
    const safestRoute = alternativeRoutes.reduce((prev, curr) =>
      curr.dangerScore < prev.dangerScore ? curr : prev
    );
    const fastestRoute = alternativeRoutes[0]; // 메인 경로가 가장 빠름

    let selectedRoute;
    if (useSafeRoute) {
      selectedRoute = safestRoute;
    } else {
      selectedRoute = fastestRoute;
    }

    // 경로 정보 업데이트
    currentRouteIndex = selectedRoute.index;
    currentRoute = selectedRoute.route;
    routeHazards = selectedRoute.hazards;

    // 기존 routingControl의 경로 라인 숨기기
    if (routingControl) {
      const container = document.querySelector('.leaflet-routing-container');
      if (container) container.style.display = 'none';
    }

    // 기존 커스텀 라인 제거
    if (routeLine && map) {
      map.removeLayer(routeLine);
    }

    // 새 경로 라인 그리기
    const coords = selectedRoute.route.coordinates.map(c => [c.lat, c.lng]);
    routeLine = L.polyline(coords, {
      color: useSafeRoute ? '#10b981' : '#2563eb',
      weight: 6,
      opacity: 0.8
    }).addTo(map);
  }

  // Routing Control 생성
  function createRoutingControl(startLatLng, endLatLng) {
    routingControl = L.Routing.control({
      waypoints: [startLatLng, endLatLng],
      routeWhileDragging: false,
      addWaypoints: false,
      alternatives: true, // 대체 경로 계산
      altLineOptions: {
        styles: [
          { color: '#94a3b8', opacity: 0.6, weight: 5 }
        ]
      },
      lineOptions: {
        styles: [{ color: '#2563eb', opacity: 0.8, weight: 6 }]
      },
      createMarker: function(i, waypoint, n) {
        if (i === 0) {
          return L.marker(waypoint.latLng, {
            icon: L.divIcon({
              className: 'custom-marker',
              html: '<div style="background: #3b82f6; width: 30px; height: 30px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>',
              iconSize: [30, 30],
              iconAnchor: [15, 15]
            })
          });
        } else {
          return L.marker(waypoint.latLng, {
            icon: L.divIcon({
              className: 'custom-marker',
              html: '<div style="background: #ef4444; width: 30px; height: 30px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>',
              iconSize: [30, 30],
              iconAnchor: [15, 15]
            })
          });
        }
      }
    }).addTo(map);

    // 경로 계산 완료 시
    routingControl.on('routesfound', function(e) {
      const routes = e.routes;

      // 모든 경로에 대해 위험 지역 체크
      alternativeRoutes = routes.map((route, index) => {
        const hazards = checkRouteHazards(route);
        return {
          route: route,
          hazards: hazards,
          dangerScore: calculateRouteDanger(hazards),
          index: index
        };
      });

      // 가장 안전한 경로 찾기 (위험도 점수가 가장 낮은 경로)
      const safestRoute = alternativeRoutes.reduce((prev, curr) =>
        curr.dangerScore < prev.dangerScore ? curr : prev
      );

      const mainRoute = alternativeRoutes[0];

      // Gemini AI에게 경로 분석 요청 (비동기)
      isAnalyzingWithAI = true;
      analyzeRoutesWithAI(alternativeRoutes, hazardTypes).then(recommendation => {
        aiRecommendation = recommendation;
        isAnalyzingWithAI = false;

        // AI 추천 경로 선택
        if (recommendation.recommendedRoute !== undefined) {
          const recommendedRoute = alternativeRoutes[recommendation.recommendedRoute];
          if (recommendedRoute) {
            // 추천 경로가 안전한 경로인지 판단
            const safestRoute = alternativeRoutes.reduce((prev, curr) =>
              curr.dangerScore < prev.dangerScore ? curr : prev
            );
            const isSafestRoute = recommendedRoute.index === safestRoute.index;

            // 토글 상태를 AI 추천에 맞게 설정
            useSafeRoute = isSafestRoute;

            currentRouteIndex = recommendedRoute.index;
            currentRoute = recommendedRoute.route;
            routeHazards = recommendedRoute.hazards;

            // 기존 경로 라인 제거
            if (routeLine && map) {
              map.removeLayer(routeLine);
            }

            // AI 추천 경로를 토글 색상으로 그리기
            const coords = recommendedRoute.route.coordinates.map(c => [c.lat, c.lng]);
            routeLine = L.polyline(coords, {
              color: useSafeRoute ? '#10b981' : '#2563eb', // 초록색(안전) / 파란색(빠른)
              weight: 6,
              opacity: 0.8
            }).addTo(map);

            // AI 추천 알림
            const routeType = useSafeRoute ? '🛡️ 안전 경로' : '⚡ 빠른 경로';
            const alertMessage = `🤖 Gemini AI 추천\n\n` +
              `추천: ${routeType} (경로 ${recommendation.recommendedRoute + 1})\n` +
              `안전도: ${recommendation.safetyScore}/100점\n\n` +
              `${recommendation.reason}` +
              (recommendation.warning ? `\n\n⚠️ ${recommendation.warning}` : '');

            alert(alertMessage);
          }
        }
      }).catch(error => {
        console.error('AI 분석 실패:', error);
        isAnalyzingWithAI = false;
        // 기본 로직으로 폴백
        if (useSafeRoute && safestRoute.index !== mainRoute.index) {
          currentRouteIndex = safestRoute.index;
          currentRoute = safestRoute.route;
          routeHazards = safestRoute.hazards;
        } else {
          currentRouteIndex = mainRoute.index;
          currentRoute = mainRoute.route;
          routeHazards = mainRoute.hazards;
        }
      });

      // 일단 기본 경로 설정
      let initialRoute;
      if (useSafeRoute && safestRoute.index !== mainRoute.index) {
        currentRouteIndex = safestRoute.index;
        currentRoute = safestRoute.route;
        routeHazards = safestRoute.hazards;
        initialRoute = safestRoute;
      } else {
        currentRouteIndex = mainRoute.index;
        currentRoute = mainRoute.route;
        routeHazards = mainRoute.hazards;
        initialRoute = mainRoute;
      }

      // 기존 routingControl의 경로 라인 숨기기
      setTimeout(() => {
        const container = document.querySelector('.leaflet-routing-container');
        if (container) container.style.display = 'none';
      }, 100);

      // 초기 경로 라인 그리기 (AI 추천 전)
      if (routeLine && map) {
        map.removeLayer(routeLine);
      }
      const coords = initialRoute.route.coordinates.map(c => [c.lat, c.lng]);
      routeLine = L.polyline(coords, {
        color: useSafeRoute ? '#10b981' : '#2563eb',
        weight: 6,
        opacity: 0.8
      }).addTo(map);

      isNavigating = true;

      // 메인 경로에 위험이 있고, 더 안전한 대체 경로가 있으면 알림
      if (mainRoute.hazards.length > 0 && safestRoute.hazards.length < mainRoute.hazards.length) {
        if (useSafeRoute) {
          alert(
            `✅ 안전한 우회 경로로 자동 변경되었습니다!\n\n` +
            `빠른 경로: 위험 ${mainRoute.hazards.length}개 (위험도 ${mainRoute.dangerScore}점)\n` +
            `안전 경로: 위험 ${safestRoute.hazards.length}개 (위험도 ${safestRoute.dangerScore}점)\n\n` +
            `💡 네비게이션 패널에서 경로를 전환할 수 있습니다.`
          );
        } else {
          const useAlternative = confirm(
            `⚠️ 경고: 현재 경로에 ${mainRoute.hazards.length}개의 위험 지역이 있습니다! (위험도 ${mainRoute.dangerScore}점)\n\n` +
            `더 안전한 우회 경로 (위험 ${safestRoute.hazards.length}개, 위험도 ${safestRoute.dangerScore}점)로 변경하시겠습니까?`
          );

          if (useAlternative) {
            useSafeRoute = true;
            currentRouteIndex = safestRoute.index;
            currentRoute = safestRoute.route;
            routeHazards = safestRoute.hazards;
          }
        }
      } else if (mainRoute.hazards.length > 0) {
        // 대체 경로도 위험하면 경고만 표시
        const confirmed = confirm(
          `⚠️ 경고: 경로 상에 ${mainRoute.hazards.length}개의 위험 지역이 있습니다!\n\n` +
          `모든 경로에 위험이 있습니다. 계속 진행하시겠습니까?`
        );

        if (!confirmed) {
          stopNavigation();
        }
      }
    });
  }

  // 네비게이션 시작
  async function startNavigation() {
    if (!destinationAddress.trim()) {
      alert('목적지를 입력해주세요!');
      return;
    }

    const destination = await geocodeAddress(destinationAddress);

    if (!destination) {
      alert('목적지를 찾을 수 없습니다. 다시 시도해주세요.');
      return;
    }

    destinationCoords = destination;

    // 기존 경로 제거
    if (routingControl) {
      map.removeControl(routingControl);
    }

    // 새 경로 생성
    createRoutingControl(
      L.latLng(userLocation.lat, userLocation.lng),
      L.latLng(destination.lat, destination.lng)
    );
  }

  // 네비게이션 중지
  function stopNavigation() {
    if (routingControl && map) {
      map.removeControl(routingControl);
      routingControl = null;
    }
    if (routeLine && map) {
      map.removeLayer(routeLine);
      routeLine = null;
    }
    currentRoute = null;
    routeHazards = [];
    alternativeRoutes = [];
    isNavigating = false;
    showRouteSelection = false;
    destinationAddress = '';
    destinationCoords = null;
    useSafeRoute = true;
    currentRouteIndex = 0;
  }

  // 이미지 파일 선택
  function handleImageChange(event) {
    const file = event.target.files[0];
    if (file) {
      reportImage = file;

      // 미리보기 생성
      const reader = new FileReader();
      reader.onload = (e) => {
        reportImagePreview = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }

  // 상품 구매
  function purchaseProduct(product) {
    if (userPoints < product.points) {
      alert(`포인트가 부족합니다! 필요: ${product.points}P, 현재: ${userPoints}P`);
      return;
    }

    const confirmed = confirm(
      `${product.name}을(를) ${product.points}P에 구매하시겠습니까?\n\n` +
      `구매 후 남은 포인트: ${userPoints - product.points}P`
    );

    if (confirmed) {
      userPoints -= product.points;
      localStorage.setItem('userPoints', userPoints.toString());

      pointsGainedMessage = `${product.name} 구매 완료! 🎉`;
      showPointsGainModal = true;
      setTimeout(() => {
        showPointsGainModal = false;
        pointsGainedMessage = '';
      }, 3000);

      alert(`${product.name} 구매가 완료되었습니다!\n남은 포인트: ${userPoints}P`);
    }
  }

  // 제보 제출
  async function submitReport() {
    if (!reportImage) {
      alert('사진을 선택해주세요!');
      return;
    }

    if (!reportDescription.trim()) {
      alert('설명을 입력해주세요!');
      return;
    }

    isSubmitting = true;

    try {
      // 1. 이미지를 Supabase Storage에 업로드
      const timestamp = Date.now();
      const fileExt = reportImage.name.split('.').pop();
      const fileName = `${timestamp}.${fileExt}`;
      const filePath = `hazards/${fileName}`;

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('hazard-images')
        .upload(filePath, reportImage);

      if (uploadError) {
        throw uploadError;
      }

      // 2. 공개 URL 가져오기
      const { data: urlData } = supabase.storage
        .from('hazard-images')
        .getPublicUrl(filePath);

      // 3. 데이터베이스에 저장
      const { error: insertError } = await supabase
        .from('hazards')
        .insert([
          {
            type: reportType,
            description: reportDescription,
            lat: userLocation.lat,
            lng: userLocation.lng,
            image_url: urlData.publicUrl
          }
        ]);

      if (insertError) {
        throw insertError;
      }

      // 4. 폼 초기화
      reportType = 'pothole';
      reportDescription = '';
      reportImage = null;
      reportImagePreview = null;
      showReportForm = false;

      alert('제보가 성공적으로 등록되었습니다!');

      // 제보 성공 시 포인트 지급 (로컬 스토리지)
      const pointsAwarded = 10;
      userPoints += pointsAwarded;
      localStorage.setItem('userPoints', userPoints.toString());
      console.log(`${pointsAwarded} 포인트 적립! 현재 포인트: ${userPoints}`);

      // 포인트 획득 모달 표시
      pointsGainedMessage = `${pointsAwarded} 포인트 획득! 🎉`;
      showPointsGainModal = true;
      setTimeout(() => {
        showPointsGainModal = false;
        pointsGainedMessage = '';
      }, 3000); // 3초 후 사라짐

      // 데이터 새로고침
      loadHazards();
    } catch (error) {
      console.error('제보 중 오류 발생:', error);
      alert(`제보 중 오류가 발생했습니다: ${error.message}`);
    } finally {
      isSubmitting = false;
    }
  }

  // 현재 위치로 이동
  function goToCurrentUserLocation() {
    if (map && 'geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          updateUserLocation(lat, lng); // 마커 위치 업데이트
          map.setView([lat, lng], map.getZoom()); // 지도 재중앙화
        },
        (error) => {
          console.error('현재 위치를 가져올 수 없습니다:', error);
          alert('현재 위치를 가져올 수 없습니다. 위치 권한을 확인해주세요.');
        },
        { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }
      );
    } else if (map) {
      alert('이 브라우저는 지리적 위치 기능을 지원하지 않습니다.');
    }
  }

  // 컴포넌트 마운트
  onMount(() => {
    // Leaflet 지도 초기화
    map = L.map('map').setView([userLocation.lat, userLocation.lng], 13);


    // OpenStreetMap 타일 레이어 추가
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      maxZoom: 19
    }).addTo(map);

    // 로컬 스토리지에서 포인트 로드
    const storedPoints = localStorage.getItem('userPoints');
    if (storedPoints) {
      userPoints = parseInt(storedPoints, 10);
    } else {
      userPoints = 0;
      localStorage.setItem('userPoints', '0');
    }

    // 사용자 위치 추적 시작
    if ('geolocation' in navigator) {
      watchId = navigator.geolocation.watchPosition(
        (position) => {
          updateUserLocation(position.coords.latitude, position.coords.longitude);
        },
        (error) => {
          console.error('위치 정보를 가져올 수 없습니다:', error);
        },
        {
          enableHighAccuracy: true,
          maximumAge: 0,
          timeout: 5000
        }
      );
    }

    // 데이터 로드 및 실시간 구독
    loadHazards();
    subscribeToHazards();

    return () => { // onDestroy 대신 onMount에서 반환 함수로 클린업 처리
      if (watchId) {
        navigator.geolocation.clearWatch(watchId);
      }
      if (realtimeChannel) {
        supabase.removeChannel(realtimeChannel);
      }
      if (routingControl && map) {
        map.removeControl(routingControl);
      }
      if (map) {
        map.remove();
      }
    };
  });
</script>

<svelte:head>
  <title>실시간 도로 위험 제보</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@latest/dist/leaflet-routing-machine.css" />
</svelte:head>

<main class="relative w-full h-full">
  <!-- 사용자 포인트 표시 -->
  <div class="fixed top-4 left-4 z-[1000] flex items-center bg-white p-3 rounded-full shadow-lg">
    <span class="text-gray-800 font-semibold">
      내 포인트: <span class="text-blue-600">{userPoints}P</span>
    </span>
  </div>

  <!-- 경고 상태 바 -->
  <div
    class="alert-bar absolute top-0 left-0 right-0 z-[1000] px-4 py-3 text-white text-center font-semibold shadow-lg"
    style="background-color: {isNearHazard ? '#dc2626' : isNavigating && routeHazards.length > 0 ? '#f97316' : '#10b981'};"
  >
    {#if isNearHazard}
      <div class="flex items-center justify-center gap-2">
        <AlertTriangle size={24} />
        <span>⚠️ 주의! 위험 지역 {Math.round(nearestHazardDistance)}m 전방</span>
      </div>
    {:else if isNavigating && routeHazards.length > 0}
      <div class="flex items-center justify-center gap-2">
        <AlertTriangle size={20} />
        <span>⚠️ 경로 상에 {routeHazards.length}개의 위험 지역 존재</span>
      </div>
    {:else if isNavigating}
      <div class="flex items-center justify-center gap-2">
        <Navigation size={20} />
        <span>안전 경로로 안내 중</span>
      </div>
    {:else}
      <div class="flex items-center justify-center gap-2">
        <MapPin size={20} />
        <span>안전 구간입니다</span>
      </div>
    {/if}
  </div>

  <!-- 지도 컨테이너 -->
  <div id="map" class="w-full h-full"></div>

  <!-- 경로 선택 모달 (사용 안 함) -->
  {#if false && showRouteSelection && alternativeRoutes.length > 1}
    <div class="fixed inset-0 bg-black/70 z-[1002] flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-2xl font-bold text-gray-900">🚨 경로 선택</h2>
        </div>

        <p class="text-gray-700 mb-6">
          현재 경로에 <span class="font-bold text-red-600">{alternativeRoutes[0].hazards.length}개의 위험</span>이 있습니다.
          {#if alternativeRoutes.some(r => r.hazards.length < alternativeRoutes[0].hazards.length)}
            <br/>더 안전한 우회 경로를 선택하시겠습니까?
          {/if}
        </p>

        <div class="space-y-3 mb-6">
          {#each alternativeRoutes as altRoute, index}
            <button
              class="w-full p-4 border-2 rounded-xl text-left transition-all hover:shadow-lg"
              class:border-red-500={altRoute.hazards.length > 0}
              class:bg-red-50={altRoute.hazards.length > 0}
              class:border-green-500={altRoute.hazards.length === 0}
              class:bg-green-50={altRoute.hazards.length === 0}
              class:border-blue-500={index === 0}
              on:click={() => setRouteNavigation(index)}
            >
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="font-semibold text-lg mb-1">
                    {index === 0 ? '🔵 메인 경로' : `🔄 대체 경로 ${index}`}
                  </h3>
                  <div class="flex items-center gap-3 text-sm">
                    <span class="text-gray-600">
                      📏 {(altRoute.route.summary.totalDistance / 1000).toFixed(1)}km
                    </span>
                    <span class="text-gray-600">
                      ⏱️ {Math.round(altRoute.route.summary.totalTime / 60)}분
                    </span>
                  </div>
                </div>
                <div class="text-right">
                  {#if altRoute.hazards.length === 0}
                    <span class="text-2xl">✅</span>
                    <p class="text-xs text-green-700 font-medium">안전</p>
                  {:else}
                    <span class="text-2xl">⚠️</span>
                    <p class="text-xs text-red-700 font-medium">{altRoute.hazards.length}개 위험</p>
                  {/if}
                </div>
              </div>
            </button>
          {/each}
        </div>

        <button
          class="w-full py-3 bg-gray-600 hover:bg-gray-700 text-white font-bold rounded-lg"
          on:click={stopNavigation}
        >
          취소
        </button>
      </div>
    </div>
  {/if}

  <!-- 네비게이션 버튼 -->
  <button
    class="fixed top-20 right-4 z-[1000] bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-xl p-4 transition-all active:scale-95"
    on:click={() => showNavigationPanel = !showNavigationPanel}
  >
    <Route size={28} />
  </button>

  <!-- 네비게이션 패널 -->
  {#if showNavigationPanel}
    <div class="fixed top-24 inset-x-4 z-[1000] bg-white rounded-2xl shadow-2xl p-6 sm:max-w-md sm:right-4 sm:left-auto">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-xl font-bold text-gray-900">경로 안내</h3>
        <button
          class="p-1 hover:bg-gray-100 rounded-full"
          on:click={() => showNavigationPanel = false}
        >
          <X size={20} />
        </button>
      </div>

      {#if !isNavigating}
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              목적지 입력
            </label>
            <input
              type="text"
              bind:value={destinationAddress}
              placeholder="예: 서울 강남구 역삼동"
              class="w-full p-3 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none"
              on:keypress={(e) => e.key === 'Enter' && startNavigation()}
            />
          </div>
          <button
            class="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-lg shadow-lg transition-all active:scale-98"
            on:click={startNavigation}
          >
            <div class="flex items-center justify-center gap-2">
              <Navigation size={20} />
              <span>경로 안내 시작</span>
            </div>
          </button>
        </div>
      {:else}
        <div class="space-y-4">
          <div class="bg-blue-50 p-4 rounded-lg">
            <p class="text-sm font-medium text-blue-900 mb-1">
              📍 목적지로 안내 중
            </p>
            <p class="text-sm text-blue-700">
              {destinationAddress}
            </p>
          </div>

          <!-- 경로 전환 토글 -->
          {#if alternativeRoutes.length > 1}
            <div class="bg-white border-2 border-gray-200 rounded-lg p-4">
              <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-2">
                  <span class="text-sm font-semibold text-gray-900">
                    {useSafeRoute ? '🛡️ 안전 경로' : '⚡ 빠른 경로'}
                  </span>
                </div>
                <button
                  class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                  class:bg-green-600={useSafeRoute}
                  class:bg-blue-600={!useSafeRoute}
                  on:click={() => {
                    useSafeRoute = !useSafeRoute;
                    toggleRoute();
                  }}
                >
                  <span
                    class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
                    class:translate-x-6={useSafeRoute}
                    class:translate-x-1={!useSafeRoute}
                  ></span>
                </button>
              </div>
              <div class="text-xs text-gray-600">
                {#if useSafeRoute}
                  {@const safest = alternativeRoutes.reduce((prev, curr) => curr.dangerScore < prev.dangerScore ? curr : prev)}
                  <p>✅ 위험 지역을 우회하는 경로</p>
                  <p class="mt-1">위험: {safest.hazards.length}개 (위험도 {safest.dangerScore}점)</p>
                {:else}
                  <p>⚡ 가장 빠른 경로</p>
                  <p class="mt-1">위험: {alternativeRoutes[0].hazards.length}개 (위험도 {alternativeRoutes[0].dangerScore}점)</p>
                {/if}
              </div>
            </div>
          {/if}

          <!-- AI 분석 중 -->
          {#if isAnalyzingWithAI}
            <div class="bg-purple-50 p-4 rounded-lg border-2 border-purple-200">
              <div class="flex items-center gap-2">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-purple-600"></div>
                <p class="text-sm font-semibold text-purple-900">
                  🤖 Gemini AI가 경로를 분석 중...
                </p>
              </div>
            </div>
          {/if}

          <!-- AI 추천 정보 -->
          {#if aiRecommendation && !isAnalyzingWithAI}
            <div class="bg-purple-50 p-4 rounded-lg border-2 border-purple-200">
              <p class="text-sm font-semibold text-purple-900 mb-2">
                🤖 Gemini AI 추천
              </p>
              <div class="text-xs text-purple-700 space-y-1">
                <p class="font-medium">안전도: {aiRecommendation.safetyScore}/100점</p>
                <p>{aiRecommendation.reason}</p>
                {#if aiRecommendation.warning}
                  <p class="text-orange-700 font-medium mt-2">⚠️ {aiRecommendation.warning}</p>
                {/if}
              </div>
            </div>
          {/if}

          {#if routeHazards.length > 0}
            <div class="bg-orange-50 p-4 rounded-lg">
              <p class="text-sm font-semibold text-orange-900 mb-2">
                ⚠️ 경로 상 위험 지역 ({routeHazards.length}개)
              </p>
              <div class="space-y-2 max-h-32 overflow-y-auto">
                {#each routeHazards as hazard}
                  <div class="text-xs text-orange-700">
                    • {hazardTypes.find(t => t.value === hazard.type)?.label || '기타'}:
                    경로로부터 {hazard.distanceFromRoute}m
                  </div>
                {/each}
              </div>
            </div>
          {/if}

          <button
            class="w-full py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg shadow-lg transition-all active:scale-98"
            on:click={stopNavigation}
          >
            안내 종료
          </button>
        </div>
      {/if}
    </div>
  {/if}

  <!-- 제보 버튼 -->
  {#if !showReportForm}
    <!-- 현재 위치 버튼 -->
    <button
      class="fixed bottom-24 right-8 z-[1000] bg-gray-700 hover:bg-gray-800 text-white rounded-full shadow-2xl p-4 flex items-center justify-center transition-all active:scale-95"
      on:click={goToCurrentUserLocation}
    >
      <MapPin size={28} />
    </button>

    <!-- 상품 거래 버튼 -->
    <button
      class="fixed bottom-8 left-8 z-[1000] bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-2xl p-6 flex items-center gap-3 transition-all active:scale-95"
      on:click={() => showShopModal = true}
    >
      <ShoppingBag size={32} />
      <span class="text-xl font-bold">상품 거래</span>
    </button>

    <button
      class="fixed bottom-8 right-8 z-[1000] bg-red-600 hover:bg-red-700 text-white rounded-full shadow-2xl p-6 flex items-center gap-3 transition-all active:scale-95"
      on:click={() => showReportForm = true}
    >
      <Camera size={32} />
      <span class="text-xl font-bold">위험 제보하기</span>
    </button>
  {/if}

  <!-- 제보 폼 모달 -->
  {#if showReportForm}
    <div class="fixed inset-0 bg-black/50 z-[1001] flex items-end sm:items-center justify-center">
      <div class="bg-white w-full sm:max-w-lg sm:rounded-t-2xl rounded-t-2xl shadow-2xl max-h-[90vh] overflow-y-auto">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b px-6 py-4 flex items-center justify-between">
          <h2 class="text-2xl font-bold text-gray-900">위험 제보하기</h2>
          <button
            class="p-2 hover:bg-gray-100 rounded-full transition-colors"
            on:click={() => {
              showReportForm = false;
              reportImage = null;
              reportImagePreview = null;
              reportDescription = '';
            }}
          >
            <X size={24} />
          </button>
        </div>

        <!-- 폼 내용 -->
        <div class="p-6 space-y-6">
          <!-- 위험 유형 선택 -->
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">
              위험 유형
            </label>
            <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {#each hazardTypes as type}
                <button
                  class="p-4 border-2 rounded-lg font-medium transition-all"
                  class:border-gray-300={reportType !== type.value}
                  class:bg-white={reportType !== type.value}
                  class:text-gray-700={reportType !== type.value}
                  style={reportType === type.value ? `border-color: ${type.color}; background-color: ${type.color}20; color: ${type.color};` : ''}
                  on:click={() => reportType = type.value}
                >
                  {type.label}
                </button>
              {/each}
            </div>
          </div>

          <!-- 사진 업로드 -->
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">
              사진 첨부 *
            </label>

            {#if reportImagePreview}
              <div class="relative">
                <img
                  src={reportImagePreview}
                  alt="미리보기"
                  class="w-full h-64 object-cover rounded-lg border-2 border-gray-300"
                />
                <button
                  class="absolute top-2 right-2 bg-red-600 text-white p-2 rounded-full shadow-lg hover:bg-red-700"
                  on:click={() => {
                    reportImage = null;
                    reportImagePreview = null;
                  }}
                >
                  <X size={20} />
                </button>
              </div>
            {:else}
              <label class="flex flex-col items-center justify-center w-full h-64 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50 transition-colors">
                <Camera size={48} class="text-gray-400 mb-3" />
                <span class="text-lg font-medium text-gray-600">사진 선택</span>
                <input
                  type="file"
                  accept="image/*"
                  capture="environment"
                  class="hidden"
                  on:change={handleImageChange}
                />
              </label>
            {/if}
          </div>

          <!-- 설명 입력 -->
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">
              상세 설명 *
            </label>
            <textarea
              bind:value={reportDescription}
              placeholder="위험 요소에 대해 자세히 설명해주세요..."
              class="w-full p-4 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none resize-none"
              rows="4"
            ></textarea>
          </div>

          <!-- 위치 정보 -->
          <div class="bg-blue-50 p-4 rounded-lg">
            <p class="text-sm font-medium text-blue-900 mb-1">
              📍 현재 위치
            </p>
            <p class="text-sm text-blue-700">
              위도: {userLocation.lat.toFixed(6)}, 경도: {userLocation.lng.toFixed(6)}
            </p>
          </div>

          <!-- 제출 버튼 -->
          <button
            class="w-full py-4 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg shadow-lg transition-all active:scale-98 disabled:opacity-50 disabled:cursor-not-allowed"
            on:click={submitReport}
            disabled={isSubmitting || !reportImage || !reportDescription.trim()}
          >
            {#if isSubmitting}
              제보 중...
            {:else}
              제보 완료
            {/if}
          </button>
        </div>
      </div>
    </div>
  {/if}

  <!-- 상품 거래 모달 -->
  {#if showShopModal}
    <div class="fixed inset-0 bg-black/50 z-[1001] flex items-end sm:items-center justify-center">
      <div class="bg-white w-full sm:max-w-4xl sm:rounded-t-2xl rounded-t-2xl shadow-2xl max-h-[90vh] overflow-y-auto">
        <!-- 헤더 -->
        <div class="sticky top-0 bg-white border-b px-6 py-4 flex items-center justify-between">
          <div>
            <h2 class="text-2xl font-bold text-gray-900">상품 거래소</h2>
            <p class="text-sm text-gray-600 mt-1">
              내 포인트: <span class="text-blue-600 font-bold text-lg">{userPoints}P</span>
            </p>
          </div>
          <button
            class="p-2 hover:bg-gray-100 rounded-full transition-colors"
            on:click={() => showShopModal = false}
          >
            <X size={24} />
          </button>
        </div>

        <!-- 상품 목록 -->
        <div class="p-6">
          <div class="mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">🍕 음식 쿠폰</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {#each shopProducts.filter(p => p.category === 'food') as product}
                <div class="bg-white border-2 border-gray-200 rounded-xl overflow-hidden hover:border-blue-400 transition-all hover:shadow-lg">
                  <img
                    src={product.image}
                    alt={product.name}
                    class="w-full h-48 object-cover"
                  />
                  <div class="p-4">
                    <h4 class="font-bold text-lg text-gray-900 mb-1">{product.name}</h4>
                    <p class="text-sm text-gray-600 mb-3">{product.description}</p>
                    <div class="flex items-center justify-between">
                      <span class="text-xl font-bold text-blue-600">{product.points}P</span>
                      <button
                        class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                        disabled={userPoints < product.points}
                        on:click={() => purchaseProduct(product)}
                      >
                        {userPoints < product.points ? '포인트 부족' : '구매하기'}
                      </button>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          <div>
            <h3 class="text-lg font-semibold text-gray-900 mb-4">🎁 상품권</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {#each shopProducts.filter(p => p.category === 'giftcard') as product}
                <div class="bg-white border-2 border-gray-200 rounded-xl overflow-hidden hover:border-blue-400 transition-all hover:shadow-lg">
                  <img
                    src={product.image}
                    alt={product.name}
                    class="w-full h-48 object-cover"
                  />
                  <div class="p-4">
                    <h4 class="font-bold text-lg text-gray-900 mb-1">{product.name}</h4>
                    <p class="text-sm text-gray-600 mb-3">{product.description}</p>
                    <div class="flex items-center justify-between">
                      <span class="text-xl font-bold text-blue-600">{product.points}P</span>
                      <button
                        class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                        disabled={userPoints < product.points}
                        on:click={() => purchaseProduct(product)}
                      >
                        {userPoints < product.points ? '포인트 부족' : '구매하기'}
                      </button>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          <!-- 포인트 안내 -->
          <div class="mt-6 bg-blue-50 p-4 rounded-lg border border-blue-200">
            <p class="text-sm text-blue-900">
              💡 <strong>포인트 적립 방법:</strong> 도로 위험을 제보하면 10P를 획득할 수 있습니다!
            </p>
          </div>
        </div>
      </div>
    </div>
  {/if}

  <!-- 포인트 획득 모달 -->
  {#if showPointsGainModal}
    <div class="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-[1002] bg-green-500 text-white px-8 py-5 rounded-lg shadow-xl text-3xl font-bold animate-fade-in-out">
      {pointsGainedMessage}
    </div>
  {/if}
</main>

<style>
  :global(.custom-hazard-marker) {
    background: transparent;
    border: none;
  }

  :global(.custom-marker) {
    background: transparent;
    border: none;
  }

  :global(.leaflet-routing-container) {
    display: none;
  }

  /* Custom animation for point gain modal */
  @keyframes fade-in-out {
    0% {
      opacity: 0;
      transform: translate(-50%, -30%); /* Slightly off-center initially */
    }
    10% {
      opacity: 1;
      transform: translate(-50%, -50%); /* Centered */
    }
    90% {
      opacity: 1;
      transform: translate(-50%, -50%); /* Centered */
    }
    100% {
      opacity: 0;
      transform: translate(-50%, -70%); /* Fades out slightly upwards */
    }
  }

  .animate-fade-in-out {
    animation: fade-in-out 3s ease-in-out forwards;
  }
</style>
