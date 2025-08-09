#!/bin/bash
set -e

echo "🔐 Setting up ArgoCD private repository access..."

# Read the private key
PRIVATE_KEY=$(cat ~/.ssh/argocd_rsa)

# Create the secret with the actual private key
cat <<EOF | sudo kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: zforums-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: git@github.com:rohitmr619/ZForums.git
  sshPrivateKey: |
$(echo "$PRIVATE_KEY" | sed 's/^/    /')
EOF

echo "✅ Private repository secret created!"
echo ""
echo "📋 Next steps:"
echo "1. Copy this public key and add it to GitHub as a Deploy Key:"
echo ""
cat ~/.ssh/argocd_rsa.pub
echo ""
echo "2. Go to: https://github.com/rohitmr619/ZForums/settings/keys"
echo "3. Click 'Add deploy key'"
echo "4. Title: 'ArgoCD Deploy Key'"
echo "5. Paste the public key above"
echo "6. ✅ Check 'Allow write access' (optional)"
echo ""
echo "🔄 Then update the ArgoCD Application to use SSH URL"
