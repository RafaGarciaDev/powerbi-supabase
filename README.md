# 📊 Dashboard Operacional Power BI + Supabase

Dashboard operacional em tempo real integrando Power BI com Supabase (PostgreSQL) para análise de KPIs e monitoramento operacional.

## ✨ Funcionalidades

- **Integração Supabase**: Conexão em tempo real com PostgreSQL
- **Dashboards Power BI**: Visualizações interativas e relatórios
- **Atualização em Tempo Real**: Refresh automático de dados
- **DAX Avançado**: Medidas complexas e cálculos
- **Alertas**: Notificações de anomalias
- **Mobile Friendly**: Visualizações responsivas

## 🛠️ Tecnologias

- **Power BI Desktop/Service**
- **Supabase (PostgreSQL)**
- **DAX**: Linguagem de cálculo
- **M Query**: Transformação de dados

## 🚀 Como Executar

```bash
# 1. Crie conta em Supabase
# https://supabase.com

# 2. Importar dados
python setup_supabase.py

# 3. Abrir arquivo Power BI
# Abra dashboard.pbix no Power BI Desktop

# 4. Configurar conexão
# Data > New Source > Supabase
```

## 📁 Estrutura

```
powerbi-supabase/
├── dashboard.pbix         # Arquivo Power BI
├── setup_supabase.py      # Script setup
├── queries/
│   └── supabase_queries.sql
├── docs/
│   └── connection_guide.md
└── README.md
```

## 📈 KPIs Monitorados

- Total de Vendas
- Ticket Médio
- Taxa de Conversão
- Tempo de Entrega
- Satisfação do Cliente

## 💡 DAX Exemplos

```dax
Total Sales = SUM(Orders[Amount])
MoM Growth = DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], 
        DATEADD(Dates[Date], -1, MONTH))
)
```

## 📝 Licença

MIT License

---

⭐ Se este projeto foi útil, deixe uma star!
