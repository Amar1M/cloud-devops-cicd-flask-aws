#!/bin/bash
# Manual deployment script for EC2
# Usage: ./scripts/deploy.sh [dockerhub_username/image_name]

set -e

IMAGE=${1:-amardevops/flask-devops-app:latest}
CONTAINER_NAME="flask-devops-app"

echo "=== Manual Deployment ==="
echo "Image: $IMAGE"
echo "Container: $CONTAINER_NAME"

# Pull latest image
echo "Pulling latest image..."
docker pull $IMAGE

# Stop and remove old container
echo "Stopping old container..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Run new container
echo "Starting new container..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p 5000:5000 \
  -e APP_VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "manual") \
  -e BUILD_NUMBER=manual \
  -e GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "manual") \
  -e ENVIRONMENT=production \
  $IMAGE

# Wait and check health
echo "Waiting 10s for app to start..."
sleep 10

echo "Checking health..."
curl -f http://localhost:5000/health && echo "✅ Health check passed" || echo "❌ Health check failed"

echo "Logs:"
docker logs $CONTAINER_NAME --tail 20

echo ""
echo "=== Deployment complete ==="
echo "App running at http://localhost:5000"
echo "To expose on port 80: sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 5000"
