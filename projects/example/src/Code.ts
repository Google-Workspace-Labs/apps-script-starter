/**
 * Apps Script Starter Template
 *
 * workspace-core 라이브러리를 사용하는 최소 예제입니다.
 * 이 코드를 삭제하고 프로젝트를 시작하세요.
 */

/**
 * Web App 진입점
 */
function doGet(): GoogleAppsScript.HTML.HtmlOutput {
  return HtmlService.createHtmlOutputFromFile('index')
    .setTitle('Apps Script Starter');
}

/**
 * workspace-core 라이브러리 사용 예제
 */
function exampleFunction(): void {
  // 1. 라이브러리 정보 확인
  const version = WorkspaceCore.getLibraryVersion();
  Logger.log('WorkspaceCore Version: ' + version);

  // 2. 날짜 포맷팅
  const today = WorkspaceCore.formatKoreanDate(new Date());
  Logger.log('Today: ' + today);

  // 3. 이메일 검증
  const email = 'user@example.com';
  if (WorkspaceCore.isValidEmail(email)) {
    Logger.log('Valid email: ' + email);
  }

  // 4. 에러 핸들링
  try {
    // 위험한 작업
    processData();
  } catch (error) {
    WorkspaceCore.logError(error as Error, { context: 'exampleFunction' });
  }
}

/**
 * 데이터 처리 예제
 */
function processData(): void {
  // TODO: 실제 로직을 여기에 구현하세요
  Logger.log('Processing data...');
}

/**
 * 메뉴 생성 예제 (Spreadsheet에서만 동작)
 */
function onOpen(): void {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('커스텀 메뉴')
    .addItem('예제 실행', 'exampleFunction')
    .addToUi();
}
