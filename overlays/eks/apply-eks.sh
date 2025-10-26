#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="petclinic"
OVERLAY_PATH="$(dirname "$0")"

echo ""
echo "Cluster hiện tại: $(kubectl config current-context)"
echo "Bắt đầu triển khai lúc: $(date)"
echo ""

if ! kubectl get nodes &>/dev/null; then
  echo "Không thể kết nối tới EKS cluster. Vui lòng chạy:"
  echo "   aws eks --region ap-southeast-1 update-kubeconfig --name eks-obser-cluster"
  exit 1
fi

echo "[1/4] Xóa namespace cũ nếu tồn tại..."
kubectl delete namespace ${NAMESPACE} --ignore-not-found --grace-period=0 --force || true

echo "[2/4] Chờ namespace cũ bị xóa hoàn toàn..."
while kubectl get ns ${NAMESPACE} &>/dev/null; do
  echo "   → Đang chờ namespace ${NAMESPACE} bị xóa..."
  sleep 2
done

echo "[3/4] Tạo namespace mới..."
kubectl create namespace ${NAMESPACE}

echo " [4/4] Áp dụng manifests từ overlay EKS..."
kubectl apply -k "${OVERLAY_PATH}"

echo ""
echo "Danh sách pods hiện tại:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "Đang chờ ALB được tạo (khoảng 1-2 phút)..."
sleep 90
echo "DNS name của ALB:"
kubectl get ingress -n ${NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'; echo

echo ""
echo " Triển khai thành công overlay EKS cho namespace '${NAMESPACE}'"
echo ""
echo " Trỏ domain (DNS Management) với 2 bản ghi CNAME:"
echo "   tienphatng237.it.com      → <ALB-DNS-NAME>"
echo "   admin.tienphatng237.it.com → <ALB-DNS-NAME>"
echo ""
echo " Truy cập sau khi DNS cập nhật:"
echo "   https://tienphatng237.it.com"
echo "   https://admin.tienphatng237.it.com"
