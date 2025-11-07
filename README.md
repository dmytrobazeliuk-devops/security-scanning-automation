# Security Scanning Automation

Automated security scanning pipeline integrating Trivy, Bandit, Safety, and npm audit. Scans Docker images, code repositories, and dependencies for vulnerabilities with automated reporting.

## Features

- **Multi-Tool Scanning**: Trivy, Bandit, Safety, npm audit
- **Docker Support**: Scan Docker images and filesystems
- **Kubernetes Support**: Scan K8s manifests and clusters
- **Automated Reporting**: JSON and text format reports
- **CI/CD Integration**: Ready for GitHub Actions and GitLab CI

## Tools

- **Trivy**: Container and filesystem vulnerability scanning
- **Bandit**: Python security linter
- **Safety**: Python dependency vulnerability scanner
- **npm audit**: Node.js dependency vulnerability scanner

## Usage

### Run scan script

```bash
chmod +x scan.sh
./scan.sh
```

### Scan Docker image

```bash
DOCKER_IMAGE=myapp:latest ./scan.sh
```

### Using Docker Compose

```bash
docker-compose up
```

## Output

Scan results are saved to `scan-results/` directory:

- `docker-scan.json` / `docker-scan.txt`
- `fs-scan.json` / `fs-scan.txt`
- `k8s-scan.json` / `k8s-scan.txt`
- `bandit-scan.json` / `bandit-scan.txt`
- `npm-audit.json` / `npm-audit.txt`
- `safety-scan.json` / `safety-scan.txt`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Author

**Dmytro Bazeliuk**
- Portfolio: https://devsecops.cv
- GitHub: [@dmytrobazeliuk-devops](https://github.com/dmytrobazeliuk-devops)
