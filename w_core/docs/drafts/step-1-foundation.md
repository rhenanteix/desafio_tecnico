# Step 1 — Fundation


Estabelecer a base da aplicação garantindo:

- Isolamento entre domínios (Telemetry vs Web)
- Autenticação segura para acesso ao sistema
- Persistência local via SQLite
- Estrutura preparada para alta concorrência

---

## 🏗️ Estrutura Inicial da Aplicação



- Phoenix Framework
- Ecto + SQLite (via Exqlite)
- OTP (GenServer + Supervisor)

