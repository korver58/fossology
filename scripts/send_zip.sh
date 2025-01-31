#!/bin/bash

# 引数のチェック
if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <URL_API> <TOKEN> <FOSS_FOLDER_NAME> <UPLOAD_FILE>"
  exit 1
fi

# 引数の設定
URL_API=$1
TOKEN=$2
FOSS_FOLDER_NAME=$3
UPLOAD_FILE=$4

# アップロードファイルの存在確認
if [[ ! -f "${UPLOAD_FILE}" ]]; then
    echo "エラー: ファイル '${UPLOAD_FILE}' が見つかりません"
    exit 1
fi

echo "=== フォルダ一覧を取得中 ==="
FOLDERS_RESPONSE=$(curl -sS -X GET ${URL_API}/folders -H "Authorization: Bearer ${TOKEN}")
if [[ $(echo "${FOLDERS_RESPONSE}" | jq -r 'type') == "object" && $(echo "${FOLDERS_RESPONSE}" | jq 'has("error")') == "true" ]]; then
    echo "エラー: フォルダ一覧の取得に失敗しました"
    echo "${FOLDERS_RESPONSE}" | jq
    exit 1
fi
echo "${FOLDERS_RESPONSE}" | jq

echo "=== フォルダを作成中: ${FOSS_FOLDER_NAME} ==="
FOLDER_CREATE_RESPONSE=$(curl -sS -X POST ${URL_API}/folders \
    -H "parentFolder: 1" \
    -H "folderName: ${FOSS_FOLDER_NAME}" \
    -H "Authorization: Bearer ${TOKEN}")
if [[ $(echo "${FOLDER_CREATE_RESPONSE}" | jq -r 'type') == "object" && $(echo "${FOLDER_CREATE_RESPONSE}" | jq 'has("error")') == "true" ]]; then
    echo "警告: フォルダの作成に失敗しました（既に存在する可能性があります）"
fi
echo "${FOLDER_CREATE_RESPONSE}" | jq

echo "=== フォルダIDを取得中 ==="
FOLDER_ID=$(curl -sS -X GET ${URL_API}/folders \
    -H "Authorization: Bearer ${TOKEN}" | jq -r ".[] | select(.name==\"${FOSS_FOLDER_NAME}\") | .id")

if [[ -z "${FOLDER_ID}" ]]; then
    echo "エラー: フォルダID の取得に失敗しました"
    exit 1
fi
echo "対象フォルダID: ${FOLDER_ID}"

echo "=== ファイルをアップロード中: ${UPLOAD_FILE} ==="
UPLOAD_RESPONSE=$(curl -sS -X POST ${URL_API}/uploads \
    -H "folderId: ${FOLDER_ID}" \
    -H "uploadDescription: created by REST" \
    -H "uploadType: file" \
    -H "public: public" \
    -H "Content-Type: multipart/form-data" \
    -F "fileInput=@${UPLOAD_FILE};type=application/x-zip-compressed" \
    -H "Authorization: Bearer ${TOKEN}")

if [[ $(echo "${UPLOAD_RESPONSE}" | jq -r 'type') == "object" && $(echo "${UPLOAD_RESPONSE}" | jq 'has("error")') == "true" ]]; then
    echo "エラー: ファイルのアップロードに失敗しました"
    echo "${UPLOAD_RESPONSE}" | jq
    exit 1
fi
echo "${UPLOAD_RESPONSE}" | jq

echo "=== 処理が正常に完了しました ==="
