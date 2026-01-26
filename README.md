# Apps Script Projects

Google Apps Script 프로젝트 개발 및 경험 축적 공간 (Monorepo)

---

## ⚡ 빠른 시작

```bash
# 1. 초기화
git clone <your-repo-url>
cd apps-script-projects
npm install
clasp login  # clasp 인증 (최초 1회)
```

> **Note:** `npm install` 실행 시 `prepare` 스크립트가 자동으로 Husky Git hooks를 설정합니다.

```bash
# 2. 새 프로젝트 생성
mkdir projects/my-app
cd projects/my-app
clasp create-script --type standalone --title "My App"

# 3. 코드 작성 & 배포
vim Code.js
clasp push
clasp open-script
```

---

## 📁 프로젝트 구조

```
root/
├── projects/              # Apps Script 프로젝트들
│   └── <project-name>/
│       ├── *.js
│       ├── appsscript.json
│       └── .clasp.json
├── docs/                  # 가이드 문서
└── package.json
```

---

## 🔧 주요 명령어

**루트:**
```bash
# 포맷팅
npm run format          # 모든 코드 자동 포맷팅
npm run format:check    # 포맷팅 검사만 (CI용)

# 린팅
npm run lint            # 린트 검사
npm run lint:fix        # 린트 문제 자동 수정
```

**개별 프로젝트:**
```bash
clasp push          # GAS 업로드
clasp open-script   # 에디터 열기
clasp deploy        # 웹앱 배포
```

---

## ⚠️ 주의사항

### TimeZone 필수 수정

`clasp create-script` 후 항상 확인:

```json
// appsscript.json
{
  "timeZone": "Asia/Seoul"  // 기본값 "America/New_York"에서 변경
}
```

### npm 패키지 사용 불가

Apps Script는 npm 패키지를 런타임에 사용할 수 없습니다.

**대안:**
- 순수 JavaScript 작성
- apps-script-library 사용
- Google API 활용

---

## 🔗 참고

- [Apps Script 공식 문서](https://developers.google.com/apps-script)
- [clasp 공식 문서](https://github.com/google/clasp)
