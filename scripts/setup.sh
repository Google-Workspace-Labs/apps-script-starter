#!/bin/bash
set -e

echo "🚀 Apps Script Monorepo 초기화 스크립트"
echo "=========================================="
echo ""
echo "이 스크립트는 모노레포 전체를 초기화합니다."
echo ""

# 1. npm install (루트)
if [ ! -d "node_modules" ]; then
  echo "📦 루트 의존성 설치 중..."
  npm install
  echo "✅ 루트 npm install 완료"
else
  echo "✅ 루트 node_modules 이미 존재"
fi

echo ""

# 2. 각 프로젝트 초기화
for project_dir in projects/*/; do
  if [ -d "$project_dir" ]; then
    project_name=$(basename "$project_dir")
    echo "📁 프로젝트 초기화: $project_name"

    cd "$project_dir"

    # npm install
    if [ ! -d "node_modules" ]; then
      echo "   📦 의존성 설치 중..."
      npm install
    else
      echo "   ✅ node_modules 존재"
    fi

    # 빌드 테스트
    echo "   🔨 빌드 테스트..."
    npm run build

    if [ -f "dist/Code.js" ]; then
      echo "   ✅ 빌드 성공"
    else
      echo "   ❌ 빌드 실패"
      cd ../..
      exit 1
    fi

    # appsscript.json 복사
    if [ -f "appsscript.json" ]; then
      cp appsscript.json dist/
      echo "   ✅ appsscript.json 복사 완료"
    fi

    # HTML 파일 복사
    if [ -f "index.html" ]; then
      cp index.html dist/
      echo "   ✅ index.html 복사 완료"
    fi

    cd ../..
    echo ""
  fi
done

echo "🎉 모노레포 초기화 완료!"
echo ""
echo "📝 다음 단계:"
echo ""
echo "새 프로젝트 생성:"
echo "  npm run new <project-name>"
echo ""
echo "전체 빌드:"
echo "  npm run build:all"
echo ""
echo "개별 프로젝트 작업:"
echo "  cd projects/<project-name>"
echo "  npm run watch    # 파일 감시 + 자동 빌드"
echo "  npm run push     # Apps Script 배포"
echo "  npm run open     # Apps Script 에디터 열기"
echo ""
echo "Happy coding! 🚀"
