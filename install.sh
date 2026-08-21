#!/usr/bin/env bash
# ============================================================================
#  compdecomp 설치 스크립트 (레포지토리 진입점)
#
#  사용자가 이 스크립트를 실행하면 GitHub 레포지토리에서 아래 4개 파일을
#  다운로드해 현재 디렉토리에 설치합니다.
#
#    - compress.sh          : COMPRESS-TARGETS.txt 목록을 .tar.xz 로 압축
#    - decompress.sh        : .tar.xz 를 원본 디렉토리로 복원
#    - NOTICE.txt           : 워크스페이스 정리 안내문
#    - COMPRESS-TARGETS.txt : 압축 대상 디렉토리 목록
#
#  설치가 끝나면 레포지토리 흔적(임시 다운로드 + 본 스크립트)은 자동 삭제되어
#  사용자 디렉토리에는 위 4개 파일만 남습니다.
# ============================================================================

set -euo pipefail

# ----------------------------------------------------------------------------
#  GitHub 레포지토리 정보
#  레포지토리를 푸시하기 전에 GITHUB_USER 를 반드시 수정하세요.
#  (환경변수로도 지정 가능: GITHUB_USER=xxx bash install.sh)
# ----------------------------------------------------------------------------
GITHUB_USER="${GITHUB_USER:-njuyoung35}"
REPO_NAME="${REPO_NAME:-compdecomp}"
BRANCH="${BRANCH:-main}"

# 설치할 파일 목록 (레포지토리 안의 4개 파일)
FILES=(
    "compress.sh"
    "decompress.sh"
    "NOTICE.txt"
    "COMPRESS-TARGETS.txt"
)

if [ "$GITHUB_USER" = "YOUR_GITHUB_USERNAME" ]; then
    echo "오류: install.sh 상단의 GITHUB_USER 값을 GitHub 사용자명으로 수정한 뒤 푸시하세요."
    exit 1
fi

# 필수 도구 확인
command -v curl >/dev/null 2>&1 || { echo "오류: curl 이 설치되어 있어야 합니다."; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "오류: tar 가 설치되어 있어야 합니다.";  exit 1; }

TARBALL_URL="https://codeload.github.com/${GITHUB_USER}/${REPO_NAME}/tar.gz/refs/heads/${BRANCH}"

# 임시 디렉토리: 스크립트 종료(성공/실패/중단) 시 자동 정리 -> 레포지토리 흔적 제거
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "=== compdecomp 설치 시작 ==="
echo "다운로드: ${TARBALL_URL}"
echo ""

# 1. 레포지토리 tarball 다운로드
if ! curl -fsSL "$TARBALL_URL" -o "$TMP_DIR/repo.tar.gz"; then
    echo "오류: 레포지토리 다운로드에 실패했습니다."
    echo "      사용자명/레포명/브랜치와 URL을 확인하세요: $TARBALL_URL"
    exit 1
fi

# 2. 압축 해제 (codeload tarball 은 {REPO}-{BRANCH}/ 디렉토리 구조)
SRC_DIR="$TMP_DIR/$REPO_NAME-$BRANCH"
tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
if [ ! -d "$SRC_DIR" ]; then
    echo "오류: tarball 내부 구조가 예상과 다릅니다. ($SRC_DIR 없음)"
    exit 1
fi

# 3. 4개 파일을 현재 디렉토리에 설치 (기존 파일은 타임스탬프 백업)
INSTALLED=0
for file in "${FILES[@]}"; do
    if [ ! -f "$SRC_DIR/$file" ]; then
        echo "경고: 레포지토리에 $file 이 없어 건너뜁니다."
        continue
    fi
    if [ -e "$file" ]; then
        backup="${file}.bak_$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        echo "기존 $file 을 $backup 으로 백업했습니다."
    fi
    cp "$SRC_DIR/$file" "$file"
    echo "설치 완료: $file"
    INSTALLED=$((INSTALLED + 1))
done

# 실행 권한 부여
chmod +x compress.sh decompress.sh 2>/dev/null || true

echo ""
if [ "$INSTALLED" -eq 0 ]; then
    echo "오류: 설치된 파일이 없습니다. 레포지토리 상태를 확인하세요."
    exit 1
fi
echo "=== 설치 완료 ($INSTALLED 개 파일) ==="
echo "  사용법:"
echo "    ./compress.sh    # COMPRESS-TARGETS.txt 목록을 .tar.xz 로 압축"
echo "    ./decompress.sh  # .tar.xz 를 원본 디렉토리로 복원"
echo ""
echo "레포지토리 임시 파일은 삭제되었습니다."

# 4. 파일로 저장해 실행한 경우 본 스크립트도 삭제 -> 레포지토리 흔적 제거
#    (curl ... | bash 로 실행하면 $0 이 bash 이므로 삭제하지 않음)
if [[ "$0" != "bash" && -f "$0" ]]; then
    rm -f -- "$0"
    echo "install.sh 진입점도 삭제되었습니다."
fi
