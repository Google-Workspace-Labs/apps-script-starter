# Apps Script Starter 모노레포 가이드

이 문서는 apps-script-starter 모노레포의 구조, npm workspaces 동작 방식, 그리고 프로젝트 관리 방법을 설명합니다.

---

## 📋 목차

- [모노레포란?](#모노레포란)
- [디렉토리 구조](#디렉토리-구조)
- [npm workspaces 이해하기](#npm-workspaces-이해하기)
- [프로젝트 추가하기](#프로젝트-추가하기)
- [빌드 시스템](#빌드-시스템)
- [Git 워크플로우](#git-워크플로우)
- [배포 전략](#배포-전략)
- [트러블슈팅](#트러블슈팅)

---

## 모노레포란?

### Monorepo (단일 저장소)

**정의**: 여러 프로젝트를 하나의 Git 저장소에서 관리하는 방식

```
단일 프로젝트 (Before)            모노레포 (After)
┌──────────────────┐           ┌─────────────────────────┐
│ geo-location/    │           │ my-apps/                │
│ ├── src/         │           │ ├── projects/           │
│ ├── package.json │           │ │   ├── geo-location/   │
│ └── .git/        │           │ │   ├── what-to-eat/    │
└──────────────────┘           │ │   └── scheduler/      │
                               │ ├── package.json        │
┌──────────────────┐           │ └── .git/               │
│ what-to-eat/     │           └─────────────────────────┘
│ ├── src/         │                    ↑
│ ├── package.json │             하나의 저장소에
│ └── .git/        │             모든 프로젝트 포함
└──────────────────┘
```

### 장점 vs 단점

#### ✅ 장점

1. **코드 공유 용이**
   - 공통 설정 파일 재사용 (`tsconfig.base.json`)
   - 공통 스크립트 공유 (`scripts/`)
   - workspace-core 라이브러리 일관된 버전 사용

2. **의존성 관리 간소화**
   - 루트 `package.json`에서 공통 의존성 관리
   - npm workspaces로 자동 연결
   - 중복 설치 방지

3. **일관된 개발 환경**
   - 동일한 빌드 도구 (esbuild)
   - 동일한 TypeScript 설정
   - 동일한 배포 방법 (clasp)

4. **리팩토링 용이**
   - 여러 프로젝트에 걸친 변경 한 번에 커밋
   - 통합 검색 및 바꾸기
   - 일관된 코드 스타일

#### ❌ 단점 (주의사항)

1. **저장소 크기 증가**
   - 모든 프로젝트의 히스토리 포함
   - Clone 시간 증가

2. **권한 관리 복잡**
   - 전체 저장소 접근 권한 필요
   - 프로젝트별 권한 분리 불가

3. **CI/CD 복잡도**
   - 변경된 프로젝트만 배포하려면 추가 설정 필요

### 언제 모노레포를 사용할까?

#### ✅ 모노레포 추천

- 관련된 여러 Apps Script 프로젝트
- 회사/팀 전체 자동화 도구
- 공통 로직이 많은 프로젝트들
- 동일한 개발자/팀이 관리

#### ❌ 단일 레포 추천

- 완전히 독립적인 프로젝트
- 다른 팀/조직이 관리
- 외부 공개 프로젝트

---

## 디렉토리 구조

### 전체 구조

```
apps-script-starter/
├── projects/                 # 모든 Apps Script 프로젝트
│   ├── example/             # 예제 프로젝트
│   ├── geo-location/        # 사용자 프로젝트 1
│   └── what-to-eat/         # 사용자 프로젝트 2
│
├── scripts/                 # 공통 스크립트
│   ├── setup.sh             # 모노레포 초기화
│   └── create-project.sh    # 새 프로젝트 생성
│
├── docs/                    # 문서
│   ├── MONOREPO_GUIDE.md    # 이 파일
│   └── MIGRATION.md         # 마이그레이션 가이드
│
├── package.json             # 루트 package.json (workspaces 설정)
├── tsconfig.base.json       # 공통 TypeScript 설정
├── .gitignore
└── README.md
```

### 개별 프로젝트 구조

```
projects/geo-location/
├── src/
│   ├── Code.ts              # 메인 TypeScript 파일
│   ├── config/              # 프로젝트별 설정 (선택)
│   └── utils/               # 프로젝트별 유틸리티 (선택)
│
├── dist/                    # 빌드 결과물 (gitignore)
│   ├── Code.js
│   └── appsscript.json
│
├── index.html               # Web App HTML (선택)
├── appsscript.json          # Apps Script 설정
├── .clasp.json              # Script ID (gitignore)
├── package.json             # 프로젝트별 의존성
├── tsconfig.json            # TypeScript 설정 (base 확장)
└── esbuild.config.mjs       # 빌드 설정
```

### 파일별 역할

| 파일 | 위치 | 역할 |
|------|------|------|
| `package.json` | 루트 | workspaces 설정, 공통 스크립트 |
| `package.json` | projects/* | 프로젝트별 의존성, 빌드 스크립트 |
| `tsconfig.base.json` | 루트 | 공통 TypeScript 설정 |
| `tsconfig.json` | projects/* | 프로젝트별 TypeScript 설정 (base 확장) |
| `.gitignore` | 루트 | 전체 저장소 무시 파일 |
| `.clasp.json` | projects/* | 프로젝트별 Script ID (gitignore) |

---

## npm workspaces 이해하기

### workspaces란?

npm workspaces는 모노레포에서 여러 프로젝트의 의존성을 통합 관리하는 기능입니다.

### 설정 방법

**루트 package.json**:
```json
{
  "name": "apps-script-starter",
  "workspaces": [
    "projects/*"
  ],
  "scripts": {
    "build:all": "npm run build --workspaces",
    "push:all": "npm run push --workspaces",
    "new": "./scripts/create-project.sh"
  }
}
```

**projects/geo-location/package.json**:
```json
{
  "name": "geo-location",
  "scripts": {
    "build": "node esbuild.config.mjs",
    "push": "npm run build && clasp push"
  }
}
```

### 작동 원리

```
루트에서 npm install 실행
       ↓
┌─────────────────────────────────────┐
│ 1. projects/*/package.json 검색      │
│    - projects/example/package.json  │
│    - projects/geo-location/...      │
│    - projects/what-to-eat/...       │
└─────────────────────────────────────┘
       ↓
┌─────────────────────────────────────┐
│ 2. 모든 의존성 분석                   │
│    - 공통 의존성 추출                 │
│    - 프로젝트별 의존성 확인            │
└─────────────────────────────────────┘
       ↓
┌─────────────────────────────────────┐
│ 3. node_modules 구조 생성            │
│                                     │
│ 루트/                               │
│ ├── node_modules/                  │
│ │   ├── esbuild/     (공통)        │
│ │   ├── typescript/  (공통)        │
│ │   └── @google/clasp/ (공통)      │
│ │                                  │
│ └── projects/                      │
│     ├── example/                   │
│     │   └── node_modules/ → 루트 참조│
│     └── geo-location/              │
│         └── node_modules/ → 루트 참조│
└─────────────────────────────────────┘
```

### 명령어 실행

#### 전체 프로젝트 실행

```bash
# 모든 프로젝트 빌드
npm run build:all

# 실제 실행되는 것:
# - projects/example: npm run build
# - projects/geo-location: npm run build
# - projects/what-to-eat: npm run build
```

#### 특정 프로젝트만 실행

```bash
# 방법 1: 프로젝트 디렉토리로 이동
cd projects/geo-location
npm run build

# 방법 2: 루트에서 workspace 지정
npm run build --workspace=geo-location

# 방법 3: 약어 사용
npm run build -w geo-location
```

### 의존성 추가

#### 공통 의존성 (모든 프로젝트)

```bash
# 루트에 추가
npm install -D typescript

# → 모든 프로젝트에서 사용 가능
```

#### 프로젝트별 의존성

```bash
# 특정 프로젝트에만 추가
cd projects/geo-location
npm install axios

# 또는 루트에서
npm install axios --workspace=geo-location
```

---

## 프로젝트 추가하기

### 자동 생성 (추천)

```bash
# 루트 디렉토리에서 실행
npm run new my-new-app

# 자동으로 수행되는 작업:
# 1. projects/my-new-app/ 디렉토리 생성
# 2. clasp create 실행 (Apps Script 프로젝트 생성)
# 3. 기본 파일 생성 (src/Code.ts, index.html 등)
# 4. package.json, tsconfig.json 생성
# 5. esbuild.config.mjs 생성
# 6. appsscript.json 생성 (workspace-core 연동)
```

**생성 후 구조**:
```
projects/my-new-app/
├── src/
│   └── Code.ts              # 기본 코드 포함
├── dist/                    # 빌드 시 생성
├── index.html               # 기본 Web App UI
├── appsscript.json          # workspace-core 연동 완료
├── .clasp.json              # Script ID 포함
├── package.json
├── tsconfig.json
└── esbuild.config.mjs
```

### 수동 생성

#### 1단계: 디렉토리 생성

```bash
mkdir -p projects/my-app/src
cd projects/my-app
```

#### 2단계: Apps Script 프로젝트 생성

```bash
clasp create --title "My App" --type standalone
```

#### 3단계: 기본 파일 생성

**src/Code.ts**:
```typescript
function doGet(): GoogleAppsScript.HTML.HtmlOutput {
  return HtmlService.createHtmlOutputFromFile('index')
    .setTitle('My App');
}

function exampleFunction(): void {
  const version = WorkspaceCore.getLibraryVersion();
  Logger.log('WorkspaceCore Version: ' + version);
}
```

**package.json**:
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "scripts": {
    "build": "node esbuild.config.mjs",
    "watch": "node esbuild.config.mjs --watch",
    "push": "npm run build && clasp push",
    "open": "clasp open"
  },
  "devDependencies": {
    "@types/google-apps-script": "^1.0.83"
  }
}
```

**tsconfig.json**:
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**esbuild.config.mjs**:
```javascript
import * as esbuild from 'esbuild';

const isWatch = process.argv.includes('--watch');

const buildOptions = {
  entryPoints: ['src/Code.ts'],
  bundle: false,
  outfile: 'dist/Code.js',
  platform: 'neutral',
  target: 'es2020',
  banner: {
    js: '// Auto-generated from TypeScript\n'
  }
};

if (isWatch) {
  const context = await esbuild.context(buildOptions);
  await context.watch();
  console.log('👀 Watching...');
} else {
  await esbuild.build(buildOptions);
  console.log('✅ Build complete');
}
```

**appsscript.json**:
```json
{
  "timeZone": "Asia/Seoul",
  "dependencies": {
    "libraries": [{
      "userSymbol": "WorkspaceCore",
      "libraryId": "1II0VGB7VY1_tNxLbNfoxp3ApVIqq7Am99LevLMMgX4LlgMI5vQCj4l4V",
      "version": "3",
      "developmentMode": false
    }]
  },
  "exceptionLogging": "STACKDRIVER",
  "runtimeVersion": "V8"
}
```

**.clasp.json** (clasp create가 자동 생성):
```json
{
  "scriptId": "YOUR_SCRIPT_ID",
  "rootDir": "./dist"
}
```

#### 4단계: 빌드 및 테스트

```bash
npm install
npm run build
npm run push
npm run open
```

---

## 빌드 시스템

### 전체 흐름

```
┌─────────────────────────────────────────────────────────┐
│                    개발 단계                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  projects/geo-location/src/Code.ts                      │
│  └── TypeScript 코드 작성                                │
│                                                         │
│         ↓                                              │
│    npm run build (또는 npm run watch)                   │
│         ↓                                              │
│  esbuild.config.mjs 실행                                │
│  ├── TypeScript → JavaScript 변환                       │
│  ├── 타입 체크                                           │
│  └── dist/Code.js 생성                                  │
│                                                         │
│         ↓                                              │
│  appsscript.json, index.html 복사                       │
│         ↓                                              │
│  projects/geo-location/dist/                            │
│  ├── Code.js                                           │
│  ├── appsscript.json                                   │
│  └── index.html                                        │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│                    배포 단계                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│    clasp push (또는 npm run push)                       │
│         ↓                                              │
│  .clasp.json 읽기: "rootDir": "./dist"                  │
│         ↓                                              │
│  dist/ 폴더의 모든 파일 업로드                           │
│         ↓                                              │
│  Google Apps Script 서버                                │
│  ├── Code.js                                           │
│  ├── appsscript.json                                   │
│  └── index.html                                        │
└─────────────────────────────────────────────────────────┘
```

### 개별 프로젝트 빌드

```bash
cd projects/geo-location
npm run build
```

### 전체 프로젝트 빌드

```bash
# 루트 디렉토리에서
npm run build:all
```

**내부 동작**:
```bash
# npm workspaces가 각 프로젝트에서 실행:
cd projects/example && npm run build
cd projects/geo-location && npm run build
cd projects/what-to-eat && npm run build
```

### Watch 모드

```bash
# 특정 프로젝트
cd projects/geo-location
npm run watch

# 파일 변경 시 자동 리빌드
# src/Code.ts 수정 → 자동으로 dist/Code.js 생성
```

---

## Git 워크플로우

### 브랜치 전략

```
main (운영)
 │
 ├─ develop (개발)
 │   │
 │   ├─ feature/add-auth     # 새 기능
 │   ├─ feature/new-project  # 새 프로젝트 추가
 │   └─ fix/bug-123          # 버그 수정
```

### 새 프로젝트 추가 시 커밋

```bash
# 1. 새 프로젝트 생성
npm run new scheduler

# 2. 개발 및 테스트
cd projects/scheduler
# ... 코딩 ...
npm run build
npm run push

# 3. Git 커밋 (프로젝트 전체 포함)
git add projects/scheduler/
git commit -m "feat: Add scheduler project

- Add cron-like scheduling functionality
- Integrate with workspace-core
- Add web UI for schedule management"

# 4. 푸시
git push origin develop
```

### 여러 프로젝트 동시 수정

```bash
# 예: workspace-core 버전 업데이트

# 1. 모든 프로젝트의 appsscript.json 수정
find projects -name "appsscript.json" -exec sed -i '' 's/"version": "3"/"version": "4"/' {} \;

# 2. 전체 빌드 및 테스트
npm run build:all

# 3. 커밋
git add projects/*/appsscript.json
git commit -m "chore: Update workspace-core to v4

Updated all projects to use workspace-core version 4
- geo-location
- what-to-eat
- scheduler"
```

### .gitignore 설정

```gitignore
# Dependencies
node_modules/

# Build Output
dist/                    # 모든 프로젝트의 dist/
projects/*/dist/

# Apps Script
.clasp.json              # Script ID 보안
.clasprc.json            # 인증 토큰
projects/*/.clasp.json

# Environment
.env
.env.local

# Logs
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

---

## 배포 전략

### 개별 프로젝트 배포

```bash
cd projects/geo-location
npm run push
```

### 전체 프로젝트 배포

```bash
# 루트에서
npm run push:all
```

**주의**: 모든 프로젝트가 배포되므로 신중하게 사용!

### 선택적 배포

```bash
# 특정 프로젝트들만
npm run push -w geo-location -w what-to-eat
```

### CI/CD 고려사항

**변경된 프로젝트만 배포**:

```yaml
# .github/workflows/deploy.yml
name: Deploy Changed Projects

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2  # 이전 커밋과 비교

      - name: Get changed projects
        id: changed
        run: |
          CHANGED=$(git diff --name-only HEAD~1 HEAD | grep '^projects/' | cut -d/ -f2 | sort -u)
          echo "projects=$CHANGED" >> $GITHUB_OUTPUT

      - name: Deploy changed projects
        run: |
          for project in ${{ steps.changed.outputs.projects }}; do
            cd projects/$project
            npm run push
            cd ../..
          done
```

---

## 트러블슈팅

### 문제 1: workspace가 인식 안 됨

**증상**:
```bash
$ npm run build:all
npm ERR! No workspaces found
```

**원인**: package.json의 workspaces 설정 누락

**해결**:
```json
{
  "workspaces": [
    "projects/*"  // ← 이 설정 확인
  ]
}
```

### 문제 2: 프로젝트 간 의존성 충돌

**증상**:
```
npm ERR! conflicting versions of package X
```

**원인**: 서로 다른 프로젝트가 다른 버전 요구

**해결**:
```bash
# 1. 의존성 확인
npm ls package-name

# 2. 버전 통일 (가능하면)
# 또는 프로젝트별로 별도 설치
cd projects/geo-location
npm install package-name@specific-version
```

### 문제 3: tsconfig 경로 에러

**증상**:
```
Cannot find tsconfig.base.json
```

**원인**: 상대 경로 문제

**해결**:
```json
{
  "extends": "../../tsconfig.base.json"  // 정확한 상대 경로
}
```

### 문제 4: 빌드는 되는데 배포 실패

**증상**:
```bash
$ npm run push
✅ Build complete
Push failed
```

**원인**: .clasp.json 누락 또는 잘못된 설정

**해결**:
```bash
# .clasp.json 확인
cat .clasp.json

# 없으면 생성
cat > .clasp.json << EOF
{
  "scriptId": "YOUR_SCRIPT_ID",
  "rootDir": "./dist"
}
EOF
```

### 문제 5: 전체 빌드가 너무 느림

**증상**: `npm run build:all`이 오래 걸림

**해결 1**: 병렬 실행
```bash
# npm-run-all 설치
npm install -D npm-run-all

# package.json
{
  "scripts": {
    "build:all": "npm-run-all --parallel build:*",
    "build:geo": "npm run build -w geo-location",
    "build:what": "npm run build -w what-to-eat"
  }
}
```

**해결 2**: 변경된 프로젝트만 빌드
```bash
# Lerna 또는 Nx 같은 모노레포 도구 고려
```

---

## 참고 자료

### 공식 문서
- [npm workspaces](https://docs.npmjs.com/cli/v7/using-npm/workspaces)
- [Monorepo 패턴](https://monorepo.tools/)

### 관련 문서
- [README.md](../README.md) - 빠른 시작 가이드
- [workspace-core/docs/DEVELOPMENT.md](https://github.com/Google-Workspace-Labs/workspace-core/blob/develop/docs/DEVELOPMENT.md) - Library 개발 가이드

### 도구
- [Lerna](https://lerna.js.org/) - 모노레포 관리 도구
- [Nx](https://nx.dev/) - 고급 모노레포 도구
- [Turborepo](https://turbo.build/repo) - 빠른 빌드 도구

---

**마지막 업데이트**: 2026-01-23
**문의**: GitHub Issues
