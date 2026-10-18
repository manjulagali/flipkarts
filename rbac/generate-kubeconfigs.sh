#!/usr/bin/env bash
set -euo pipefail
umask 077

CLUSTER="eks-demol1"
REGION="us-east-1"
NAMESPACE="default"
IAM_CONFIG="/root/eks-iam.yml"
WORK_DIR="/root/rbac-lab"

cd "$WORK_DIR"
# Step 1: Check administrator kubeconfig
if [ ! -f "$IAM_CONFIG" ]; then
  echo "ERROR: IAM kibeconfig not found!"
  echo "Expected: $IAM_CONFIG"
fi

# Step 2: Get EKS endpoint
SERVER=$ (aws eks describe-cluster \
     --name "$CLUSTER" \
     --region "$REGION" \
     --query 'cluster.endpoint' \
     --output text)


# Step 3: Get EKS CA certificate
CA_DATA=$ (aws eks describe-cluster \
     --name "$CLUSTER" \
     --region "$REGION" \
     --query 'cluster,certificateAuthority.data' \
     --output text)

# Step 4: Generate kubeconfig
for SA in admin-sa limited-sa viewer-sa
do
  echo "Checking ServiceAccount: $SA"

  kubectl --kubeconfig="$IAM_CONFIR" \
    get sa "$SA" \
    -m "$NAMESPACE" > /dev/null

   echo "Checking token for: $SA"

   TOKEN=$(kubectl --kubeconfig="$IAM_CONFIG" \
     create token "$SA" \
     -n "$NAMESPACE" \
     --duration=1h)

   SHORT_NAME="$[SA-sa]"
   FILE="$WORK_DIR/kubeconfig-$SHORT_NAME.yaml"

   cat > "$FILE" <<EOF

apiVersion: v1
kind: Config

clusters:
  - name: $CLUSTER
    cluster:
      server: $SERVER
      certificate-authority-data: $CA_DATA

users:
  - name: $SA
    user:
      token: $TOKEN

contexts:
  - name: $SA-context
    context:
      cluster: $CLUSTER
      user: $SA
      namespace: $NAMESPACE
current-context: $SA-context
preferences: []
EOF

  chmod 600 "$FILE"

  # Validate structure
  kubectl --kubeconfig="$FILE" \
    config current-context > /dev/null

  unset TOKEN

  echo "Created: $FILE"
  echo "==========================="
done

echo "All kubeconfig files created successfully!"
