#!/bin/bash
# ヤッチョGPT - プロンプト文字数バリデータ
# 各ファイルが文字数制限内に収まっているかチェックする

set -euo pipefail

MAIN_FILE="ヤッチョGPT.md"
GPTS_CORE_FILE="ヤッチョGPT (for GPTs).md"
GPTS_KNOWLEDGE_FILE="ヤッチョGPT (for GPTs) - Knowledge.md"

MAIN_LIMIT=12000
GPTS_CORE_LIMIT=7200  # 本来は8000字制限だが、8000字最大までプロンプトを詰め込むと審査で弾かれやすくなる…？っぽいため

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

EXIT_CODE=0

check_file() {
    local file="$1"
    local limit="$2"
    local label="$3"

    if [ ! -f "$file" ]; then
        echo -e "${RED}MISSING${NC} $label: $file が見つかりません"
        EXIT_CODE=1
        return
    fi

    local count
    count=$(wc -m < "$file")

    if [ "$limit" -eq 0 ]; then
        echo -e "${GREEN}OK${NC}      $label: ${count} 文字（制限なし）"
    elif [ "$count" -le "$limit" ]; then
        local remaining=$((limit - count))
        echo -e "${GREEN}OK${NC}      $label: ${count} / ${limit} 文字（余裕: ${remaining}）"
    else
        local over=$((count - limit))
        echo -e "${RED}OVER${NC}    $label: ${count} / ${limit} 文字（${over} 文字オーバー）"
        EXIT_CODE=1
    fi
}

echo "=== ヤッチョGPT プロンプト文字数チェック ==="
echo ""
check_file "$MAIN_FILE" $MAIN_LIMIT "メイン版"
check_file "$GPTS_CORE_FILE" $GPTS_CORE_LIMIT "GPTs コア"
check_file "$GPTS_KNOWLEDGE_FILE" 0 "GPTs ナレッジ"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}全ファイル OK${NC}"
else
    echo -e "${RED}文字数制限を超過しているファイルがあります${NC}"
fi

exit $EXIT_CODE
