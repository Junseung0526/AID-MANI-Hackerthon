<script>
  import { onMount, onDestroy } from 'svelte';
  import L from 'leaflet';
  import { supabase } from './lib/supabase';
  import { AlertTriangle, Camera, X, MapPin } from 'lucide-svelte';

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

  // 폼 데이터
  let reportType = 'pothole';
  let reportDescription = '';
  let reportImage = null;
  let reportImagePreview = null;
  let isSubmitting = false;

  const hazardTypes = [
    { value: 'pothole', label: '포트홀', color: '#ef4444' },
    { value: 'rockfall', label: '낙석', color: '#f97316' },
    { value: 'ice', label: '결빙', color: '#3b82f6' },
    { value: 'flood', label: '침수', color: '#06b6d4' },
    { value: 'accident', label: '사고', color: '#dc2626' },
    { value: 'other', label: '기타', color: '#8b5cf6' }
  ];

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
      map.setView([lat, lng], map.getZoom());

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
          loadHazards(); // 변경사항이 있으면 다시 로드
        }
      )
      .subscribe();
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

      // 데이터 새로고침
      loadHazards();
    } catch (error) {
      console.error('제보 중 오류 발생:', error);
      alert(`제보 중 오류가 발생했습니다: ${error.message}`);
    } finally {
      isSubmitting = false;
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
  });

  // 컴포넌트 언마운트
  onDestroy(() => {
    if (watchId) {
      navigator.geolocation.clearWatch(watchId);
    }
    if (realtimeChannel) {
      supabase.removeChannel(realtimeChannel);
    }
    if (map) {
      map.remove();
    }
  });
</script>

<svelte:head>
  <title>실시간 도로 위험 제보</title>
</svelte:head>

<main class="relative w-full h-full">
  <!-- 경고 상태 바 -->
  <div
    class="alert-bar absolute top-0 left-0 right-0 z-[1000] px-4 py-3 text-white text-center font-semibold shadow-lg"
    style="background-color: {isNearHazard ? '#dc2626' : '#10b981'};"
  >
    {#if isNearHazard}
      <div class="flex items-center justify-center gap-2">
        <AlertTriangle size={24} />
        <span>⚠️ 주의! 위험 지역 {Math.round(nearestHazardDistance)}m 전방</span>
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

  <!-- 제보 버튼 -->
  {#if !showReportForm}
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
            <div class="grid grid-cols-2 gap-3">
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
</main>

<style>
  :global(.custom-hazard-marker) {
    background: transparent;
    border: none;
  }
</style>
