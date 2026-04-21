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