# Apps Script Starter

Google Apps Script 프로젝트를 TypeScript로 빠르게 시작하기 위한 템플릿

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![workspace-core](https://img.shields.io/badge/workspace--core-v2-purple)](https://github.com/Google-Workspace-Labs/workspace-core)

---

## ⚡ 빠른 시작 (30초)

### 1. 템플릿 사용

GitHub에서 **"Use this template"** 버튼 클릭 → 새 레포지토리 생성

### 2. Apps Script 프로젝트 생성

1. https://script.google.com 접속
2. **새 프로젝트** 생성
3. **프로젝트 설정** → **Script ID** 복사

### 3. 로컬 설정

```bash
git clone https://github.com/YOUR_USERNAME/your-project.git
cd your-project

# 자동 초기화 (프로젝트 이름 + Script ID 입력)
./scripts/setup.sh
```

### 4. 개발 시작

```bash
# 파일 감시 + 자동 빌드
npm run watch

# (다른 터미널에서) 배포
npm run push

# Apps Script 에디터 열기
npm run open
```

**끝!** 🎉

---

## 📚 주요 기능

- ✅ **TypeScript** - 타입 안전성과 자동완성
- ✅ **workspace-core** - 공통 유틸리티 자동 연동
- ✅ **Hot Reload** - 파일 변경 감지 및 자동 빌드
- ✅ **자동화 스크립트** - setup.sh로 30초 초기화
- ✅ **간편한 배포** - `npm run push` 한 번에 배포

---

## 🔧 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `npm run build` | TypeScript → JavaScript 빌드 |
| `npm run watch` | 파일 감시 + 자동 빌드 |
| `npm run push` | 빌드 + Apps Script 배포 |
| `npm run open` | Apps Script 에디터 열기 |
| `npm run deploy` | 빌드 + 배포 + 웹앱 배포 |
| `npm run logs` | Apps Script 로그 확인 |

---

## 📁 프로젝트 구조

```
your-project/
├── src/
│   ├── Code.ts           # 메인 진입점 (여기서 시작!)
│   ├── config/           # 설정 파일
│   └── utils/            # 프로젝트 유틸리티
├── dist/                 # 빌드 결과물 (자동 생성)
├── scripts/
│   └── setup.sh          # 자동 초기화 스크립트
├── index.html            # Web App HTML
├── appsscript.json       # Apps Script 설정
├── esbuild.config.mjs    # 빌드 설정
├── tsconfig.json         # TypeScript 설정
└── package.json
```

**시작 파일**: `src/Code.ts`를 열어서 개발을 시작하세요!

---

## 🌟 workspace-core 사용 예시

### 날짜 포맷팅

```typescript
const today = WorkspaceCore.formatKoreanDate(new Date());
Logger.log(today); // "2026-01-23"

const dateTime = WorkspaceCore.formatKoreanDate(new Date(), true);
Logger.log(dateTime); // "2026-01-23 10:30:00"
```

### 문자열 변환

```typescript
const kebab = WorkspaceCore.toKebabCase('myVariableName');
Logger.log(kebab); // "my-variable-name"

const camel = WorkspaceCore.toCamelCase('my-variable-name');
Logger.log(camel); // "myVariableName"
```

### 이메일 검증

```typescript
if (WorkspaceCore.isValidEmail(email)) {
  Logger.log('Valid email');
}
```

### 에러 핸들링

```typescript
try {
  riskyOperation();
} catch (error) {
  WorkspaceCore.logError(error as Error, { context: 'myFunction' });
}
```

### 배열 유틸리티

```typescript
// 청크 분할
const chunks = WorkspaceCore.chunk([1, 2, 3, 4, 5], 2);
// [[1, 2], [3, 4], [5]]

// 중복 제거
const unique = WorkspaceCore.unique([1, 2, 2, 3, 3, 3]);
// [1, 2, 3]
```

**더 많은 기능**: [workspace-core 문서](https://github.com/Google-Workspace-Labs/workspace-core)

---

## 🚀 배포

### 로컬 배포

```bash
npm run push
```

### 웹 앱 배포

```bash
npm run deploy
```

배포 후 Apps Script 에디터에서:
1. **배포** → **새 배포**
2. **유형** → **웹 앱**
3. **액세스 권한** 설정
4. **배포** 클릭

---

## 🎨 커스터마이징

### HTML 수정

`index.html` 파일을 수정하여 웹 앱 UI 커스터마이징

### TypeScript 코드

`src/Code.ts`와 `src/utils/`에서 로직 구현

### workspace-core 업데이트

`appsscript.json`에서 버전 변경:

```json
{
  "dependencies": {
    "libraries": [{
      "version": "3"  // 최신 버전으로 변경
    }]
  }
}
```

---

## 📖 문서

- [workspace-core API](https://github.com/Google-Workspace-Labs/workspace-core)
- [Apps Script 공식 문서](https://developers.google.com/apps-script)
- [TypeScript 공식 문서](https://www.typescriptlang.org/)

---

## 🤝 기여

이슈와 PR을 환영합니다!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 라이선스

MIT License - 자유롭게 사용하세요

---

## 🙋 FAQ

### Q: TypeScript를 꼭 써야 하나요?

A: 아니요. src/Code.ts를 .js로 바꾸고 tsconfig.json을 삭제해도 됩니다.

### Q: workspace-core 없이 사용할 수 있나요?

A: 네. `appsscript.json`에서 dependencies를 삭제하면 됩니다.

### Q: 다른 라이브러리를 추가하려면?

A: `appsscript.json`의 libraries 배열에 추가하세요.

### Q: 빌드 에러가 발생하면?

A: `npm install`을 다시 실행하고, `node_modules`와 `dist` 폴더를 삭제 후 재시도하세요.

---

**Made with ❤️ by Google-Workspace-Labs**
