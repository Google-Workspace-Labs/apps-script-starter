#!/bin/bash
set -e

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: npm run new <project-name>"
  echo "Example: npm run new my-new-app"
  exit 1
fi

PROJECT_DIR="projects/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' already exists"
  exit 1
fi

echo "🆕 Creating new Apps Script project: $PROJECT_NAME"
echo ""

# 디렉토리 생성
mkdir -p "$PROJECT_DIR/src"
cd "$PROJECT_DIR"

echo "📝 Creating Apps Script project..."
clasp create --title "$PROJECT_NAME" --type standalone

# src 디렉토리로 TypeScript 파일 생성
echo "📄 Creating TypeScript files..."
cat > src/Code.ts <<'EOF'
/**
 * Main entry point for the Apps Script web app
 */
function doGet(): GoogleAppsScript.HTML.HtmlOutput {
  return HtmlService.createHtmlOutputFromFile('index')
    .setTitle('My App');
}

/**
 * Example function using workspace-core
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
    throw new Error('Test error');
  } catch (error) {
    WorkspaceCore.logError(error as Error, { context: 'exampleFunction' });
  }
}
EOF

# HTML 파일 생성
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
  <head>
    <base target="_top">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My App</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        color: #333;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 20px;
      }

      .container {
        background: white;
        padding: 40px;
        border-radius: 12px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        max-width: 600px;
        width: 100%;
      }

      h1 {
        color: #667eea;
        margin-bottom: 10px;
        font-size: 2em;
      }

      .subtitle {
        color: #666;
        margin-bottom: 30px;
        font-size: 1.1em;
      }

      button {
        background: #667eea;
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 6px;
        cursor: pointer;
        font-size: 16px;
        font-weight: 600;
        transition: all 0.3s ease;
        width: 100%;
      }

      button:hover {
        background: #5568d3;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
      }

      button:active {
        transform: translateY(0);
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>🚀 My App</h1>
      <p class="subtitle">Google Apps Script Web App</p>

      <button onclick="runExample()">
        Run Example
      </button>
    </div>

    <script>
      function runExample() {
        google.script.run
          .withSuccessHandler(function() {
            alert('Check Apps Script logs!');
          })
          .withFailureHandler(function(error) {
            alert('Error: ' + error.message);
          })
          .exampleFunction();
      }
    </script>
  </body>
</html>
EOF

# package.json 생성
cat > package.json <<PKGJSON
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "node esbuild.config.mjs",
    "watch": "node esbuild.config.mjs --watch",
    "push": "npm run build && clasp push",
    "pull": "clasp pull",
    "open": "clasp open",
    "deploy": "npm run build && clasp push && clasp deploy",
    "logs": "clasp logs"
  },
  "devDependencies": {
    "@types/google-apps-script": "^1.0.83"
  }
}
PKGJSON

# tsconfig.json 생성
cat > tsconfig.json <<'TSCFG'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
TSCFG

# esbuild.config.mjs 생성
cat > esbuild.config.mjs <<'ESBUILDCFG'
import * as esbuild from 'esbuild';

const isWatch = process.argv.includes('--watch');

const buildOptions = {
  entryPoints: ['src/Code.ts'],
  bundle: true,
  outfile: 'dist/Code.js',
  platform: 'neutral',
  target: 'es2020',
  format: 'iife',
  globalName: 'Main',
  banner: {
    js: '// Auto-generated from TypeScript\n'
  }
};

if (isWatch) {
  const context = await esbuild.context(buildOptions);
  await context.watch();
  console.log('👀 Watching for changes...');
} else {
  await esbuild.build(buildOptions);
  console.log('✅ Build complete');
}
ESBUILDCFG

# appsscript.json 수정 (workspace-core 추가)
cat > appsscript.json <<'APPSCRIPT'
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
APPSCRIPT

# .clasp.json에서 scriptId 추출
SCRIPT_ID=$(jq -r '.scriptId' .clasp.json)

# .clasp.json을 dist로 푸시하도록 수정
cat > .clasp.json <<CLASP
{
  "scriptId": "$SCRIPT_ID",
  "rootDir": "./dist"
}
CLASP

# dist 디렉토리 생성
mkdir -p dist

echo ""
echo "✅ Project '$PROJECT_NAME' created successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. cd projects/$PROJECT_NAME"
echo "   2. npm install"
echo "   3. npm run build"
echo "   4. npm run push"
echo "   5. npm run open"
echo ""
echo "📖 Edit src/Code.ts to start coding!"
echo ""
