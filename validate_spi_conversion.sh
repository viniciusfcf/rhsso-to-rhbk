#!/bin/bash

# Script to validate SPI conversion from RHSSO to RHBK
# Usage: ./validate_spi_conversion.sh <spi_directory>

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <spi_directory>"
  exit 1
fi

SPI_DIR="$1"

# Ensure the directory exists
if [ ! -d "$SPI_DIR" ]; then
  echo "Error: Directory $SPI_DIR does not exist."
  exit 1
fi

# Navigate to the SPI directory
cd "$SPI_DIR" || exit 1

# Step 1: Check for Java EE dependencies using Maven dependency:tree
echo "Checking for Java EE dependencies in Maven dependency tree..."
mvn dependency:tree | grep -E "javax\.ejb|javax\.jms|javax\.annotation|javax\.persistence|lombok" > java_dependencies.txt

if [ -s java_dependencies.txt ]; then
  echo "${RED}Java dependencies found (see java_dependencies.txt):${NORMAL}"
  cat java_dependencies.txt
  echo "---"
else
  echo "No Java EE dependencies found."
  rm -f java_dependencies.txt
fi


# Step 2: Check for incompatible imports in Java files
echo "Checking for incompatible imports in Java files..."
find . -name "*.java" | xargs grep -nE "import java\.lang\.reflect" > incompatible_imports.txt

if [ -s incompatible_imports.txt ]; then
  echo "${RED}Incompatible imports found (see incompatible_imports.txt):${NORMAL}"
  cat incompatible_imports.txt
  echo "---"
else
  echo "No incompatible imports found."
  rm -f incompatible_imports.txt
fi


# Final summary
echo "Validation completed. Check the generated files for details if issues were found."
