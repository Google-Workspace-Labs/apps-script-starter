# Projects

이 폴더에 Apps Script 프로젝트들이 생성됩니다.

---

## 🚀 새 프로젝트 생성

### 1. 디렉토리 생성

```bash
mkdir projects/my-app
cd projects/my-app
```

### 2. Apps Script 프로젝트 생성

```bash
# 독립 실행형 프로젝트
clasp create-script --type standalone --title "My App"

# 타입 옵션:
#   standalone - 독립 실행형 (기본)
#   sheets     - Google Sheets 바인딩
#   docs       - Google Docs 바인딩
#   slides     - Google Slides 바인딩
#   forms      - Google Forms 바인딩
```

### 3. TimeZone 수정 (필수!)

```bash
# appsscript.json 파일 열기
vim appsscript.json

# "America/New_York" → "Asia/Seoul" 변경
```

**clasp create는 항상 America/New_York으로 생성됩니다!**

### 4. 코드 작성

```bash
# JavaScript 파일 생성 (파일명 자유)
vim Code.js

# Web App의 경우 HTML 파일 추가 (선택)
vim index.html
```

### 5. 배포

```bash
# GAS 서버로 업로드
clasp push

# 에디터에서 확인
clasp open-script
```

---

## 📁 프로젝트 구조

```
projects/my-app/
├── Code.js          # JavaScript 코드 (파일명 자유)
├── index.html       # Web App HTML (선택)
├── appsscript.json  # Apps Script 설정 (TimeZone, 라이브러리 등)
└── .clasp.json      # Script ID (Git 포함 필수)
```

**중요:**
- ❌ `package.json` 없음 (개별 프로젝트에 불필요)
- ❌ `node_modules/` 없음 (npm 패키지 사용 불가)
- ✅ clasp 명령어 직접 사용
- ✅ 루트의 ESLint, Prettier 자동 적용

---

## 🔧 개발 워크플로우

```bash
# 1. 코드 수정
vim Code.js

# 2. Git 커밋 (GAS 업로드 전에 버전 관리 먼저)
git add .
git commit -m "feat: Add new feature"

# 3. GAS 서버에 업로드
clasp push

# 4. 에디터에서 테스트
clasp open-script

# 5. Web App 배포 (Web App인 경우에만, 최초 1회는 GUI 필수)
clasp deploy --deploymentId $(cat .deploymentId) -d "Update v2"
```

**권장 순서:** Git 커밋 → clasp push (업로드) → clasp deploy (Web App 배포)

---

## ⚠️ 주의사항

### npm install 금지

**개별 프로젝트에서 `npm install` 실행하지 마세요!**

```bash
# ❌ 절대 하지 마세요
cd projects/my-app
npm install

# ✅ 루트에서만
cd ../../
npm install
```

**이유:**
- Apps Script는 npm 패키지를 런타임에 사용할 수 없음
- clasp은 루트 node_modules에서 공유
- npm workspaces로 의존성 통합 관리

### package.json 생성 금지

개별 프로젝트에 `package.json`을 만들지 마세요. 불필요합니다.

```bash
# ❌ 하지 마세요
npm init
```

---

## 📚 문서

새 프로젝트를 만들기 전에 이 문서들을 읽어보세요:

- **[CLASP_GIT_WORKFLOW.md](../docs/CLASP_GIT_WORKFLOW.md)** - clasp + Git 워크플로우 (필독!)
- **[CLASP_COMMANDS.md](../docs/CLASP_COMMANDS.md)** - clasp 명령어 완전 가이드
- **[JAVASCRIPT_GUIDE.md](../docs/JAVASCRIPT_GUIDE.md)** - JavaScript 코딩 가이드
- **[HTML_GUIDE.md](../docs/HTML_GUIDE.md)** - HTML/CSS 코딩 가이드

---

## 💡 팁

### apps-script-library 사용

공통 유틸리티가 필요하면 apps-script-library를 추가하세요.

```json
// appsscript.json
{
  "dependencies": {
    "libraries": [{
      "userSymbol": "WorkspaceCore",
      "libraryId": "1II0VGB7VY1_tNxLbNfoxp3ApVIqq7Am99LevLMMgX4LlgMI5vQCj4l4V",
      "version": "2",
      "developmentMode": false
    }]
  }
}
```

```javascript
// Code.js에서 사용
const today = WorkspaceCore.formatKoreanDate(new Date());
console.log(today); // "2026-01-26"
```

**developmentMode 옵션:**
- `false` (권장) - 지정한 버전에 고정, 안정적
- `true` (개발용) - 최신 코드 사용, 라이브러리 개발 시에만 사용

대부분의 경우 `false`를 사용하세요.

### 외부 API 사용

npm 패키지 대신 Apps Script API를 사용하세요:

```javascript
// UrlFetchApp으로 HTTP 요청
const response = UrlFetchApp.fetch('https://api.example.com/data', {
  method: 'GET',
  headers: { 'Authorization': 'Bearer ' + apiKey }
});

// Utilities로 날짜/문자열 처리
const formatted = Utilities.formatDate(new Date(), 'Asia/Seoul', 'yyyy-MM-dd');
```

---

**작성일**: 2026-01-26
