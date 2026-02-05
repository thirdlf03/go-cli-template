#!/bin/bash
set -euo pipefail

TEMPLATE_MODULE="github.com/thirdlf03/go-cli-template"
TEMPLATE_BINARY="app"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}Go CLI Template Setup${NC}"
echo "================================"
echo ""

# Gather input
read -rp "Project name (binary name): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    exit 1
fi

read -rp "Go module path (e.g., github.com/user/myapp): " MODULE_PATH
if [ -z "$MODULE_PATH" ]; then
    echo -e "${RED}Error: Module path is required${NC}"
    exit 1
fi

read -rp "Short description [A CLI application]: " DESCRIPTION
DESCRIPTION="${DESCRIPTION:-A CLI application}"

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Project name:  $PROJECT_NAME"
echo "  Module path:   $MODULE_PATH"
echo "  Description:   $DESCRIPTION"
echo ""
read -rp "Proceed? [Y/n] " CONFIRM
if [[ "${CONFIRM:-Y}" =~ ^[Nn] ]]; then
    echo "Aborted."
    exit 0
fi

echo ""

# Detect sed in-place flag (macOS vs GNU/Linux)
if sed --version 2>/dev/null | grep -q GNU; then
    SED_I=(sed -i)
else
    SED_I=(sed -i '')
fi

# 1. Replace module path in all relevant files
echo -e "${GREEN}[1/6] Replacing module path...${NC}"
while IFS= read -r -d '' file; do
    "${SED_I[@]}" "s|${TEMPLATE_MODULE}|${MODULE_PATH}|g" "$file"
done < <(find . -type f \( -name '*.go' -o -name 'go.mod' -o -name 'Makefile' -o -name '*.yaml' -o -name '*.md' \) \
    ! -path './.git/*' ! -name 'setup.sh' -print0)

# 2. Replace binary name
echo -e "${GREEN}[2/6] Updating binary name...${NC}"
"${SED_I[@]}" "s/^BINARY_NAME=.*/BINARY_NAME=${PROJECT_NAME}/" Makefile
"${SED_I[@]}" "s/binary: ${TEMPLATE_BINARY}/binary: ${PROJECT_NAME}/g" .goreleaser.yaml
"${SED_I[@]}" "s/id: ${TEMPLATE_BINARY}/id: ${PROJECT_NAME}/g" .goreleaser.yaml

# 3. Update root command and its test
echo -e "${GREEN}[3/6] Updating root command...${NC}"
"${SED_I[@]}" "s/Use:   \"${TEMPLATE_BINARY}\"/Use:   \"${PROJECT_NAME}\"/" cmd/root.go
ESCAPED_DESC=$(printf '%s\n' "$DESCRIPTION" | sed 's/[&/\]/\\&/g')
"${SED_I[@]}" "s/Short: \"A brief description of your application\"/Short: \"${ESCAPED_DESC}\"/" cmd/root.go
"${SED_I[@]}" "s/\"${TEMPLATE_BINARY}\"/\"${PROJECT_NAME}\"/g" cmd/root_test.go

# 4. Reset CHANGELOG.md
echo -e "${GREEN}[4/6] Resetting CHANGELOG.md...${NC}"
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
EOF

# 5. go mod tidy
echo -e "${GREEN}[5/6] Running go mod tidy...${NC}"
go mod tidy

# 6. Reset git
echo -e "${GREEN}[6/6] Resetting git history...${NC}"
rm -rf .git
git init -q
git add -A
git commit -q -m "Initial commit from go-cli-template"

# Self-destruct
rm -f setup.sh

echo ""
echo -e "${GREEN}Done!${NC} Project '${PROJECT_NAME}' is ready."
echo ""
echo "Next steps:"
echo "  make build    # Build the binary"
echo "  make test     # Run tests"
echo "  make run      # Build and run"
