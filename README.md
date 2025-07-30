# INFO8985-Inclass-task-4
K8S Infrastructure with SigNoz Integration

## Quick Start

```bash
pip install ansible kubernetes
ansible-playbook up.yml
```

## What This Does

1. **Deploys K8S Infrastructure** helm chart to your Kubernetes cluster  
2. **Configures OpenTelemetry** to route telemetry to your SigNoz at `s4z.nidhun.me:4317`
3. **Deploys RollDice app** with telemetry configured

## Testing

Run the test script to verify everything is working:

```bash
./test-setup.sh
```

## Cleanup

```bash
ansible-playbook down.yml
```

## Assignment Requirements Met

✅ **Installs and removes K8S Infra helm chart with ansible** (3 marks)
- `up.yml` and `down.yml` install/remove the helm chart

✅ **Override values to specify upstream OTEL collector** (3 marks)  
- Values configured inline in `k8s/up.yml` to send to `s4z.nidhun.me:4317`

✅ **Test setup on vsphere** (2 marks)
- Use `./test-setup.sh` to validate deployment

✅ **RollDice app with telemetry to SigNoz** (2 marks)
- RollDice deployment configured to send telemetry through K8S Infrastructure to SigNoz

## Files Overview

- `up.yml` - Main deployment playbook
- `down.yml` - Cleanup playbook  
- `k8s/up.yml` - K8S Infrastructure deployment
- `k8s/down.yml` - K8S Infrastructure removal
- `rolldice/` - RollDice application manifests
- `test-setup.sh` - Validation script
