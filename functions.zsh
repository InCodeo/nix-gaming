# Shared git update function
function _nix_update_git() {
    local repo_path="$1"
    cd "$repo_path" || return 1
    git pull origin main || return 1
    return 0
}

# Update git repository without building
function nixpull() {
    echo "🔄 Pulling NixOS configuration..."
    if ! _nix_update_git "/etc/nixos"; then
        echo "❌ Git pull failed"
        return 1
    fi
    echo "✅ Pull complete"
    return 0
}

# Build NixOS configuration
function nixbuild() {
    local build_only=${1:-false}
    
    if ! nixpull; then
        return 1
    fi
    
    echo "🔨 Building NixOS configuration..."
    if [ "$build_only" = true ]; then
        sudo nixos-rebuild build || { echo "❌ Build failed"; return 1; }
    else
        sudo nixos-rebuild switch || { echo "❌ Build failed"; return 1; }
    fi
    
    echo "✅ Build complete"
    return 0
}

# Test NixOS configuration
function nixtest() {
    if ! nixpull; then
        return 1
    fi
    
    echo "🧪 Testing NixOS configuration..."
    
    # Build without switching
    if ! nixbuild true; then
        echo "❌ Test build failed"
        return 1
    fi
    
    # Test if configuration evaluates
    if ! nix-env -qa --file /etc/nixos/configuration.nix; then
        echo "❌ Configuration evaluation failed"
        return 1
    fi
    
    echo "✅ All tests passed"
    return 0
}

# Full update with build and switch
function nixup() {
    if ! nixpull; then
        return 1
    fi
    
    if ! nixbuild; then
        echo "❌ Build failed"
        return 1
    fi
    
    echo "✅ System update complete"
    return 0
}

# Combined update, test and build
function nixfull() {
    if ! nixpull; then
        return 1
    fi
    
    if ! nixtest; then
        echo "❌ Tests failed"
        return 1
    fi
    
    if ! nixbuild; then
        echo "❌ Build failed"
        return 1
    fi
    
    echo "✅ Full system update complete"
    return 0
}

# Usage examples:
# Just pull:
#   nixpull
#
# Pull and test:
#   nixtest
#
# Pull and build without switching (dry-run):
#   nixbuild true
#
# Pull, build and switch:
#   nixbuild
#
# Full update with tests:
#   nixfull
#
# Quick update:
#   nixup