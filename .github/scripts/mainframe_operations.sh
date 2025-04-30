#!/bin/bash
set -e

echo "🔧 Starting mainframe COBOL check operations..."

# Navigate into the correct folder
if [[ -d "cobol-check" ]]; then
  cd cobol-check
  echo "📂 Changed to $(pwd)"
else
  echo "❌ 'cobol-check' directory not found"
  exit 1
fi

# Make sure the cobolcheck script is there
if [[ -f "cobolcheck" ]]; then
  chmod +x cobolcheck
  echo "✅ Made 'cobolcheck' executable"
else
  echo "❌ 'cobolcheck' script not found"
  exit 1
fi

# If a scripts folder exists, handle its script
if [[ -f "scripts/linux_gnucobol_run_tests" ]]; then
  chmod +x scripts/linux_gnucobol_run_tests
  echo "✅ Made 'linux_gnucobol_run_tests' executable"
else
  echo "ℹ️ 'scripts/linux_gnucobol_run_tests' not found — skipping"
fi

# Run COBOL Check for each program
for program in NUMBERS EMPPAY DEPTPAY; do
  echo "🚀 Running cobolcheck for $program"
  ./cobolcheck -p "$program" || echo "⚠️ cobolcheck failed for $program"

  # Check output file
  if [[ -f "CC##99.CBL" ]]; then
    echo "✅ Found CC##99.CBL for $program"
  else
    echo "❌ CC##99.CBL not found for $program"
  fi

  if [[ -f "${program}.JCL" ]]; then
    echo "✅ Found ${program}.JCL"
  else
    echo "❌ ${program}.JCL not found"
  fi

echo "ZOWE_USERNAME = $ZOWE_USERNAME"
echo "program = $program" 

# Truncate or Normalize Imputs
DSNAME_PROGRAM=$(echo "$program" | cut -c1-8)
# DSNAME_USER=$(echo "$ZOWE_USERNAME" | cut -c1-8)
# Upload the generated COBOL test file to MVS
if [[ -f "CC##99.CBL" ]]; then
  zowe zos-files upload file-to-data-set "CC##99.CBL" "${ZOWE_USERNAME}.CBL(${DSNAME_PROGRAM})" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false
  echo "📤 Uploaded CC##99.CBL to ${ZOWE_USERNAME}.CBL(${DSNAME_PROGRAM})"
else
  echo "❌ CC##99.CBL not found — skipping COBOL upload for $program"
fi

# Upload the existing JCL to MVS
if [[ -f "${program}.JCL" ]]; then
  zowe zos-files upload file-to-data-set "${program}.JCL" "//${ZOWE_USERNAME}.JCL(${DSNAME_PROGRAM})" \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --host "$ZOWE_HOST" \
    --port "$ZOWE_PORT" \
    --reject-unauthorized false
  echo "📤 Uploaded ${program}.JCL to ${ZOWE_USERNAME}.JCL(${DSNAME_PROGRAM})"
else
  echo "❌ ${program}.JCL not found — cannot upload to MVS"
fi

done

echo "✅ Mainframe operations completed"
