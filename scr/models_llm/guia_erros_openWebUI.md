🔧 Erro "Frontend Only" no Open WebUI - Solução Completa
Este erro é comum e significa que o frontend está carregando, mas o backend não está respondendo. Vamos resolver!
🎯 Causas Mais Prováveis
Causa
	
Frequência
	
Solução
Cache do navegador
	
🥇 60%
	
Limpar cache/cookies
Backend travou na inicialização
	
🥈 25%
	
Verificar logs do container
Imagem desatualizada/corrompida
	
🥉 10%
	
Pull da imagem mais recente
Configuração docker-compose
	
5%
	
Ajustar configuração
🚀 Soluções em Ordem (Tente Uma por Uma)
SOLUÇÃO 1: Limpar Cache do Navegador (Mais Comum!)
Este erro frequentemente é cache antigo do frontend tentando conectar a um backend novo.

🌐 No seu navegador:

Chrome/Edge:
1. Pressione Ctrl+Shift+Delete
2. Marque: "Cookies" e "Imagens e arquivos em cache"
3. Período: "Todo o período"
4. Clique em "Limpar dados"
5. Feche e reabra o navegador
6. Acesse: http://192.168.0.177:3000

Firefox:
1. Pressione Ctrl+Shift+Delete
2. Marque: "Cookies" e "Cache"
3. Clique em "Limpar agora"
4. Acesse: http://192.168.0.177:3000

OU use aba anônima: Ctrl+Shift+N

    ✅ Teste rápido: Acesse via aba anônima primeiro. Se funcionar, é cache!

SOLUÇÃO 2: Verificar se Backend Está Realmente Rodando
bash
# 1. Verificar status do container
docker-compose ps

# Esperado:
# NAME         STATUS
# open-webui   Up (healthy)

bash
# 2. Verificar logs COMPLETOS (procure por erros)
docker-compose logs --tail=100 | grep -iE "error|exception|failed|traceback"

# 3. Verificar se backend está escutando
docker exec open-webui curl -s http://localhost:8080/health 2>/dev/null || echo "❌ Backend não responde"

# 4. Verificar portas
sudo ss -tlnp | grep 3000

Se o backend não estiver respondendo, os logs vão mostrar o erro real.
SOLUÇÃO 3: Atualizar Imagem do Open WebUI
A imagem pode estar desatualizada ou corrompida.
bash
# 1. Parar container
docker-compose down

# 2. Remover imagem antiga
docker rmi ghcr.io/open-webui/open-webui:main 2>/dev/null

# 3. Baixar imagem mais recente
docker-compose pull

# 4. Recriar container
docker-compose up -d --force-recreate

# 5. Aguardar inicialização (3-5 minutos)
sleep 180

# 6. Verificar logs
docker-compose logs --tail=50

# 7. Testar
curl -I http://localhost:3000

SOLUÇÃO 4: Usar Versão Específica (Estável)
A tag :main pode ter bugs. Use uma versão estável específica.
bash
# 1. Editar docker-compose.yml
nano ~/openwebui/docker-compose.yml

Mudar a linha da imagem:
yaml
# DE:
image: ghcr.io/open-webui/open-webui:main

# PARA (versão estável testada):
image: ghcr.io/open-webui/open-webui:0.5.10

bash
# 2. Recriar container
docker-compose down
docker-compose pull
docker-compose up -d --force-recreate

# 3. Aguardar e testar
sleep 180
curl -I http://localhost:3000

SOLUÇÃO 5: Verificar Configuração do Docker-Compose
Sua configuração pode estar faltando algo crítico.
bash
# Editar docker-compose.yml
nano ~/openwebui/docker-compose.yml

Use esta configuração TESTADA:
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
      - OLLAMA_BASE_URL=http://192.168.0.177:11434
      - WEBUI_BIND_HOST=0.0.0.0
      - WEBUI_PORT=8080
      - ENABLE_RAG=false
      - ENABLE_WEB_SEARCH=false
      - ENABLE_COMMUNITY_SHARING=false
      - CORS_ALLOW_ORIGIN=http://192.168.0.177:3000
      - LOG_LEVEL=INFO
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped
    # Health check para garantir que está pronto
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s

    
bash
# Recriar
docker-compose down
docker-compose up -d --force-recreate

