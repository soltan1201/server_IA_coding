🤖 AI Coding Server - Arch Linux + Ollama + Open WebUI

    Servidor local de IA para programação com Qwen3.5, DeepSeek-Coder e CodeGemma, acessível por múltiplos desenvolvedores na rede local. 100% privado, offline e gratuito.


📋 Índice

    ✨ Funcionalidades
    🎯 Pré-requisitos
    🚀 Instalação Rápida
    🔧 Instalação Detalhada
    🤖 Configuração dos Modelos
    🌐 Acesso via Open WebUI
    💻 Integração com VS Code
    🔄 Gerenciamento de Modelos
    🛠️ Troubleshooting
    📊 Monitoramento
    🔒 Segurança
    🤝 Contribuindo

✨ Funcionalidades

    🏆 3 modelos de código otimizados para GPU:
        qwen3.5:9b → Qualidade máxima para tarefas complexas
        deepseek-coder:6.7b → Código rápido e leve
        codegemma:7b → Balanceado para uso geral
    🎮 Aceleração GPU com NVIDIA RTX 3060 (12GB VRAM)
    🌐 Acesso multi-usuário via rede local (5+ desenvolvedores simultâneos)
    🔒 100% privado — dados nunca saem da sua rede
    💬 Interface web tipo ChatGPT (Open WebUI)
    🧩 Integração nativa com VS Code via Continue.dev
    🔄 Troca dinâmica de modelos sem reiniciar servidor
    📦 Dockerizado para fácil deploy e manutenção

🎯 Pré-requisitos
Hardware Recomendado
Componente       Mínimo               Recomendado
GPU             NVIDIA 8GB VRAM    NVIDIA 12GB+ VRAM (RTX 3060)
RAM             16 GB              32 GB+
CPU             4 núcleos          6+ núcleos
Armazenamento   50 GB livres       100 GB+ SSD/NVMe
Rede            Wi-Fi/Ethernet      Gigabit Ethernet

Software
    ✅ Arch Linux instalado e atualizado
    ✅ Usuário com privilégios sudo
    ✅ Drivers NVIDIA instalados (nvidia-dkms, nvidia-utils)
    ✅ Conexão com internet para downloads iniciais

🚀 Instalação Rápida

bash
# 1. Clonar este repositório (ou copiar os comandos abaixo)
git clone https://github.com/seu-usuario/ai-coding-server.git
cd ai-coding-server

# 2. Executar script de instalação automática
chmod +x install.sh
./install.sh

# 3. Baixar modelos (escolha os desejados)
ollama pull qwen3.5:9b
ollama pull deepseek-coder:6.7b
ollama pull codegemma:7b

# 4. Iniciar serviços
sudo systemctl enable --now ollama
cd ~/openwebui && docker-compose up -d

# 5. Acessar interface web
# http://<IP-DO-SERVIDOR>:3000
- fin do bash


🔧 Instalação Detalhada
1. Preparar o Sistema

bash
# Atualizar sistema
sudo pacman -Syu

# Instalar ferramentas essenciais
sudo pacman -S base-devel git wget curl docker docker-compose yay

# Habilitar e iniciar Docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# ⚠️ Faça logout/login para aplicar mudanças de grupo

# Instalar drivers NVIDIA (se ainda não tiver)
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings cuda cudnn

# Verificar GPU
nvidia-smi
- fin do bash

2. Instalar e Configurar Ollama

bash
# Instalar Ollama via AUR
yay -S ollama ollama-cuda

# Configurar para rede local e GPU
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo nano /etc/systemd/system/ollama.service.d/override.conf
- fin do bash

Conteúdo do override.conf:
ini 
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_NUM_PARALLEL=5"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_KEEP_ALIVE=10m"
Environment="CUDA_VISIBLE_DEVICES=0"

bash
# Aplicar configurações
sudo systemctl daemon-reload
sudo systemctl enable --now ollama

# Verificar status
systemctl status ollama --no-pager
-fin do bash


3. Configurar Firewall (Opcional mas Recomendado)
bash
# Instalar UFW
sudo pacman -S ufw

# Liberar portas necessárias
sudo ufw allow 11434/tcp  # Ollama API
sudo ufw allow 3000/tcp   # Open WebUI
sudo ufw enable

# Verificar regras
sudo ufw status
- fin do bash

