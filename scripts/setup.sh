#!/bin/bash
set -e

echo "🚀 Apps Script Starter 초기화 스크립트"
echo "======================================"
echo ""

# 1. 프로젝트 이름 입력
read -p "프로젝트 이름을 입력하세요: " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ 프로젝트 이름은 필수입니다."
  exit 1
fi

echo ""
echo "📝 Apps Script 프로젝트 정보 입력"
echo "======================================"
echo "1. https://script.google.com 에서 새 프로젝트 생성"
echo "2. 프로젝트 설정 → Script ID 복사"
echo ""

read -p "Script ID를 입력하세요: " SCRIPT_ID

if [ -z "$SCRIPT_ID" ]; then
  echo "❌ Script ID는 필수입니다."
  exit 1
fi

echo ""
echo "⚙️  초기화 중..."

# 2. package.json 프로젝트 이름 업데이트
if [ -f "package.json" ]; then
  sed -i '' "s/\"name\": \"apps-script-starter\"/\"name\": \"$PROJECT_NAME\"/" package.json
  echo "✅ package.json 업데이트 완료"
fi

# 3. .clasp.json 생성
cat > .clasp.json << EOF
{
  "scriptId": "$SCRIPT_ID",
  "rootDir": "./dist"
}
EOF
echo "✅ .clasp.json 생성 완료"

# 4. npm install
if [ ! -d "node_modules" ]; then
  echo ""
  echo "📦 의존성 설치 중..."
  npm install
  echo "✅ npm install 완료"
else
  echo "✅ node_modules 이미 존재 (스킵)"
fi

# 5. 빌드 테스트
echo ""
echo "🔨 빌드 테스트 중..."
npm run build

if [ -f "dist/Code.js" ]; then
  echo "✅ 빌드 성공"
else
  echo "❌ 빌드 실패"
  exit 1
fi

# 6. appsscript.json을 dist로 복사
cp appsscript.json dist/
echo "✅ appsscript.json 복사 완료"

# 7. index.html을 dist로 복사
if [ -f "index.html" ]; then
  cp index.html dist/
  echo "✅ index.html 복사 완료"
fi

echo ""
echo "🎉 초기화 완료!"
echo ""
echo "다음 단계:"
echo "  1. npm run watch    # 파일 감시 + 자동 빌드"
echo "  2. npm run push     # Apps Script 배포"
echo "  3. npm run open     # Apps Script 에디터 열기"
echo ""
echo "Happy coding! 🚀"
