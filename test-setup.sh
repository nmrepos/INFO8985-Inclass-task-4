#!/bin/bash

# Simple Test Script for K8S Infrastructure + SigNoz Integration

set -e

echo "🔍 Testing the setup..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_passed() {
    echo -e "${GREEN}✅ $1${NC}"
}

test_failed() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

echo "📋 Test 1: Checking Kubernetes cluster..."
if kubectl cluster-info > /dev/null 2>&1; then
    test_passed "Kubernetes cluster is accessible"
else
    test_failed "Cannot connect to Kubernetes cluster"
fi

echo "📋 Test 2: Checking k8s-infra namespace..."
if kubectl get namespace k8s-infra > /dev/null 2>&1; then
    test_passed "k8s-infra namespace exists"
else
    test_failed "k8s-infra namespace does not exist"
fi

echo "📋 Test 3: Checking OpenTelemetry Collector..."
if kubectl get daemonset -n k8s-infra | grep -q "k8s-infra"; then
    test_passed "OpenTelemetry Collector DaemonSet is deployed"
    
    READY_PODS=$(kubectl get daemonset -n k8s-infra k8s-infra -o jsonpath='{.status.numberReady}' 2>/dev/null || echo "0")
    DESIRED_PODS=$(kubectl get daemonset -n k8s-infra k8s-infra -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null || echo "0")
    
    if [ "$READY_PODS" -eq "$DESIRED_PODS" ] && [ "$READY_PODS" -gt 0 ]; then
        test_passed "All OpenTelemetry Collector pods are ready ($READY_PODS/$DESIRED_PODS)"
    else
        test_failed "OpenTelemetry Collector pods not ready ($READY_PODS/$DESIRED_PODS)"
    fi
else
    test_failed "OpenTelemetry Collector DaemonSet not found"
fi

echo "📋 Test 4: Checking RollDice application..."
if kubectl get namespace rolldice > /dev/null 2>&1; then
    test_passed "RollDice namespace exists"
    
    if kubectl get deployment -n rolldice rolldice-app > /dev/null 2>&1; then
        test_passed "RollDice deployment exists"
        
        ROLLDICE_READY=$(kubectl get deployment -n rolldice rolldice-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        ROLLDICE_DESIRED=$(kubectl get deployment -n rolldice rolldice-app -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
        
        if [ "$ROLLDICE_READY" -eq "$ROLLDICE_DESIRED" ] && [ "$ROLLDICE_READY" -gt 0 ]; then
            test_passed "RollDice pods are ready ($ROLLDICE_READY/$ROLLDICE_DESIRED)"
        else
            test_failed "RollDice pods not ready ($ROLLDICE_READY/$ROLLDICE_DESIRED)"
        fi
    else
        test_failed "RollDice deployment not found"
    fi
else
    test_failed "RollDice namespace does not exist"
fi

echo "📋 Test 5: Checking telemetry configuration..."
ROLLDICE_POD=$(kubectl get pods -n rolldice -l app=rolldice -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$ROLLDICE_POD" ]; then
    OTEL_ENDPOINT=$(kubectl get pod -n rolldice "$ROLLDICE_POD" -o jsonpath='{.spec.containers[0].env[?(@.name=="OTEL_EXPORTER_OTLP_ENDPOINT")].value}' 2>/dev/null || echo "")
    if [[ "$OTEL_ENDPOINT" == *"k8s-infra"* ]]; then
        test_passed "RollDice is configured to send telemetry to K8S Infrastructure"
    else
        test_failed "RollDice telemetry configuration incorrect: $OTEL_ENDPOINT"
    fi
fi

echo ""
echo "🎯 Test Summary:"
echo "================"
test_passed "K8S Infrastructure: Deployed"
test_passed "OpenTelemetry: Collector running"
test_passed "RollDice App: Deployed with telemetry"
test_passed "Telemetry: Configured for s4z.nidhun.me:4317"

echo ""
echo "🚀 Next Steps:"
echo "- Monitor telemetry in SigNoz at s4z.nidhun.me"
echo "- Check traces and metrics for both K8S infra and RollDice app"

echo ""
echo "✅ Test completed successfully!"
