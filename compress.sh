#!/bin/bash

# ============================================================================
#  압축 스크립트 - COMPRESS-TARGETS.txt에 나열된 디렉토리들을 .tar.xz로 압축
# ============================================================================

set -e  # 에러 발생 시 즉시 중단

TARGET_FILE="COMPRESS-TARGETS.txt"
LOG_FILE="compress_$(date +%Y%m%d_%H%M%S).log"
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')

echo "======================================================================"
echo "  📦 워크스페이스 압축 정리 시작 ($START_TIME)"
echo "======================================================================"
echo ""

# 대상 파일 존재 확인
if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ 오류: $TARGET_FILE 파일을 찾을 수 없습니다."
    exit 1
fi

# 대상 목록 읽기 (빈 줄과 공백 제거)
targets=$(grep -v '^[[:space:]]*$' "$TARGET_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$targets" ]; then
    echo "❌ 오류: $TARGET_FILE 에 압축 대상이 없습니다."
    exit 1
fi

echo "📋 압축 대상 목록:"
echo "$targets" | sed 's/^/  - /'
echo ""
echo "----------------------------------------------------------------------"

TOTAL=$(echo "$targets" | wc -l)
COUNT=0
SUCCESS=0
FAILED=0

# 각 대상에 대해 압축 실행
for dir in $targets; do
    COUNT=$((COUNT + 1))
    echo "[$COUNT/$TOTAL] 처리 중: $dir"
    
    if [ ! -d "$dir" ]; then
        echo "  ⚠️  경고: '$dir' 디렉토리가 존재하지 않습니다. (건너뜀)"
        echo "  ⚠️  경고: '$dir' 디렉토리가 존재하지 않습니다. (건너뜀)" >> "$LOG_FILE"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # 압축 전 용량 측정
    BEFORE=$(du -sh "$dir" 2>/dev/null | cut -f1)
    
    echo "  📦 압축 중... (압축 전: $BEFORE)"
    echo "  📦 압축 중... (압축 전: $BEFORE)" >> "$LOG_FILE"
    
    # 실제 압축 실행 (xz, 우선순위 낮춤)
    if nice -n 19 tar -cJvf "${dir}.tar.xz" "$dir" >> "$LOG_FILE" 2>&1; then
        AFTER=$(du -sh "${dir}.tar.xz" 2>/dev/null | cut -f1)
        echo "  ✅ 완료: ${dir}.tar.xz (압축 후: $AFTER)"
        echo "  ✅ 완료: ${dir}.tar.xz (압축 후: $AFTER)" >> "$LOG_FILE"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  ❌ 실패: $dir 압축 중 오류 발생 (로그 확인)"
        echo "  ❌ 실패: $dir 압축 중 오류 발생" >> "$LOG_FILE"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
done

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
DURATION=$(( $(date -d "$END_TIME" +%s) - $(date -d "$START_TIME" +%s) ))

echo "----------------------------------------------------------------------"
echo "  ✅ 압축 작업 완료!"
echo "  📊 결과: 총 $TOTAL 개 중 성공 $SUCCESS, 실패 $FAILED"
echo "  ⏱️  소요 시간: ${DURATION}초"
echo "  📝 로그 파일: $LOG_FILE"
echo "======================================================================"

# 원본 디렉토리 삭제 여부 확인 (안전장치)
echo ""
echo "⚠️  원본 디렉토리를 삭제하시겠습니까? (y/N)"
read -r confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    for dir in $targets; do
        if [ -d "$dir" ] && [ -f "${dir}.tar.xz" ]; then
            echo "🗑️  삭제 중: $dir"
            rm -rf "$dir"
        fi
    done
    echo "✅ 원본 디렉토리 삭제 완료."
else
    echo "ℹ️  원본 디렉토리를 유지합니다. (직접 삭제하시려면 'rm -rf [디렉토리명]' 실행)"
fi

echo ""
echo "📌 복원이 필요하시면 ./decompress.sh 를 실행하세요."
