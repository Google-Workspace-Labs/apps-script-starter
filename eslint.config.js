import fs from 'node:fs';
import { globSync } from 'glob';
import eslintConfigPrettier from 'eslint-config-prettier';

/**
 * 모든 프로젝트의 appsscript.json에서 라이브러리 심볼 추출
 *
 * 이 함수는 ESLint 실행 시마다 호출되지만,
 * - 파일 개수가 적고 (프로젝트 수만큼)
 * - JSON 파싱은 빠르므로
 * - 성능 이슈 없음
 */
function extractLibrarySymbols() {
  const symbols = {};

  try {
    // projects/**/appsscript.json 파일들 찾기
    const appsscriptFiles = globSync('projects/**/appsscript.json', {
      ignore: ['**/node_modules/**'],
    });

    appsscriptFiles.forEach((filePath) => {
      try {
        const content = fs.readFileSync(filePath, 'utf8');
        const config = JSON.parse(content);

        // libraries 배열에서 userSymbol 추출
        const libraries = config.dependencies?.libraries || [];
        libraries.forEach((lib) => {
          if (lib.userSymbol) {
            symbols[lib.userSymbol] = 'readonly';
          }
        });
      } catch (error) {
        console.warn(`⚠️  Failed to parse ${filePath}:`, error.message);
      }
    });

    // 감지된 라이브러리 심볼 출력 (디버깅용)
    const symbolNames = Object.keys(symbols);
    if (symbolNames.length > 0) {
      console.log('📦 Auto-detected library symbols:', symbolNames.join(', '));
    }
  } catch (error) {
    console.warn('⚠️  Failed to extract library symbols:', error.message);
  }

  return symbols;
}

/**
 * Apps Script 표준 전역 객체
 *
 * 이들은 모든 Apps Script 프로젝트에서 기본 제공되므로
 * 명시적으로 정의합니다.
 *
 * 참고: https://developers.google.com/apps-script/reference
 */
const APPS_SCRIPT_GLOBALS = {
  // 기본 서비스
  Logger: 'readonly',
  console: 'readonly', // V8 런타임

  // Google Apps 서비스
  SpreadsheetApp: 'readonly',
  DocumentApp: 'readonly',
  SlidesApp: 'readonly',
  FormApp: 'readonly',
  GmailApp: 'readonly',
  CalendarApp: 'readonly',
  DriveApp: 'readonly',

  // 유틸리티
  HtmlService: 'readonly',
  ScriptApp: 'readonly',
  Utilities: 'readonly',
  Session: 'readonly',
  UrlFetchApp: 'readonly',
  ContentService: 'readonly',

  // 고급 서비스 (자주 사용)
  PropertiesService: 'readonly',
  CacheService: 'readonly',
  LockService: 'readonly',
};

/**
 * 자주 사용하는 공통 라이브러리 (선택 사항)
 *
 * 거의 모든 프로젝트에서 사용하는 라이브러리는
 * 여기에 하드코딩하면 명시성이 높아집니다.
 *
 * appsscript.json에서도 자동 감지되지만,
 * 중복 선언해도 문제없으므로 가독성을 위해 포함.
 */
const COMMON_LIBRARY_SYMBOLS = {
  WorkspaceCore: 'readonly', // apps-script-library
  // 필요시 추가:
  // Moment: 'readonly',
  // Lodash: 'readonly',
};

// appsscript.json에서 동적으로 추출한 라이브러리 심볼
const dynamicLibrarySymbols = extractLibrarySymbols();

// 모든 전역 객체 통합
const allGlobals = {
  ...APPS_SCRIPT_GLOBALS,
  ...COMMON_LIBRARY_SYMBOLS,
  ...dynamicLibrarySymbols,
};

/**
 * Apps Script Simple Triggers (예약 함수명)
 * https://developers.google.com/apps-script/guides/triggers
 *
 * 이 함수들은 코드에서 직접 호출되지 않아도
 * Apps Script 런타임에서 자동 실행되므로 no-unused-vars 제외
 */
const APPS_SCRIPT_TRIGGERS = [
  'onOpen',
  'onInstall',
  'onEdit',
  'onSelectionChange',
  'doGet',
  'doPost',
];

/**
 * 커스텀 예약 함수 (프로젝트별 추가)
 *
 * HTML 템플릿에서 호출되거나, 외부에서 트리거되는 함수들
 * 여기에 추가하면 no-unused-vars 경고가 발생하지 않음
 */
const CUSTOM_RESERVED_FUNCTIONS = [
  'include', // HTML 템플릿에서 <?!= include('filename') ?>로 호출
  'processLocationData', // 클라이언트에서 google.script.run.processLocationData() 호출
  'testWorkspaceCore', // 테스트/디버깅 함수 (Apps Script 에디터에서 실행)
  'sendSolapiSMS', // solapi 프로젝트: SMS 전송 메인 함수
  'getConfig', // 다른 파일에서 호출되는 설정 유틸리티 함수
  // 프로젝트별로 필요한 함수 추가:
  // 'onFormSubmit',
  // 'handleWebhook',
  // 'apiEndpoint',
];

/**
 * ESLint Flat Config (ESM)
 *
 * ESLint 9+ 형식
 * "type": "module" 환경에서 동작
 */
export default [
  {
    // 전역 무시 설정
    ignores: [
      '**/node_modules/**',
      '**/dist/**',
      '**/build/**',
      'scripts/**',
      '**/.clasp.json',
      '**/.clasprc.json',
    ],
  },
  {
    // 프로젝트 파일들에 적용
    files: ['projects/**/*.js'],

    languageOptions: {
      ecmaVersion: 2021,
      sourceType: 'script',
      globals: allGlobals,
    },

    rules: {
      'no-var': 'error',
      'prefer-const': 'warn',
      'prefer-arrow-callback': 'warn',
      'no-unused-vars': [
        'warn',
        {
          argsIgnorePattern: '^_',
          // 기본 트리거 + 커스텀 함수 정규식 패턴 생성
          varsIgnorePattern: `^(${[...APPS_SCRIPT_TRIGGERS, ...CUSTOM_RESERVED_FUNCTIONS].join('|')})$`,
        },
      ],

      // Prettier와 충돌 방지
      ...eslintConfigPrettier.rules,
    },
  },
];
