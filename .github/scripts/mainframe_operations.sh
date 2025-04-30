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
done

echo "✅ Mainframe operations completed"
