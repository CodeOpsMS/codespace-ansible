# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-alpine AS builder

# Metadaten für den Builder
LABEL stage=builder

# Setze Arbeitsverzeichnis
WORKDIR /app

# Installiere Build-Abhängigkeiten
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev

# Kopiere nur die Requirements-Datei
COPY requirements.txt .

# Installiere Python-Pakete
RUN pip install --user --no-cache-dir -r requirements.txt

# ================================
# Stage 2: Final Image
# ================================
FROM python:3.11-alpine AS final

# Metadaten für das finale Image
LABEL maintainer="Your Name CodeOpsMS"
LABEL description="Ansible Codespace"
LABEL version="0.1"

# Setze Umgebungsvariablen
ENV ANSIBLE_FORCE_COLOR=1 \
    PATH="/home/vscode/.local/bin:$PATH"

# Installiere nur notwendige Laufzeitabhängigkeiten
RUN apk add --no-cache \
    git \
    openssh-client \
    docker-cli \
    curl \
    wget \
    vim \
    less \
    bash \
    fish \
    && rm -rf /var/cache/apk/*

# Installiere Terraform
RUN wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip \
    && unzip terraform_1.5.7_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.5.7_linux_amd64.zip

# Erstelle nicht-root Benutzer
RUN adduser -D vscode
USER vscode
WORKDIR /home/vscode

# Kopiere installierte Python-Pakete vom Builder
COPY --from=builder /root/.local /home/vscode/.local

# Installiere Ansible-Kollektionen
RUN ansible-galaxy collection install community.general community.docker hetzner.hcloud

# Setze Standard-Shell auf fish
SHELL ["/usr/bin/fish", "-c"]

CMD ["/usr/bin/fish"]
