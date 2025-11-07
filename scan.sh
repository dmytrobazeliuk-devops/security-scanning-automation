#!/bin/bash
# Automated Security Scanning Script
# Scans Docker images, code repositories, and infrastructure for vulnerabilities

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCAN_DIR="${SCAN_DIR:-.}"
OUTPUT_DIR="${OUTPUT_DIR:-./scan-results}"
DOCKER_IMAGE="${DOCKER_IMAGE:-}"
TRIVY_CACHE_DIR="${TRIVY_CACHE_DIR:-./.trivy-cache}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Starting security scan...${NC}"

# Function to scan Docker image
scan_docker_image() {
    if [ -z "$DOCKER_IMAGE" ]; then
        echo -e "${YELLOW}Skipping Docker image scan (DOCKER_IMAGE not set)${NC}"
        return
    fi
    
    echo -e "${GREEN}Scanning Docker image: $DOCKER_IMAGE${NC}"
    trivy image --format json --output "$OUTPUT_DIR/docker-scan.json" "$DOCKER_IMAGE"
    trivy image --format table --output "$OUTPUT_DIR/docker-scan.txt" "$DOCKER_IMAGE"
    echo -e "${GREEN}Docker scan completed${NC}"
}

# Function to scan filesystem
scan_filesystem() {
    echo -e "${GREEN}Scanning filesystem: $SCAN_DIR${NC}"
    trivy fs --format json --output "$OUTPUT_DIR/fs-scan.json" "$SCAN_DIR"
    trivy fs --format table --output "$OUTPUT_DIR/fs-scan.txt" "$SCAN_DIR"
    echo -e "${GREEN}Filesystem scan completed${NC}"
}

# Function to scan Kubernetes manifests
scan_kubernetes() {
    if [ ! -d "kubernetes" ] && [ ! -d "k8s" ]; then
        echo -e "${YELLOW}Skipping Kubernetes scan (no k8s manifests found)${NC}"
        return
    fi
    
    echo -e "${GREEN}Scanning Kubernetes manifests${NC}"
    trivy k8s cluster --format json --output "$OUTPUT_DIR/k8s-scan.json" || true
    trivy k8s cluster --format table --output "$OUTPUT_DIR/k8s-scan.txt" || true
    echo -e "${GREEN}Kubernetes scan completed${NC}"
}

# Function to run Bandit (Python security scanner)
scan_python() {
    if ! command -v bandit &> /dev/null; then
        echo -e "${YELLOW}Bandit not installed, skipping Python scan${NC}"
        return
    fi
    
    if find "$SCAN_DIR" -name "*.py" | grep -q .; then
        echo -e "${GREEN}Scanning Python code with Bandit${NC}"
        bandit -r "$SCAN_DIR" -f json -o "$OUTPUT_DIR/bandit-scan.json" || true
        bandit -r "$SCAN_DIR" -f txt -o "$OUTPUT_DIR/bandit-scan.txt" || true
        echo -e "${GREEN}Python scan completed${NC}"
    fi
}

# Function to run npm audit
scan_npm() {
    if [ -f "package.json" ]; then
        echo -e "${GREEN}Scanning npm dependencies${NC}"
        npm audit --json > "$OUTPUT_DIR/npm-audit.json" || true
        npm audit > "$OUTPUT_DIR/npm-audit.txt" || true
        echo -e "${GREEN}npm audit completed${NC}"
    fi
}

# Function to run safety (Python dependencies)
scan_python_deps() {
    if ! command -v safety &> /dev/null; then
        echo -e "${YELLOW}Safety not installed, skipping Python dependency scan${NC}"
        return
    fi
    
    if [ -f "requirements.txt" ] || [ -f "Pipfile" ]; then
        echo -e "${GREEN}Scanning Python dependencies with Safety${NC}"
        safety check --json > "$OUTPUT_DIR/safety-scan.json" || true
        safety check > "$OUTPUT_DIR/safety-scan.txt" || true
        echo -e "${GREEN}Python dependency scan completed${NC}"
    fi
}

# Main execution
main() {
    echo -e "${GREEN}=== Security Scanning Automation ===${NC}"
    echo -e "Scan directory: $SCAN_DIR"
    echo -e "Output directory: $OUTPUT_DIR"
    echo ""
    
    scan_filesystem
    scan_docker_image
    scan_kubernetes
    scan_python
    scan_npm
    scan_python_deps
    
    echo ""
    echo -e "${GREEN}=== Scan Summary ===${NC}"
    echo -e "Results saved to: $OUTPUT_DIR"
    ls -lh "$OUTPUT_DIR"
    
    echo -e "${GREEN}Security scan completed!${NC}"
}

# Run main function
main

