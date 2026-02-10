import { GoogleGenerativeAI } from '@google/generative-ai';

// Gemini API 초기화
const genAI = new GoogleGenerativeAI(import.meta.env.VITE_GEMINI_API_KEY);

// Gemini 모델 (Gemini 1.5 Flash - 빠르고 무료)
const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

/**
 * Gemini AI에게 경로를 분석하고 추천받기
 * @param {Array} routes - 경로 목록 (각 경로에는 hazards, dangerScore, distance, time 포함)
 * @param {Array} hazardTypes - 위험 유형 정보 (severity 포함)
 * @returns {Promise} - AI 추천 결과
 */
export async function analyzeRoutesWithAI(routes, hazardTypes) {
  try {
    // 위험 유형별 정보를 텍스트로 변환
    const hazardTypesInfo = hazardTypes.map(t =>
      `- ${t.label} (${t.value}): 심각도 ${t.severity}점 / 10점`
    ).join('\n');

    const prompt = `
당신은 도로 안전 전문가입니다. 아래 경로들을 분석하고 가장 안전한 경로를 추천해주세요.

# 위험 유형별 심각도
${hazardTypesInfo}

# 경로 정보
${routes.map((route, index) => `
## 경로 ${index + 1}
- 거리: ${(route.route.summary.totalDistance / 1000).toFixed(1)}km
- 예상 시간: ${Math.round(route.route.summary.totalTime / 60)}분
- 위험 지역 개수: ${route.hazards.length}개
- 총 위험도 점수: ${route.dangerScore}점
- 위험 상세:
${route.hazards.length > 0 ? route.hazards.map(h => {
  const typeInfo = hazardTypes.find(t => t.value === h.type);
  return `  * ${typeInfo?.label || h.type} (심각도 ${typeInfo?.severity || 1}점, 경로로부터 ${h.distanceFromRoute}m): ${h.description}`;
}).join('\n') : '  위험 없음'}
`).join('\n')}

# 판단 기준
1. **안전성 (절대 최우선)**:
   - **위험이 없는 경로가 있다면 무조건 그 경로를 최우선으로 추천.** (다른 경로보다 최대 10% 더 멀거나 15분 더 소요되더라도 위험이 없는 경로를 선택해야 함)
   - 위험 지역의 개수와 각 위험의 심각도를 종합적으로 고려.
   - 심각도 10점(사고)과 5점(낙석, 침수)은 특히 위험하며, 단 하나의 존재만으로도 해당 경로의 우선순위를 크게 낮춰야 함.
   - 경로로부터의 거리도 고려 (가까울수록 위험도가 급증).
2. **시간 효율성**: 너무 큰 우회가 아닌지 확인
3. **거리**: 비슷한 안전도라면 짧은 경로 선호

# 분석 방법
- 각 경로의 위험도 점수(dangerScore)는 경로 상 모든 위험의 심각도 합계입니다
- 위험도가 낮을수록 안전합니다
- 위험이 전혀 없는 경로가 최선이지만, 모든 경로에 위험이 있다면 가장 덜 위험한 경로를 선택하세요
- 시간이 2배 이상 차이나면 경고를 포함하세요

# 응답 형식 (JSON)
{
  "recommendedRoute": 추천 경로 번호 (0부터 시작),
  "reason": "추천 이유 (2-3문장, 한글, 구체적인 위험 정보 포함)",
  "safetyScore": 추천 경로의 안전도 점수 (0-100, 위험이 없으면 100점, 위험이 많으면 낮은 점수),
  "warning": "주의사항 (있으면 작성, 없으면 빈 문자열)"
}

JSON만 응답하세요.
`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // JSON 파싱
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }

    throw new Error('AI 응답 파싱 실패');
  } catch (error) {
    console.error('Gemini AI 오류:', error);
    // 기본값 반환 - 가장 안전한 경로(위험도가 가장 낮은 경로) 선택
    const safestRouteIndex = routes.reduce((minIndex, route, index) =>
      route.dangerScore < routes[minIndex].dangerScore ? index : minIndex
    , 0);

    return {
      recommendedRoute: safestRouteIndex,
      reason: 'AI 분석 실패로 위험도가 가장 낮은 경로를 선택했습니다.',
      safetyScore: 50,
      warning: 'AI 분석에 실패했습니다. 수동으로 경로를 확인해주세요.'
    };
  }
}
