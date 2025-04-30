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
    --binary-files "cobolcheck" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false

# Verify upload
echo "🔍 Verifying uploaded files in $USS_DIR:"
zowe zos-files list uss-files "$USS_DIR" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false

echo "✅ Zowe operations completed successfully."