4. Instalar Open WebUI (Interface Web)
bash
# Criar diretório do projeto
mkdir -p ~/openwebui
cd ~/openwebui

# Criar docker-compose.yml
nano docker-compose.yml
-fin do bash

Conteúdo do docker-compose.yml:
yaml
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    volumes:
      - ./open-webui:/app/backend/data
    environment:
      - OLLAMA_BASE_URL=http://192.168.0.177:11434  # ← Altere para IP do seu servidor
      - ENABLE_RAG=false
      - ENABLE_WEB_SEARCH=false
      - ENABLE_COMMUNITY_SHARING=false
      - WEBUI_BIND_HOST=0.0.0.0
      - WEBUI_PORT=8080
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped

bash
# Iniciar container
docker-compose up -d

# Verificar logs
docker-compose logs -f
# Aguarde: "Uvicorn running on http://0.0.0.0:8080"
-fin do bash

🤖 Configuração dos Modelos
Baixar Modelos Recomendados

bash
# Modelo principal (qualidade máxima)
ollama pull qwen3.5:9b          # ~6.6 GB

# Modelo leve para código rápido
ollama pull deepseek-coder:6.7b # ~3.8 GB

# Modelo balanceado
ollama pull codegemma:7b        # ~5.0 GB

# Verificar downloads
ollama list
-fin do bash

Verificar Uso de VRAM
bash
# Monitorar GPU em tempo real
watch -n 2 nvidia-smi

# Ou comando único
nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu --format=csv
- fin do bash

💡 Dica: Cada modelo 7B usa ~6GB de VRAM. Com OLLAMA_MAX_LOADED_MODELS=1, apenas um modelo fica na GPU por vez.


🌐 Acesso via Open WebUI
Primeiro Acesso

    Abra no navegador: http://<IP-DO-SERVIDOR>:3000
    Crie sua conta admin:

Email: admin@openwebui.local
Nome: Admin
Senha: ********

Conectar ao Ollama

    1. Clique no seu nome → Admin Panel → Settings → Connections
    2. Configure:
        OLLAMA BASE URL: http://<IP-DO-SERVIDOR>:11434
    3. Clique em "Test Connection" ✅
    4. Clique em "Save"

Usar os Modelos

    1. Volte para o chat principal
    2. Clique no seletor de modelo (topo da página)
    3. Escolha um modelo:
        qwen3.5:9b → Tarefas complexas, raciocínio
        deepseek-coder:6.7b → Geração de código rápido
        codegemma:7b → Uso geral balanceado
    4. Comece a conversar! 🎉

 Dica: para garantir que o Open WebUI funcione de primeira:
    1. A Variável de Ambiente WEBUI_SECRET_KEY
    O Open WebUI exige uma chave secreta para criptografar os tokens de login no banco de dados. Se você não definir uma no docker-compose.yml
    YAML
      environment:
      - 'WEBUI_SECRET_KEY=sua_chave_secreta_aqui_muito_longa' # Adicione isso
      - 'OLLAMA_BASE_URL=http://host.docker.internal:11434'
    2. Permissões de Escrita no Volume (Crucial no Arch)
    bash
    # Se o Open WebUI der erro de banco de dados, force a permissão:
    sudo chown -R 1000:1000 ~/openwebui/open-webui
    sudo chmod -R 755 ~/openwebui/open-webui
    - fin do bash
    3. DNS e comunicação via host.docker.internal
    Se o IP do servidor mudar via DHCP, o WebUI para de funcionar.
    Recomendação de ajuste no passo 4:
    No arquivo docker-compose.yml, altere:
    OLLAMA_BASE_URL=http://host.docker.internal:11434
    Isso garante que, não importa o IP da sua rede WiFi/Ethernet, o Open WebUI sempre achará o Ollama rodando no Arch.
    4. Ordem de Inicialização (O "Race Condition")
    bash
    # Comando de verificação rápida
    until curl -s http://localhost:11434/api/tags > /dev/null; do
      echo "Aguardando Ollama iniciar..."
      sleep 2
    done
    docker-compose up -d
    - fin do bash
    













💻 Integração com VS Code (Continue.dev)
Instalar em Cada Notebook

    1. No VS Code a extensão: Ctrl+Shift+X → Busque "Continue" → Instale
    2. Abra a paleta: Ctrl+Shift+P → "Continue: Open Config"
    3. Configure ~/.continue/config.json:

