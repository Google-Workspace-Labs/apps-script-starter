# JavaScript 코딩 가이드 (Apps Script)

Apps Script 프로젝트에서 권장하는 JavaScript 코딩 스타일입니다.

**기반:** [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html)

---

## 📚 목차

1. [변수 선언](#1-변수-선언)
2. [로깅](#2-로깅)
3. [함수 선언](#3-함수-선언)
4. [문자열](#4-문자열)
5. [객체와 배열](#5-객체와-배열)
6. [에러 핸들링](#6-에러-핸들링)
7. [비동기 처리](#7-비동기-처리)
8. [주석](#8-주석)
9. [네이밍 규칙](#9-네이밍-규칙)
10. [Apps Script 특수 사항](#10-apps-script-특수-사항)

---

## 1. 변수 선언

### ✅ 권장

```javascript
// const를 기본으로 사용 (재할당 없는 경우)
const API_KEY = 'your-api-key';
const sheet = SpreadsheetApp.getActiveSheet();
const data = sheet.getDataRange().getValues();

// 재할당이 필요한 경우만 let 사용
let counter = 0;
for (let i = 0; i < data.length; i++) {
  counter += data[i][0];
}
```

### ❌ 금지

```javascript
// var는 절대 사용하지 마세요
var sheet = SpreadsheetApp.getActiveSheet();  // ❌
var counter = 0;  // ❌
```

### 왜 var를 금지하나?

- **함수 스코프 문제**: 블록 스코프가 아닌 함수 스코프
- **호이스팅 혼란**: 선언 전에 사용 가능해 버그 유발
- **Google 공식 권장**: "The var keyword must not be used."

> **"Use `const` by default, unless a variable needs to be reassigned."**

---

## 2. 로깅

### ✅ 권장: console.log

```javascript
function processData() {
  console.log('Processing started...');

  try {
    const result = calculateTotal();
    console.log('Total:', result);
  } catch (error) {
    console.error('Error occurred:', error.message);
  }
}

// 성능 측정
function performanceTest() {
  console.time('data-processing');
  // ... 작업 수행
  console.timeEnd('data-processing');  // "data-processing: 1234ms"
}

// 로그 레벨 구분
console.log('일반 정보');
console.info('참고 정보');
console.warn('경고 메시지');
console.error('에러 발생!');
```

### ⚠️ 레거시: Logger.log

```javascript
// Logger.log는 레거시 API
Logger.log('Processing...');  // ⚠️ 구식
```

### console.log vs Logger.log

| 항목 | console.log | Logger.log |
|------|------------|-----------|
| **도입** | V8 런타임 (2019~) | 초기부터 |
| **로그 레벨** | ✅ log, info, warn, error | ❌ log만 |
| **성능 측정** | ✅ time(), timeEnd() | ❌ 없음 |
| **표준성** | ✅ 표준 JavaScript | ⚠️ GAS 전용 |

### 언제 Logger.log를 쓸까?

```javascript
// Cloud Logging에 구조화된 JSON 데이터 전송
function logStructuredData() {
  Logger.log(JSON.stringify({
    event: 'user_signup',
    userId: 12345,
    timestamp: new Date(),
    metadata: { source: 'web' }
  }));
}
```

---

## 3. 함수 선언

### ✅ 권장

```javascript
// Arrow function (콜백, 간단한 함수)
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const users = data.filter(user => user.active);

// 일반 함수 (Apps Script 진입점, 복잡한 로직)
function doGet(e) {
  return HtmlService.createHtmlOutputFromFile('index');
}

function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Custom Menu')
    .addItem('Run Script', 'myFunction')
    .addToUi();
}
```

### ❌ 금지

```javascript
// 불필요한 function 키워드
const doubled = numbers.map(function(n) {  // ❌
  return n * 2;
});

// var + function 조합
var myFunc = function() {  // ❌
  // ...
};
```

---

## 4. 문자열

### ✅ 권장: Template Literals

```javascript
const name = 'John';
const age = 30;
const message = `User ${name} is ${age} years old`;

// 멀티라인
const html = `
  <div>
    <h1>Hello, ${name}</h1>
    <p>Welcome to our app</p>
  </div>
`;
```

### ❌ 금지: 문자열 연결

```javascript
const message = 'User ' + name + ' is ' + age + ' years old';  // ❌

const html = '<div>' +  // ❌
  '<h1>Hello, ' + name + '</h1>' +
  '</div>';
```

---

## 5. 객체와 배열

### ✅ 권장

```javascript
// Destructuring
const { firstName, lastName } = user;
const [first, second, ...rest] = items;

// Spread operator
const newUser = { ...user, active: true };
const combined = [...array1, ...array2];

// Property shorthand
const name = 'John';
const age = 30;
const user = { name, age };  // { name: name, age: age }
```

### ❌ 금지

```javascript
// 전통적인 방식
const firstName = user.firstName;  // ❌ (destructuring 가능할 때)
const lastName = user.lastName;

const newUser = Object.assign({}, user, { active: true });  // ❌
```

---

## 6. 에러 핸들링

### ✅ 권장

```javascript
function processUserData(userId) {
  try {
    const user = fetchUser(userId);

    if (!user) {
      throw new Error(`User not found: ${userId}`);
    }

    return processUser(user);

  } catch (error) {
    console.error('Error processing user:', error.message);
    console.error('Stack trace:', error.stack);

    // 선택: WorkspaceCore 라이브러리 사용
    // WorkspaceCore.logError(error, { userId });

    throw error;  // 재throw 필요 시
  }
}
```

### ❌ 금지

```javascript
function processUserData(userId) {
  try {
    // ...
  } catch (e) {
    Logger.log(e);  // ❌ 에러 정보 부족
    // 에러를 무시하거나 처리 없이 삼킴
  }
}
```

---

## 7. 비동기 처리

Apps Script는 동기적이지만, `UrlFetchApp` 등 외부 API 호출 시 유용합니다.

### ✅ 권장: 병렬 처리

```javascript
function fetchMultipleApis() {
  const urls = [
    'https://api1.example.com/data',
    'https://api2.example.com/data',
    'https://api3.example.com/data'
  ];

  // UrlFetchApp.fetchAll()로 병렬 요청
  const requests = urls.map(url => ({ url }));
  const responses = UrlFetchApp.fetchAll(requests);

  return responses.map(response => JSON.parse(response.getContentText()));
}
```

### ❌ 금지: 순차 처리

```javascript
function fetchMultipleApis() {
  const results = [];
  results.push(UrlFetchApp.fetch(url1));  // ❌ 느림
  results.push(UrlFetchApp.fetch(url2));
  results.push(UrlFetchApp.fetch(url3));
  return results;
}
```

---

## 8. 주석

### ✅ 권장: JSDoc

```javascript
/**
 * 사용자의 총 점수를 계산합니다.
 *
 * @param {string} userId - 사용자 ID
 * @param {Date} startDate - 계산 시작일
 * @param {Date} endDate - 계산 종료일
 * @return {number} 총 점수
 */
function calculateUserScore(userId, startDate, endDate) {
  // 날짜 범위 검증
  if (startDate >= endDate) {
    throw new Error('Invalid date range');
  }

  const activities = fetchUserActivities(userId, startDate, endDate);

  // 활동별 점수 합산 (활동 타입에 따라 가중치 적용)
  return activities.reduce((total, activity) => {
    const weight = ACTIVITY_WEIGHTS[activity.type] || 1;
    return total + (activity.score * weight);
  }, 0);
}
```

### ❌ 금지: 불필요한 주석

```javascript
// 명백한 주석
const total = a + b;  // ❌ a와 b를 더함

// 코드로 설명 가능한 것
// user의 active 상태 확인  // ❌
if (user.status === 'active') {
  // ...
}

// 대신 함수로 분리
if (isUserActive(user)) {  // ✅
  // ...
}
```

---

## 9. 네이밍 규칙

### ✅ 권장

```javascript
// 상수: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// 변수/함수: camelCase
const userName = 'John';
function getUserById(id) { }

// 클래스: PascalCase
class UserManager {
  constructor() { }
}

// Private 멤버: _ 접두사
const _internalCache = {};
function _privateHelper() { }

// Boolean: is/has/can 접두사
const isActive = true;
const hasPermission = user.checkPermission();
const canEdit = user.role === 'admin';

// 파일명: 소문자, kebab-case 또는 camelCase
// utils.js, config.js (권장)
// user-manager.js, api-client.js (권장)
```

**파일명 규칙:**
- ✅ 소문자 시작: `config.js`, `utils.js`, `helper.js`
- ✅ kebab-case: `user-manager.js`, `api-client.js`
- ⚠️ 예외: `Code.js` (Apps Script 메인 파일 관례)
- ❌ PascalCase: `Config.js`, `Utils.js` (클래스 파일이 아니라면 지양)

**이유:**
1. JavaScript 생태계 표준 관례
2. 대부분의 npm 패키지/프로젝트가 소문자 사용
3. `Code.js`는 Apps Script의 특수 케이스로 예외 허용

**미사용 변수 규칙:**

의도적으로 사용하지 않는 변수는 `_`로 시작하세요:

```javascript
// ✅ 권장: 미사용 변수는 _로 시작
const _unusedPassword = 'not-needed';
const { name, _id, _token } = apiResponse;  // id와 token은 사용 안 함

// 파라미터에도 적용
function handleEvent(event, _metadata) {  // metadata는 사용 안 함
  console.log(event.type);
}

// 구조 분해 할당에서도 활용
const [first, _second, third] = arr;  // second는 무시
```

**이유:**
1. 코드 리뷰 시 의도가 명확함 (실수가 아니라 의도적으로 안 씀)
2. ESLint `no-unused-vars` 규칙 예외 (현재는 off지만 향후 대비)
3. 다른 개발자가 보기에 혼란 방지

### ❌ 금지

```javascript
// 헝가리안 표기법
const strUserName = 'John';  // ❌
const arrData = [1, 2, 3];  // ❌

// 의미 없는 이름
const a = getUserData();  // ❌
function fn() { }  // ❌
const temp = calculateTotal();  // ❌

// 약어 남용
const usrMgr = new UserManager();  // ❌
```

---

## 10. Apps Script 특수 사항

### 전역 객체 사용

```javascript
// 전역 객체는 const로 재할당하지 마세요
const sheet = SpreadsheetApp.getActiveSheet();  // ✅
SpreadsheetApp = null;  // ❌ readonly 전역 변수

// 자주 사용하는 객체는 로컬 변수에 저장
function processSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();  // ✅
  const sheet = ss.getSheetByName('Data');

  // SpreadsheetApp.getActiveSpreadsheet() 반복 호출 피하기
}
```

---

### Simple Triggers (진입점 함수)

```javascript
// 이 함수들은 반드시 전역 함수 선언이어야 함
function doGet(e) { }      // Web App GET
function doPost(e) { }     // Web App POST
function onOpen(e) { }     // Spreadsheet 열 때
function onEdit(e) { }     // Spreadsheet 편집 시
function onInstall(e) { }  // Add-on 설치 시

// ❌ const/let로 선언하면 Apps Script가 인식 못 함
const doGet = (e) => { };  // ❌
```

**ESLint 자동 제외:**
이 함수들은 `eslint.config.js`에서 자동으로 "unused" 경고 제외됩니다.

---

### ⚠️ TimeZone 설정 (중요!)

**문제:** `clasp create`는 기본값이 `"America/New_York"`

**영향:**
- 날짜/시간 함수 14시간 차이
- 시간 트리거 실행 시간 오차
- `Utilities.formatDate()`, `new Date()` 결과 차이

**해결:**

```json
// appsscript.json
{
  "timeZone": "Asia/Seoul",  // ✅ 한국 시간
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER"
}
```

**워크플로우:**

```bash
# 1. 프로젝트 생성
clasp create-script --type standalone --title "My App"

# 2. ⚠️ TimeZone 확인 및 수정!
cat appsscript.json
# "timeZone": "America/New_York" → "Asia/Seoul"

# 3. 변경사항 적용
clasp push
```

**확인:**

```javascript
function checkTimeZone() {
  const tz = Session.getScriptTimeZone();
  console.log('Current TimeZone:', tz);  // "Asia/Seoul"

  const now = new Date();
  console.log('Formatted:', Utilities.formatDate(now, tz, 'yyyy-MM-dd HH:mm:ss'));
}
```

---

### ⚠️ 프로젝트 생성 및 삭제

#### Container-bound Scripts

**타입:** `--type sheets`, `--type forms`, `--type docs`, `--type slides`

**특징:**
- `.clasp.json`에 `parentId` 필드 있음
- 컨테이너(Sheet/Form)에 포함됨

**삭제:**
```bash
# ✅ parentId로 삭제 (컨테이너 + Script 모두 삭제)
clasp delete <parentId>

# ❌ scriptId로는 권한 없음
```

---

#### Standalone Scripts

**타입:** `--type standalone` (기본값)

**특징:**
- `.clasp.json`에 `parentId` 없음
- Google Drive에 독립적으로 존재

**삭제:**
```bash
# ❌ scriptId로 삭제 불가
clasp delete <scriptId>

# ✅ GAS 에디터에서 수동 삭제
clasp open-script
# → 좌측 메뉴 > Overview > Delete project
```

---

### 프로젝트 이름 자동 설정

```bash
# --title 없이 생성하면 폴더명이 프로젝트명이 됨
mkdir projects/customer-survey
cd projects/customer-survey
clasp create-script --type forms

# 결과: "customer-survey"라는 이름으로 생성
```

---

## ✅ 체크리스트

### 프로젝트 생성 시:
- [ ] 의미 있는 폴더명 사용
- [ ] TimeZone → `Asia/Seoul` 변경
- [ ] `.clasp.json` 확인 (parentId 여부 파악)

### 코드 작성 시:
- [ ] `var` 대신 `const`/`let` 사용
- [ ] `Logger.log` 대신 `console.log` 사용
- [ ] Template literals (백틱) 사용
- [ ] Arrow function 적극 활용
- [ ] Destructuring과 spread operator 사용
- [ ] 의미 있는 변수명
- [ ] 에러 핸들링 추가
- [ ] JSDoc 주석 (공개 함수)

### 프로젝트 삭제 시:
- [ ] `.clasp.json`에서 `parentId` 확인
- [ ] Container-bound: `clasp delete <parentId>`
- [ ] Standalone: GAS 에디터에서 수동 삭제
- [ ] 데이터 백업 확인 (Container-bound)

---

## 📚 참고 문서

### 공식 가이드:
- [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html)
- [Apps Script V8 Runtime](https://developers.google.com/apps-script/guides/v8-runtime)
- [Apps Script Logging](https://developers.google.com/apps-script/guides/logging)
- [Apps Script Best Practices](https://developers.google.com/apps-script/guides/support/best-practices)

### 커뮤니티:
- [Andrew Roberts - Best Practices](https://www.andrewroberts.net/google-apps-script/google-apps-script-development-best-practices/)
- [Ben Collins - V8 Runtime](https://www.benlcollins.com/apps-script/apps-script-v8-runtime/)

### 프로젝트 내 문서:
- **[CLASP_COMMANDS.md](./CLASP_COMMANDS.md)** - clasp 명령어
- **[CLASP_GIT_WORKFLOW.md](./CLASP_GIT_WORKFLOW.md)** - clasp + Git 워크플로우
- **[HTML_GUIDE.md](./HTML_GUIDE.md)** - HTML/CSS 가이드

---

**작성일**: 2026-01-26
