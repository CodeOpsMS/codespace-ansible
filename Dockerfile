# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-alpine AS builder

# Metadata for the builder
LABEL stage=builder

# Set working directory
WORKDIR /app

# Install build dependencies
# Versions are examples and should be adjusted to the latest stable versions
RUN apk add --no-cache \
    gcc=13.2.1_git20240309-r0 \
    musl-dev=1.2.5-r0 \
    libffi-dev=3.4.6-r0	 \
    openssl-dev=3.3.2-r0

# Copy only the requirements file
COPY requirements.txt .

# Install Python packages
RUN pip install --user --no-cache-dir -r requirements.txt

# ================================
# Stage 2: Final Image
# ================================
FROM python:3.11-alpine AS final

# Metadata for the final image
LABEL maintainer="CodeOpsMS"
LABEL description="Ansible Codespce"
LABEL version="0.1"

# Set environment variables
ENV ANSIBLE_FORCE_COLOR=1 \
    PATH="/home/vscode/.local/bin:$PATH"

# Install only necessary runtime dependencies
# Versions are examples and should be adjusted to the latest stable versions
RUN apk add --no-cache \
    git=2.45.2-r0 \
    openssh=9.7_p1-r4 \
    docker-cli=26.1.5-r0	 \
    curl=8.9.1-r2 \
    wget=1.24.5-r0 \
    nano=8.0-r0 \
    less=643-r2	 \
    bash=5.2.26-r0 \
    fish=3.7.1-r0 \
    && rm -rf /var/cache/apk/*

# Install Terraform
RUN wget --progress=dot:giga https://releases.hashicorp.com/terraform/1.9.6/terraform_1.9.6_linux_amd64.zip \
    && unzip terraform_1.9.6_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.9.6_linux_amd64.zip

# Create non-root user
RUN adduser -D vscode
USER vscode
WORKDIR /home/vscode

# Copy installed Python packages from the builder
COPY --from=builder /root/.local /home/vscode/.local

# Install Ansible collections
RUN ansible-galaxy collection install community.general community.docker hetzner.hcloud

# Set default shell to fish
SHELL ["/usr/bin/fish", "-c"]

CMD ["/usr/bin/fish"]
