---
name: cicd-pipeline
description: Set up CI/CD pipelines with GitHub Actions or GitLab CI. Use when automating testing, building, deploying, or implementing DevOps workflows.
---

# CI/CD Pipeline (GitHub Actions)

## When to Use

- Setting up automated testing
- Building and deploying applications
- Automating release processes
- Implementing DevOps workflows

## Input

- Repository structure
- Test requirements
- Deployment target

## Output

- GitHub Actions workflows
- Test configuration
- Build scripts
- Deployment scripts

## Checklist

1. **Workflow Structure**
   - Create .github/workflows/
   - Define triggers (push, PR, schedule)
   - Set up jobs and steps
   - Configure environment variables

2. **Testing**
   - Run unit tests
   - Run integration tests
   - Generate coverage reports
   - Cache dependencies

3. **Building**
   - Build application
   - Build Docker images
   - Push to registry
   - Generate artifacts

4. **Deploying**
   - Deploy to staging
   - Deploy to production
   - Implement rollback
   - Notify team

## Best Practices

- Use reusable workflows
- Cache dependencies
- Use environment protection rules
- Implement secrets management
- Add status badges
- Use matrix builds for multi-platform
- Implement rollback strategy

## Anti-Patterns

❌ No caching
❌ Hardcoded secrets
❌ No test coverage
❌ Skipping security scans
❌ No rollback strategy
❌ Long-running workflows

## Validation

- Tests pass in CI
- Build succeeds
- Deployment works
- Secrets are secure
- Caching improves speed

## Examples

### Example 1: Full CI/CD Workflow
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # Add deployment commands here

      - name: Run smoke tests
        run: |
          echo "Running smoke tests..."
          # Add smoke test commands here

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
          # Add deployment commands here

      - name: Notify team
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚀 Deployed to production: ${{ github.sha }}"
            }
```

### Example 2: PR Validation
```yaml
# .github/workflows/pr-validation.yml
name: PR Validation

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Type check
        run: npm run type-check

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test

      - name: Build
        run: npm run build

      - name: Check bundle size
        uses: andresz1/size-limit-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Example 3: Reusable Workflow
```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
      test-command:
        required: false
        type: string
        default: 'npm test'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: ${{ inputs.test-command }}

# Usage in another workflow:
# jobs:
#   test:
#     uses: ./.github/workflows/reusable-test.yml
#     with:
#       node-version: '20'
```

### Example 4: Environment Protection
```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    
    steps:
      - name: Deploy
        run: |
          echo "Deploying to ${{ environment.url }}..."
```

## GitHub Actions Reference

| Action | Purpose |
|--------|---------|
| actions/checkout | Checkout code |
| actions/setup-node | Setup Node.js |
| actions/cache | Cache dependencies |
| docker/build-push-action | Build Docker images |
| codecov/codecov-action | Upload coverage |

## Secrets Management

```bash
# Add secrets via GitHub CLI
gh secret set DATABASE_URL --body "postgresql://..."

# Use in workflow
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## Output Structure

```
├── .github/
│   └── workflows/
│       ├── ci-cd.yml           # Main CI/CD workflow
│       ├── pr-validation.yml   # PR checks
│       ├── release.yml         # Release workflow
│       └── reusable-*.yml      # Reusable workflows
├── scripts/
│   ├── deploy.sh               # Deployment script
│   └── test.sh                 # Test script
└── Dockerfile                  # Docker build
```
