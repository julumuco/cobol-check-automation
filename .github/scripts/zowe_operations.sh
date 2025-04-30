#!/bin/bash
set -e

echo "🛠 Starting Zowe USS upload operations..."
export PATH="$PATH:$(npm bin -g)"
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
USS_DIR="/z/$LOWERCASE_USERNAME/cobol-check-automation/cobol-check"
JAR_FILE="./cobol-check/bin/cobol-check-0.2.17.jar"

# Create USS dir if not exists
if ! zowe zos-files list uss-files "$USS_DIR" --user "$ZOWE_USERNAME" --password "$ZOWE_PASSWORD" --host "$ZOWE_HOST" --port "$ZOWE_PORT" --reject-unauthorized false &>/dev/null; then
  echo "📁 Creating USS directory: $USS_DIR"
  zowe zos-files create uss-directory "$USS_DIR" --user "$ZOWE_USERNAME" --password "$ZOWE_PASSWORD" --host "$ZOWE_HOST" --port "$ZOWE_PORT" --reject-unauthorized false
else
  echo "✅ Directory already exists: $USS_DIR"
fi

# Upload all files except the JAR
echo "📂 Uploading files from cobol-check/ excluding the .jar"
for file in $(find ./cobol-check -type f ! -name "$(basename "$JAR_FILE")"); do
  REL_PATH="${file#./cobol-check/}"
  echo "➡️ Uploading text file: $file → $USS_DIR/$REL_PATH"
  zowe zos-files upload file-to-uss "$file" "$USS_DIR/$REL_PATH" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false
done

# Upload the JAR file separately in binary mode
if [[ -f "$JAR_FILE" ]]; then
  echo "📦 Uploading JAR as binary: $JAR_FILE"
  zowe zos-files upload file-to-uss "$JAR_FILE" "$USS_DIR/bin/$(basename "$JAR_FILE")" \
    --binary \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false
else
  echo "❌ JAR file not found: $JAR_FILE"
fi

echo "✅ Zowe upload completed successfully."
