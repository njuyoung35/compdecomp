#!/bin/bash

# ============================================================================
#  복원 스크립트 - COMPRESS-TARGETS.txt에 나열된 .tar.xz 파일들을 압축 해제
# ============================================================================

set -e

TARGET_FILE="COMPRESS-TARGETS.txt"
LOG_FILE="decompress_$(date +%Y%m%d_%H%M%S).log"
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "======================================================================"
echo "  🔓 워크스페이스 복원 시작 ($START_TIME)"
echo "======================================================================"
echo ""

if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ 오류: $TARGET_FILE 파일을 찾을 수 없습니다."
    exit 1
fi

targets=$(grep -v '^[[:space:]]*$' "$TARGET_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$targets" ]; then
    echo "❌ 오류: $TARGET_FILE 에 복원 대상이 없습니다."
    exit 1
fi

echo "📋 복원 대상 목록:"
echo "$targets" | sed 's/^/  - /'
echo ""
echo "----------------------------------------------------------------------"

TOTAL=$(echo "$targets" | wc -l)
COUNT=0
SUCCESS=0
FAILED=0

for dir in $targets; do
    COUNT=$((COUNT + 1))
    ARCHIVE="${dir}.tar.xz"
    
    echo "[$COUNT/$TOTAL] 복원 중: $dir"
    
    if [ ! -f "$ARCHIVE" ]; then
        echo "  ⚠️  경고: $ARCHIVE 파일이 존재하지 않습니다. (건너뜀)"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # 이미 디렉토리가 존재하면 백업
    if [ -d "$dir" ]; then
        BACKUP="${dir}_backup_$(date +%Y%m%d_%H%M%S)"
        echo "  ⚠️  '$dir' 이미 존재합니다. → '$BACKUP' 으로 백업 후 진행"
        mv "$dir" "$BACKUP"
    fi
    
    # 압축 해제
    if tar -xJvf "$ARCHIVE" >> "$LOG_FILE" 2>&1; then
        echo "  ✅ 복원 완료: $dir"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ❌ 복원 실패: $dir (로그 확인)"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
done

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
DURATION=$(( $(date -d "$END_TIME" +%s) - $(date -d "$START_TIME" +%s) ))

echo "----------------------------------------------------------------------"
echo "  ✅ 복원 작업 완료!"
echo "  📊 결과: 총 $TOTAL 개 중 성공 $SUCCESS, 실패 $FAILED"
echo "  ⏱️  소요 시간: ${DURATION}초"
echo "  📝 로그 파일: $LOG_FILE"
echo ""
echo "📌 복원 후 .tar.xz 파일은 직접 삭제하셔도 됩니다: rm -f *.tar.xz"
echo "======================================================================"