json
{
  "models": [
    {
      "title": "🏆 Qwen3.5 9B (Local)",
      "provider": "ollama",
      "model": "qwen3.5:9b",
      "apiBase": "http://<IP-DO-SERVIDOR>:11434"
    },
    {
      "title": "⚡ DeepSeek 6.7B (Local)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "apiBase": "http://<IP-DO-SERVIDOR>:11434"
    },
    {
      "title": "🔷 CodeGemma 7B (Local)",
      "provider": "ollama",
      "model": "codegemma:7b",
      "apiBase": "http://<IP-DO-SERVIDOR>:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "⚡ DeepSeek 6.7B (Local)",
    "provider": "ollama",
    "model": "deepseek-coder:6.7b",
    "apiBase": "http://<IP-DO-SERVIDOR>:11434"
  }
}
no meu caso o <IP-DO-SERVIDOR> = 192.168.0.177

Como Usar
Atalho                 Função                     Exemplo
Ctrl+L                Chat lateral               "Explique esta função"
Ctrl+I                Edit inline                "Adicione type hints"
Tab                   Aceitar autocomplete       Sugestão enquanto digita

Testar Conexão
No terminal do notebook para saber se o servidor ollama esta respondendo:
bash
curl http://<IP-DO-SERVIDOR>:11434/api/tags
# Deve retornar JSON com lista de modelos
- fin do bash 
 saida > "run ollama" na pagina web


 🔄 Gerenciamento de Modelos
Script de Troca Rápida
Crie ~/switch-model.sh:

bash
#!/bin/bash
# ~/switch-model.sh - Troca entre modelos Ollama

OLLAMA_URL="http://127.0.0.1:11434"
MODEL="${1:-qwen3.5:9b}"

echo "=== 🔄 Trocando para: $MODEL ==="

# Descarregar modelo anterior
curl -s -X POST "$OLLAMA_URL/api/generate" \
  -H "Content-Type: application/json" \
  -d "{\"model\": \"$MODEL\", \"prompt\": \".\", \"keep_alive\": 0}" > /dev/null
sleep 3

# Pré-carregar novo modelo
curl -s -X POST "$OLLAMA_URL/api/generate" \
  -H "Content-Type: application/json" \
  -d "{\"model\": \"$MODEL\", \"prompt\": \"ready\", \"keep_alive\": \"24h\"}" > /dev/null

echo "✅ Modelo ativo: $(curl -s $OLLAMA_URL/api/ps | grep -oP '"model":\s*"\K[^"]+' || echo 'Verificando...')"
echo "🎮 VRAM: $(nvidia-smi --query-gpu=memory.used --format=csv,noheader | tail -1)"
-finb do bash

bash
# Tornar executável
chmod +x ~/switch-model.sh

# Adicionar aliases ao ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# === AI Model Switcher ===
alias ai-qwen='~/switch-model.sh qwen3.5:9b'
alias ai-deepseek='~/switch-model.sh deepseek-coder:6.7b'
alias ai-gemma='~/switch-model.sh codegemma:7b'
alias ai-status='curl -s http://127.0.0.1:11434/api/ps 2>/dev/null | grep -oP "\"model\":\s*\"\K[^\"]+" || echo "Nenhum"'
alias ai-vram='nvidia-smi --query-gpu=memory.used --format=csv,noheader | tail -1'
EOF

source ~/.bashrc
- fin do bash

Comandos Úteis
bash 
# Trocar modelo
ai-qwen          # Ativa Qwen3.5 9B
ai-deepseek      # Ativa DeepSeek 6.7B
ai-gemma         # Ativa CodeGemma 7B

# Ver status
ai-status        # Qual modelo está ativo
ai-vram          # Uso de VRAM da GPU
ollama list      # Modelos instalados em disco

# Gerenciar modelos
ollama rm nome:modelo    # Remover modelo
ollama pull nome:modelo  # Baixar modelo
- fin do bash

🛠️ Troubleshooting
Ollama não inicia
bash
# Verificar logs
sudo journalctl -u ollama -n 50 --no-pager

# Verificar módulo overlay (necessário para Docker)
lsmod | grep overlay || sudo modprobe overlay

# Reinstalar se necessário
yay -S ollama ollama-cuda
sudo systemctl restart ollama
- fin do bash

Open WebUI não carrega
bash
# Verificar logs do container
docker-compose logs -f

# Verificar se porta está escutando
sudo ss -tlnp | grep 3000

# Testar localmente
curl -I http://localhost:3000

# Se necessário, recriar container
docker-compose down
docker-compose up -d --force-recreate
- fin do bash

Modelos não aparecem no Open WebUI

    1. No Admin Panel → Models → Clique em "Refresh"
    2. Verifique conexão: Settings → Connections → "Test Connection"
    3. Se falhar, ajuste OLLAMA_BASE_URL para IP fixo do servidor

Conexão recusada dos notebooks
bash
# No servidor, verificar firewall
sudo ufw status
sudo ufw allow 11434/tcp
sudo ufw allow 3000/tcp

# Verificar se Ollama escuta na rede
ss -tlnp | grep 11434
# Deve mostrar: 0.0.0.0:11434 (não 127.0.0.1)

# No notebook, testar conexão
curl http://<IP-DO-SERVIDOR>:11434/api/tags
-fin do bash

GPU não detectada
bash
# Verificar drivers
nvidia-smi

# Se falhar, reinstalar
sudo pacman -S nvidia-dkms nvidia-utils
sudo reboot

# Verificar se Ollama usa GPU
ollama run qwen3.5:9b "teste" &
sleep 3
nvidia-smi | grep ollama
- fin do bash

📊 Monitoramento
Script de Monitoramento
Crie ~/monitor-ai.sh:

bash
#!/bin/bash
echo "=== 🤖 AI Server Monitor ==="
echo ""
echo "🎮 GPU (RTX 3060):"
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader
echo ""
echo "💻 RAM:"
free -h | grep Mem | awk '{print "Usado: "$3" | Livre: "$4}'
echo ""
echo "📦 Modelos em Memória:"
curl -s http://127.0.0.1:11434/api/ps 2>/dev/null | grep -oP '"model":\s*"\K[^"]+' || echo "Nenhum"
echo ""
echo "🔗 Conexões Ativas:"
ss -tnp | grep 11434 | wc -l | xargs echo "Conexões Ollama:"
echo ""
echo "📊 Disco (Modelos):"
sudo du -sh /var/lib/ollama
echo ""
echo "🐳 Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"
-fin do bash

-- como usar --
bash
chmod +x ~/monitor-ai.sh
# Executar: ~/monitor-ai.sh
-fin do bash

Comandos Rápidos
bash
# Uso de GPU em tempo real
watch -n 2 nvidia-smi

# Logs do Ollama
journalctl -u ollama -f

# Logs do Open WebUI
docker-compose logs -f

# Espaço em disco
df -h /
sudo du -sh /var/lib/ollama
- fin do bash

🔒 Segurança
Recomendações para Produção
bash
# 1. Alterar senha padrão do Open WebUI
# Admin Panel → Settings → Account

# 2. Habilitar autenticação no Open WebUI
# Admin Panel → Settings → Auth → Enable

# 3. Restringir acesso por IP (se necessário)
sudo ufw allow from 192.168.0.0/24 to any port 11434
sudo ufw allow from 192.168.0.0/24 to any port 3000

# 4. Usar reverse proxy com HTTPS (opcional)
# Exemplo com Nginx + Let's Encrypt
-fin do bash

Backup dos Dados
bash
# Backup dos modelos Ollama
sudo tar -czf ollama-backup-$(date +%Y%m%d).tar.gz /var/lib/ollama

# Backup do Open WebUI (chats, configs)
tar -czf webui-backup-$(date +%Y%m%d).tar.gz ~/openwebui/open-webui

# Restaurar
sudo tar -xzf ollama-backup-*.tar.gz -C /
tar -xzf webui-backup-*.tar.gz -C ~/
- fin do bash

Backup dos Dados
bash
# Backup dos modelos Ollama
sudo tar -czf ollama-backup-$(date +%Y%m%d).tar.gz /var/lib/ollama

# Backup do Open WebUI (chats, configs)
tar -czf webui-backup-$(date +%Y%m%d).tar.gz ~/openwebui/open-webui

# Restaurar
sudo tar -xzf ollama-backup-*.tar.gz -C /
tar -xzf webui-backup-*.tar.gz -C ~/
- fin do bash
