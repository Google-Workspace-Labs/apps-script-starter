# Apps Script Starter (Monorepo)

Google Apps Script 프로젝트를 TypeScript로 개발하고 여러 프로젝트를 하나의 레포에서 관리하는 모노레포 템플릿

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![workspace-core](https://img.shields.io/badge/workspace--core-v3-purple)](https://github.com/Google-Workspace-Labs/workspace-core)

---

## ⚡ 빠른 시작

### 1. 템플릿 사용

GitHub에서 **"Use this template"** 버튼 클릭 → 새 레포지토리 생성

### 2. 로컬에 클론

```bash
git clone https://github.com/YOUR_USERNAME/your-monorepo.git
cd your-monorepo
```

### 3. 초기화

```bash
# 전체 모노레포 초기화
./scripts/setup.sh
```

### 4. 새 프로젝트 생성

```bash
# 새 Apps Script 프로젝트 추가
npm run new my-app

# 프로젝트 디렉토리로 이동
cd projects/my-app

# 개발 시작
npm run watch    # 파일 감시 + 자동 빌드
npm run push     # Apps Script 배포
npm run open     # Apps Script 에디터 열기
```

**끝!** 🎉

---

## 📁 프로젝트 구조

```
your-monorepo/
├── projects/                 # 모든 Apps Script 프로젝트
│   ├── example/             # 예제 프로젝트
│   │   ├── src/
│   │   │   ├── Code.ts     # 메인 진입점
│   │   │   ├── config/     # 설정 파일
│   │   │   └── utils/      # 유틸리티
│   │   ├── dist/           # 빌드 결과물 (자동 생성)
│   │   ├── index.html      # Web App HTML
│   │   ├── appsscript.json # Apps Script 설정
│   │   ├── .clasp.json     # Script ID (개별)
│   │   ├── package.json    # 프로젝트별 의존성
│   │   ├── tsconfig.json   # TypeScript 설정
│   │   └── esbuild.config.mjs # 빌드 설정
│   │
│   ├── my-app/             # 사용자 프로젝트 1
│   └── another-app/        # 사용자 프로젝트 2
│
├── scripts/
│   ├── setup.sh            # 모노레포 초기화
│   └── create-project.sh   # 새 프로젝트 생성
│
├── package.json            # 루트 (workspaces 설정)
├── tsconfig.base.json      # 공통 TypeScript 설정
└── README.md
```

---

## 🔧 주요 명령어

### 모노레포 전체

| 명령어 | 설명 |
|--------|------|
| `npm run new <name>` | 새 프로젝트 생성 |
| `npm run build:all` | 모든 프로젝트 빌드 |
| `npm run watch:all` | 모든 프로젝트 감시 |
| `npm run push:all` | 모든 프로젝트 배포 |

### 개별 프로젝트 (projects/프로젝트명/)

| 명령어 | 설명 |
|--------|------|
| `npm run build` | TypeScript → JavaScript 빌드 |
| `npm run watch` | 파일 감시 + 자동 빌드 |
| `npm run push` | 빌드 + Apps Script 배포 |
| `npm run open` | Apps Script 에디터 열기 |
| `npm run deploy` | 빌드 + 배포 + 웹앱 배포 |
| `npm run logs` | Apps Script 로그 확인 |

---

## 📚 주요 기능

- ✅ **모노레포** - 여러 Apps Script 프로젝트를 하나의 레포에서 관리
- ✅ **TypeScript** - 타입 안전성과 자동완성
- ✅ **workspace-core** - 공통 유틸리티 자동 연동
- ✅ **Hot Reload** - 파일 변경 감지 및 자동 빌드
- ✅ **빠른 프로젝트 생성** - `npm run new` 한 번에 새 프로젝트 추가
- ✅ **독립적 배포** - 각 프로젝트는 독립된 Script ID로 관리

---

## 🚀 새 프로젝트 추가하기

### Step 1: 프로젝트 생성

```bash
# 루트 디렉토리에서 실행
npm run new my-new-app
```

이 명령은 자동으로:
- `projects/my-new-app/` 디렉토리 생성
- Apps Script 프로젝트 생성 (clasp)
- 기본 파일 구조 생성 (src/Code.ts, index.html 등)
- workspace-core 연동 설정

### Step 2: Script ID 확인

```bash
cd projects/my-new-app
cat .clasp.json  # scriptId 확인
```

### Step 3: 개발 시작

```bash
npm install      # 의존성 설치
npm run build    # 빌드 테스트
npm run watch    # 개발 모드
```

### Step 4: 배포

```bash
npm run push     # Apps Script에 배포
npm run open     # 에디터에서 확인
```

---

## 🌟 workspace-core 사용 예시

모든 프로젝트는 workspace-core를 사용할 수 있습니다.

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

**더 많은 기능**: [workspace-core 문서](https://github.com/Google-Workspace-Labs/workspace-core)

---

## 🎨 프로젝트 커스터마이징

### HTML 수정

각 프로젝트의 `index.html` 파일을 수정하여 웹 앱 UI 커스터마이징

### TypeScript 코드

`src/Code.ts`와 `src/utils/`에서 로직 구현

### workspace-core 버전 업데이트

각 프로젝트의 `appsscript.json`에서 버전 변경:

```json
{
  "dependencies": {
    "libraries": [{
      "version": "4"  // 최신 버전으로 변경
    }]
  }
}
```

---

## 💡 모노레포 장점

### 단일 프로젝트 vs 모노레포

**단일 프로젝트 (Before)**
```
❌ 프로젝트마다 별도 레포지토리
❌ 중복된 설정 파일
❌ 공통 코드 복사/붙여넣기
❌ 의존성 관리 복잡
```

**모노레포 (After)**
```
✅ 하나의 레포에서 여러 프로젝트 관리
✅ 공통 설정 재사용 (tsconfig.base.json)
✅ workspace-core로 공통 기능 공유
✅ npm workspaces로 의존성 통합 관리
```

### 언제 모노레포를 사용할까?

- 관련된 여러 Apps Script 프로젝트 개발
- 회사/팀에서 여러 자동화 도구 관리
- 공통 로직을 여러 프로젝트에서 사용
- 일관된 코드 스타일과 설정 유지

---

## 📖 문서

- [workspace-core API](https://github.com/Google-Workspace-Labs/workspace-core)
- [Apps Script 공식 문서](https://developers.google.com/apps-script)
- [TypeScript 공식 문서](https://www.typescriptlang.org/)
- [npm workspaces](https://docs.npmjs.com/cli/v7/using-npm/workspaces)

---

## 🙋 FAQ

### Q: 프로젝트를 몇 개까지 추가할 수 있나요?

A: 제한 없습니다. `npm run new` 명령으로 원하는 만큼 추가할 수 있습니다.

### Q: 각 프로젝트는 독립적으로 배포되나요?

A: 네, 각 프로젝트는 독립된 Script ID와 .clasp.json을 가지므로 개별 배포 가능합니다.

### Q: 기존 Apps Script 프로젝트를 이전할 수 있나요?

A: 가능합니다.
1. `npm run new existing-project` 실행
2. 기존 코드를 `projects/existing-project/src/`로 복사
3. `.clasp.json`에 기존 Script ID 입력

### Q: 모노레포가 너무 복잡하면?

A: 단순한 프로젝트는 `projects/` 안에 하나만 두고 사용해도 됩니다.

### Q: workspace-core 없이 사용할 수 있나요?

A: 네. 각 프로젝트의 `appsscript.json`에서 dependencies를 삭제하면 됩니다.

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

**Made with ❤️ by Google-Workspace-Labs**
