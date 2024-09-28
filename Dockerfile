# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-alpine AS builder

# Metadaten für den Builder
LABEL stage=builder

# Setze Arbeitsverzeichnis
WORKDIR /app

# Installiere Build-Abhängigkeiten
# Versionen sind beispielhaft und sollten an die aktuellsten stabilen Versionen angepasst werden
RUN apk add --no-cache \
    gcc=14.2.0-r3 \
    musl-dev=1.2.5-r3 \
    libffi-dev=3.4.6-r0 \
    openssl-dev=3.3.2-r2

# Kopiere nur die Requirements-Datei
COPY requirements.txt .

# Installiere Python-Pakete
RUN pip install --user --no-cache-dir -r requirements.txt

# ================================
# Stage 2: Final Image
# ================================
FROM python:3.11-alpine AS final

# Metadaten für das finale Image
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Ansible Development Environment"
LABEL version="1.0"

# Setze Umgebungsvariablen
ENV ANSIBLE_FORCE_COLOR=1 \
    PATH="/home/vscode/.local/bin:$PATH"

# Installiere nur notwendige Laufzeitabhängigkeiten
# Versionen sind beispielhaft und sollten an die aktuellsten stabilen Versionen angepasst werden
RUN apk add --no-cache \
    git=2.46.2-r0 \
    openssh=9.9_p1-r0 \
    docker-cli=27.3.1-r0 \
    curl=8.9.1-r2 \
    wget=1.24.5-r0 \
    nano=8.2-r0 \
    less=661-r0 \
    bash=5.2.37-r0 \
    fish=3.7.1-r0 \
    && rm -rf /var/cache/apk/*

# Installiere Terraform
RUN wget --progress=dot:giga https://releases.hashicorp.com/terraform/1.9.6/terraform_1.9.6_linux_amd64.zip \
    && unzip terraform_1.9.6_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.9.6_linux_amd64.zip

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