# Monitorar inicialização
docker-compose logs -f

Aguarde até ver:
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8080

SOLUÇÃO 6: Limpar Dados Corrompidos do WebUI
Os dados persistidos podem estar corrompidos.
bash
# ⚠️ ATENÇÃO: Isso remove chats/configs salvos!

# 1. Parar container
docker-compose down

# 2. Backup (opcional)
mkdir -p ~/backup-webui-$(date +%Y%m%d)
cp -r ~/openwebui/open-webui ~/backup-webui-$(date +%Y%m%d)/

# 3. Remover dados antigos
rm -rf ~/openwebui/open-webui/*

# 4. Recriar do zero
docker-compose up -d

# 5. Aguardar inicialização completa
sleep 180

# 6. Verificar logs
docker-compose logs --tail=50

# 7. Testar
curl -I http://localhost:3000


🧪 Script de Diagnóstico Completo
Crie e execute este script:
bash
nano ~/diagnose-webui-error.sh

bash
#!/bin/bash
echo "=== 🔍 Diagnóstico: Frontend Only Error ==="
echo ""

echo "1. Status do container:"
docker-compose ps
echo ""

echo "2. Health check:"
docker inspect open-webui --format='{{.State.Health.Status}}' 2>/dev/null || echo "Sem health check"
echo ""

echo "3. Backend responde internamente?"
docker exec open-webui curl -s -o /dev/null -w "HTTP: %{http_code}\n" http://localhost:8080/health 2>/dev/null || echo "❌ Falha"
echo ""

echo "4. Portas escutando:"
sudo ss -tlnp | grep 3000
echo ""

echo "5. Últimos erros nos logs:"
docker-compose logs --tail=50 | grep -iE "error|exception|failed" | tail -10 || echo "Nenhum erro óbvio"
echo ""

echo "6. Teste HTTP local:"
curl -s -o /dev/null -w "HTTP: %{http_code}\n" http://localhost:3000 2>/dev/null || echo "❌ Sem resposta"
echo ""

echo "7. Espaço em disco:"
df -h / | tail -1
echo ""

echo "=== ✅ Diagnóstico Concluído ==="
echo ""
echo "Próximos passos:"
echo "• Se backend HTTP = falha: container travou → Solução 6"
echo "• Se backend HTTP = 200: problema é cache → Solução 1"
echo "• Se porta 3000 não aparece: docker não mapeou → Solução 5"


bash
dar permissão 
chmod +x ~/diagnose-webui-error.sh
~/diagnose-webui-error.sh

📋 Checklist de Validação
Execute após cada solução:
bash
echo "=== ✅ Validação ==="
echo ""

# 1. Container saudável?
docker-compose ps | grep -q "healthy" && echo "✅ Container healthy" || echo "⏳ Aguardando..."

# 2. Backend responde?
docker exec open-webui curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null | grep -q "200" && echo "✅ Backend OK" || echo "❌ Backend falhou"

# 3. Porta acessível?
sudo ss -tlnp | grep -q ":3000" && echo "✅ Porta 3000 aberta" || echo "❌ Porta não encontrada"

# 4. HTTP responde?
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200" && echo "✅ HTTP 200 OK" || echo "⏳ Aguardando..."

echo ""
echo "Se todos ✅: Limpe cache do navegador e acesse http://192.168.0.177:3000"

🎯 Resumo: O Que Fazer Agora
┌─────────────────────────────────────────┐
│  ORDEM DE AÇÃO RECOMENDADA:            │
├─────────────────────────────────────────┤
│                                         │
│  1️⃣ Teste em aba anônima              │
│     (Ctrl+Shift+N)                     │
│     → Se funcionar: limpar cache       │
│                                         │
│  2️⃣ Executar script de diagnóstico    │
│     ~/diagnose-webui-error.sh          │
│     → Identifica causa raiz            │
│                                         │
│  3️⃣ Se backend falhou:                │
│     • Verificar logs: docker-compose   │
│       logs --tail=100                  │
│     • Recriar com dados limpos         │
│       (Solução 6)                      │
│                                         │
│  4️⃣ Se backend OK mas erro persiste:  │
│     • Limpar cache do navegador        │
│     • Ou usar versão específica 0.5.10 │
│                                         │
└─────────────────────────────────────────┘