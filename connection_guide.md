\# 🔌 Guia de Conexão — Power BI + Supabase



\## Pré-requisitos

\- Power BI Desktop (\[download](https://powerbi.microsoft.com/desktop/))

\- Conta no \[Supabase](https://supabase.com) com projeto criado

\- Python 3.8+



---



\## 1. Configurar o Supabase



\### 1.1 Criar o projeto

1\. Acesse \[app.supabase.com](https://app.supabase.com) → \*\*New Project\*\*

2\. Defina nome, senha e região

3\. Aguarde ~2 min



\### 1.2 Credenciais necessárias

| Variável | Onde encontrar |

|---|---|

| `SUPABASE\_URL` | Settings → API → Project URL |

| `SUPABASE\_KEY` | Settings → API → anon/public key |

| `DB\_HOST` | Settings → Database → Host |

| `DB\_PORT` | `5432` (padrão) |

| `DB\_USER` | `postgres` |

| `DB\_PASSWORD` | Senha definida na criação |



\### 1.3 Popular os dados

```bash

pip install -r requirements.txt

export SUPABASE\_URL="https://SEU\_PROJETO.supabase.co"

export SUPABASE\_KEY="sua-anon-key"

python setup\_supabase.py

```



---



\## 2. Conectar Power BI



\### Via PostgreSQL (recomendado)

1\. \*\*Home → Get Data → More → PostgreSQL\*\*

2\. Server: `db.SEU\_PROJETO.supabase.co`

3\. Database: `postgres`

4\. Mode: `Import` (histórico) ou `DirectQuery` (tempo real)

5\. Auth: usuário `postgres` + senha do projeto

6\. Selecione tabelas/views → \*\*Load\*\*



\### Via REST API (Power Query M)

```m

let

&nbsp;   Url = "https://SEU\_PROJETO.supabase.co/rest/v1/sales?select=\*",

&nbsp;   Headers = \[#"apikey" = "SUA\_KEY", #"Authorization" = "Bearer SUA\_KEY"],

&nbsp;   Source = Json.Document(Web.Contents(Url, \[Headers = Headers])),

&nbsp;   Tabela = Table.FromList(Source, Splitter.SplitByNothing()),

&nbsp;   Expand = Table.ExpandRecordColumn(Tabela, "Column1",

&nbsp;              {"id","date","customer\_id","amount","product","status"})

in Expand

```



---



\## 3. Refresh Automático (Power BI Service)

1\. \*\*File → Publish → Power BI Service\*\*

2\. Dataset → Settings → \*\*Scheduled Refresh\*\*

3\. Configure frequência (até 8×/dia no plano gratuito)

4\. Adicione credenciais em \*\*Data source credentials\*\*



---



\## 4. Segurança



| Prática | Como fazer |

|---|---|

| Usuário read-only | `GRANT SELECT ON ALL TABLES IN SCHEMA public TO powerbi\_reader;` |

| RLS ativo | Já incluso no `supabase\_queries.sql` |

| Restringir IPs | Settings → Database → Network |

| Nunca expor `service\_role` | Use apenas a chave `anon` no Power BI |



---



\## 5. Troubleshooting



| Erro | Solução |

|---|---|

| `connection refused` porta 5432 | Libere o IP em Settings → Database → Network |

| `SSL required` | Marque \*\*Encrypt connection\*\* no Power BI |

| Dados desatualizados | Revise o agendamento de refresh |

| Timeout em queries | Use `Import` mode + filtros no Power Query |

| Erro de autenticação | Use `postgres` como usuário padrão |



---



\## 6. Links Úteis

\- \[Docs Supabase](https://supabase.com/docs)

\- \[Conector PostgreSQL Power BI](https://learn.microsoft.com/power-query/connectors/postgresql)

\- \[DAX Reference](https://dax.guide)

