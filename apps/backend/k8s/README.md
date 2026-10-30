# Deploy to the homelab k3s

The backend runs in the `ambrogio` namespace and is reachable at
`https://api-ambrogio.mircoporetti.me` through the main Cloudflare tunnel
(`homelab/infrastructure/cloudflare/configmap.yaml`). Photos go to the
`ambrogio-photos` R2 bucket.

Each push to `main` that touches the backend runs
`.github/workflows/deploy-backend.yml`. GitHub-hosted runners test it and
push `ghcr.io/mircoporetti/ambrogio-backend:<commit>`. Then a self-hosted
runner on the control plane runs `kubectl apply -k` with that tag.

The pods are pinned to amd64 nodes because the image is built for amd64 only.

## One-time setup

### 1. Cloudflare R2

In the Cloudflare dashboard, under R2:

1. Create the bucket `ambrogio-photos`. It stays private.
2. Manage API tokens → create a token with **Object Read & Write**, limited
   to that bucket. Note its access key id and secret, and the S3 endpoint
   `https://<account id>.r2.cloudflarestorage.com`.

### 2. Secrets in the cluster

`secrets.example.yaml` lists every key with a placeholder. Copy it to
`secrets.yaml`, which is gitignored, fill it in and apply it by hand:

```sh
cd apps/backend/k8s
cp secrets.example.yaml secrets.yaml   # then replace the <placeholders>
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
```

The secret isn't part of `kustomization.yaml`, so a deploy never replaces
it. Keep a copy of `secrets.yaml` in your password manager: without
`DB_PASSWORD` the backend can't reach the existing database.

Postgres sets its password from `DB_PASSWORD` only when it creates the
database the first time. After that, changing the secret needs a matching
`ALTER USER ambrogio PASSWORD '...'` inside Postgres.

Changing `JWT_SECRET` logs every user out at their next request.

### 3. GitHub runner

The deploy job runs on `[self-hosted, linux, ambrogio]`. A runner registered
to the `sensebuilding-uk` org can't serve this personal repo, so add a second
one on `dumbledore`, next to the existing one:

1. GitHub → this repo → Settings → Actions → Runners → New self-hosted
   runner → Linux, ARM64. Copy the token from the page.
2. On `dumbledore`, in a new folder (not the SB runner's):

   ```sh
   mkdir ~/actions-runner-ambrogio && cd ~/actions-runner-ambrogio
   # download and extract the runner as shown on the GitHub page, then:
   ./config.sh --url https://github.com/mircoporetti/ambrogio-grocery \
     --token <token> --name dumbledore-ambrogio --labels ambrogio --unattended
   sudo ./svc.sh install && sudo ./svc.sh start
   ```

3. The runner needs `kubectl` and a kubeconfig it can read, the same one the
   SB runner uses.

The repo is public, so only run workflows from your own branches on it.
Settings → Actions → General → "Require approval for all external
contributors" keeps forks off this runner.

### 4. GitHub environment

Settings → Environments → create `Production`, then add:

| Name | Kind | Value |
|---|---|---|
| `KUBECONFIG_PATH` | variable | path of the kubeconfig on `dumbledore` |

No other secrets are needed. The workflow pushes to GHCR with the built-in
`GITHUB_TOKEN`.

After the first push, make the package public: GitHub → your profile →
Packages → `ambrogio-backend` → Package settings → Change visibility →
Public. Until then the cluster can't pull the image without a pull secret.

### 5. Tunnel and DNS

The route is in `homelab/infrastructure/cloudflare/configmap.yaml`. Apply it
and restart cloudflared, then add the DNS record:

```sh
kubectl apply -f infrastructure/cloudflare/configmap.yaml
kubectl -n cloudflared rollout restart deployment cloudflared
cloudflared tunnel route dns b7f8cb31-94fe-4760-b7ee-b04b097349f3 api-ambrogio.mircoporetti.me
```

Or in the dashboard: DNS → CNAME `api-ambrogio` →
`b7f8cb31-94fe-4760-b7ee-b04b097349f3.cfargotunnel.com`, proxied.

### 6. Rate limit the login

bcrypt makes each login cost CPU, and the server has no rate limit of its
own. Under Security → WAF → Rate limiting rules, add a rule for host
`api-ambrogio.mircoporetti.me` with method `POST` and path `/sessions` or
`/accounts`: block for 10 minutes after 10 requests per minute from the same
IP.

## Deploy

Push to `main`, or run the workflow by hand (Actions → Deploy backend → Run
workflow). By hand from a laptop:

```sh
cd apps/backend/k8s
kubectl kustomize . | sed "s/ambrogio-backend:latest/ambrogio-backend:<commit sha>/" | kubectl apply -f -
```

Roll back to the previous version:

```sh
kubectl -n ambrogio rollout undo deployment/backend
```

A rollback doesn't undo a database migration. The previous version must
still work with the newer schema.

## Mobile app

Release builds point at the deployed backend:

```sh
flutter build apk --release --dart-define=API_URL=https://api-ambrogio.mircoporetti.me
flutter run --release -d <iPhone id> --dart-define=API_URL=https://api-ambrogio.mircoporetti.me
```

## Check

```sh
curl https://api-ambrogio.mircoporetti.me/health
kubectl -n ambrogio get pods
kubectl -n ambrogio logs deployment/backend --tail=100
```

## Data

There is no backup yet. The database lives only on the `postgres-data`
volume (`longhorn-sc`, two replicas on the two workers). Its reclaim policy
is `Delete`: deleting the PVC or the namespace deletes every account,
recipe and list for good. Phones keep their local copy until they log out.
