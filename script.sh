# Install Trivy if not already installed
if ! command -v trivy &> /dev/null; then
  echo "Trivy is not installed, installing..."
  wget https://github.com/aquasecurity/trivy/releases/download/v0.19.1/trivy_0.19.1_Linux-64bit.deb
  dpkg -i trivy_0.19.1_Linux-64bit.deb
fi

# Scan your Docker image
trivy image your-container-image:tag
