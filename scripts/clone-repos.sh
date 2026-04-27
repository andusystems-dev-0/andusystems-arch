#!/usr/bin/env bash
set -euo pipefail

FORGEJO_HOST="https://forgejo.andusystems.com"
FORGEJO_OWNER="andusystems"
DEST="$HOME/andusystems"

REPOS=(
    andusystems-portfolio
    Portfolio
    andusystems-monitoring
    andusystems-dispatch
    andusystems-management
    andusystems-storage
    andusystems-networking
    andusystems-sentinel
    andusystems-arch
)

read -rp "Forgejo username: " FORGEJO_USER
read -rsp "Forgejo password: " FORGEJO_PASS
echo
export FORGEJO_USER FORGEJO_PASS

HELPER_SCRIPT="$(mktemp)"
trap 'rm -f "$HELPER_SCRIPT"' EXIT
cat > "$HELPER_SCRIPT" <<'EOF'
#!/usr/bin/env bash
[ "$1" = "get" ] || exit 0
printf 'username=%s\n' "$FORGEJO_USER"
printf 'password=%s\n' "$FORGEJO_PASS"
EOF
chmod 700 "$HELPER_SCRIPT"

mkdir -p "$DEST"

for repo in "${REPOS[@]}"; do
    target="$DEST/$repo"
    if [ -e "$target" ]; then
        echo "skip $repo: $target already exists"
        continue
    fi
    echo "clone $repo -> $target"
    git -c credential.helper= \
        -c "credential.helper=$HELPER_SCRIPT" \
        clone "$FORGEJO_HOST/$FORGEJO_OWNER/$repo.git" "$target"
done
