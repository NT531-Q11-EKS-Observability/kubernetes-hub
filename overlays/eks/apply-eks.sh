#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="petclinic"
OVERLAY_PATH="$(dirname "$0")"
BASE_PATH="${OVERLAY_PATH}/../../base"

echo ""
echo "=============================================================="
echo " Triển khai ứng dụng Petclinic lên EKS (HPA + TSC Enabled)"
echo "=============================================================="
echo ""
echo "Cluster hiện tại: $(kubectl config current-context)"
echo "Bắt đầu triển khai lúc: $(date)"
echo ""

# Kiểm tra kết nối với EKS cluster
if ! kubectl get nodes &>/dev/null; then
  echo "❌ Không thể kết nối tới EKS cluster!"
  echo "👉 Vui lòng chạy lệnh sau trước khi tiếp tục:"
  echo "   aws eks --region ap-southeast-1 update-kubeconfig --name eks-obser-cluster"
  exit 1
fi

# Bước 1. Xóa namespace cũ nếu tồn tại
echo "[1/6] 🧹 Xóa namespace cũ (nếu có): ${NAMESPACE}"
kubectl delete namespace ${NAMESPACE} --ignore-not-found --grace-period=0 --force || true

echo "[2/6] ⏳ Chờ namespace cũ bị xóa hoàn toàn..."
while kubectl get ns ${NAMESPACE} &>/dev/null; do
  echo "   → Đang chờ namespace ${NAMESPACE} bị xóa..."
  sleep 2
done

# Bước 2. Tạo namespace mới
echo "[3/6] 🏗️  Tạo namespace mới..."
kubectl create namespace ${NAMESPACE}

# Bước 3. Áp dụng các manifest chính
echo "[4/6] 🚀 Triển khai toàn bộ ứng dụng và cấu hình cơ bản..."
kubectl apply -k "${OVERLAY_PATH}"

# Bước 4. Áp dụng Horizontal Pod Autoscaler (HPA)
echo "[5/6] ⚙️  Áp dụng cấu hình Auto Scaling (HPA)..."
kubectl apply -f "${BASE_PATH}/hpa/hpa-all.yaml"

# Bước 5. Áp dụng Topology Spread Constraints (TSC)
echo "[6/6] 🧩 Áp dụng cấu hình Topology Spread Constraints (TSC)..."
kubectl apply -f "${BASE_PATH}/tsc/"

echo ""
echo "=============================================================="
echo "✅ Danh sách Pods hiện tại:"
kubectl get pods -n ${NAMESPACE}
echo ""

echo "Đang chờ ALB được tạo (khoảng 1-2 phút)..."
sleep 90

ALB_DNS=$(kubectl get ingress -n ${NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
echo ""
echo "🌐 DNS name của ALB:"
echo "   ${ALB_DNS}"
echo ""
echo "=============================================================="
echo "🎉 Triển khai thành công overlay EKS cho namespace '${NAMESPACE}'"
echo ""
echo "👉 Hãy trỏ domain (DNS Management) với 2 bản ghi CNAME:"
echo "   tienphatng237.it.com      → ${ALB_DNS}"
echo "   admin.tienphatng237.it.com → ${ALB_DNS}"
echo ""
echo "🌎 Truy cập sau khi DNS cập nhật:"
echo "   https://tienphatng237.it.com"
echo "   https://admin.tienphatng237.it.com"
echo "=============================================================="
echo ""
