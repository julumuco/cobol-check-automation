#!/bin/bash
set -e

echo "🛠 Starting Zowe USS upload operations..."

# Ensure Zowe CLI is in the PATH (fallback if needed)
export PATH="$PATH:$(npm bin -g)"

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Define the target USS directory
USS_DIR="/z/$LOWERCASE_USERNAME/cobol-check-automation/cobol-check"

echo "📂 Target USS directory: $USS_DIR"

# Create the directory if it doesn't exist
if ! zowe zos-files list uss-files "$USS_DIR" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false &>/dev/null; then

    echo "📁 Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$USS_DIR" \
      --user "$ZOWE_USERNAME" \
      --password "$ZOWE_PASSWORD" \
      --host "$ZOWE_HOST" \
      --port "$ZOWE_PORT" \
      --reject-unauthorized false
else
    echo "✅ Directory already exists."
fi

# Upload the cobol-check directory contents recursively
echo "📤 Uploading contents of ./cobol-check to USS..."
zowe zos-files upload dir-to-uss "./cobol-check" "$USS_DIR" \
    --recursive \
    --exclude "bin/cobol-check-0.2.17.jar" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false

# Upload the JAR file separately in binary mode
JAR_PATH="./cobol-check/bin/cobol-check-0.2.17.jar"
if [[ -f "$JAR_PATH" ]]; then
  echo "📦 Uploading $JAR_PATH as binary..."
  zowe zos-files upload file-to-uss "$JAR_PATH" "$USS_DIR/bin/cobol-check-0.2.17.jar" \
      --binary \
      --user "$ZOWE_USERNAME" \
      --password "$ZOWE_PASSWORD" \
      --host "$ZOWE_HOST" \
      --port "$ZOWE_PORT" \
      --reject-unauthorized false
else
  echo "❌ $JAR_PATH not found — skipping binary upload."
fi

# Verify upload
echo "🔍 Verifying uploaded files in $USS_DIR:"
zowe zos-files list uss-files "$USS_DIR" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false

echo "✅ Zowe operations completed successfully."
