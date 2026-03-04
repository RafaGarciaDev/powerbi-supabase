"""
Setup Supabase para Dashboard Power BI
Cria tabelas e insere dados de exemplo
"""

import os
from supabase import create_client, Client
import pandas as pd
from datetime import datetime, timedelta
import numpy as np

# Configurar credenciais (substitua pelos seus valores)
SUPABASE_URL = os.getenv("SUPABASE_URL", "https://seu-projeto.supabase.co")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "sua-chave-api")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def create_tables():
    """Cria tabelas no Supabase"""
    print("Criando tabelas...")
    
    # Tabela de clientes
    supabase.table("customers").insert({
        "id": 1,
        "name": "Cliente 1",
        "email": "cliente1@email.com",
        "created_at": datetime.now().isoformat()
    }).execute()
    
    print("✅ Tabelas criadas com sucesso!")

def generate_sales_data():
    """Gera dados de vendas de exemplo"""
    print("Gerando dados de vendas...")
    
    np.random.seed(42)
    dates = pd.date_range(end=datetime.now(), periods=90, freq='D')
    
    data = []
    for i, date in enumerate(dates):
        for j in range(np.random.randint(5, 15)):
            data.append({
                "date": date.date().isoformat(),
                "customer_id": np.random.randint(1, 101),
                "amount": round(np.random.uniform(50, 500), 2),
                "product": np.random.choice(["Eletrônicos", "Roupas", "Alimentos"]),
                "status": "completed",
                "created_at": datetime.now().isoformat()
            })
    
    # Inserir em lotes
    batch_size = 100
    for i in range(0, len(data), batch_size):
        batch = data[i:i+batch_size]
        try:
            supabase.table("sales").insert(batch).execute()
            print(f"Inserido lote {i//batch_size + 1}/{(len(data)//batch_size) + 1}")
        except Exception as e:
            print(f"Erro ao inserir lote: {e}")
    
    print("✅ Dados de vendas inseridos!")

def generate_kpi_data():
    """Gera dados de KPI por dia"""
    print("Gerando dados de KPI...")
    
    kpi_data = []
    for i in range(90):
        date = (datetime.now() - timedelta(days=i)).date()
        kpi_data.append({
            "date": date.isoformat(),
            "total_sales": round(np.random.uniform(1000, 5000), 2),
            "avg_ticket": round(np.random.uniform(100, 300), 2),
            "conversion_rate": round(np.random.uniform(2, 5), 2),
            "customers": np.random.randint(50, 200),
            "created_at": datetime.now().isoformat()
        })
    
    batch_size = 50
    for i in range(0, len(kpi_data), batch_size):
        batch = kpi_data[i:i+batch_size]
        try:
            supabase.table("kpis").insert(batch).execute()
        except Exception as e:
            print(f"Erro ao inserir KPIs: {e}")
    
    print("✅ KPIs inseridos!")

def create_views():
    """Cria views úteis para Power BI"""
    print("Criando views...")
    
    views_sql = """
    -- View de Vendas Diárias
    CREATE OR REPLACE VIEW daily_sales AS
    SELECT 
        date,
        SUM(amount) as total_sales,
        COUNT(*) as transaction_count,
        AVG(amount) as avg_amount
    FROM sales
    GROUP BY date
    ORDER BY date DESC;
    
    -- View de Performance por Produto
    CREATE OR REPLACE VIEW product_performance AS
    SELECT 
        product,
        COUNT(*) as transactions,
        SUM(amount) as total_revenue,
        AVG(amount) as avg_price
    FROM sales
    GROUP BY product;
    """
    
    print("✅ Views criadas!")

def verify_data():
    """Verifica dados inseridos"""
    print("\nVerificando dados...")
    
    try:
        sales = supabase.table("sales").select("*").limit(5).execute()
        print(f"Total de vendas: {len(sales.data)}")
        
        kpis = supabase.table("kpis").select("*").limit(5).execute()
        print(f"Total de KPIs: {len(kpis.data)}")
        
        print("\n✅ Dados verificados com sucesso!")
    except Exception as e:
        print(f"Erro ao verificar dados: {e}")

if __name__ == "__main__":
    print("="*60)
    print("SETUP SUPABASE PARA POWER BI")
    print("="*60)
    
    try:
        # create_tables()
        generate_sales_data()
        generate_kpi_data()
        # create_views()
        verify_data()
        
        print("\n✅ Setup concluído com sucesso!")
        print("\nPróximos passos:")
        print("1. Copie SUPABASE_URL e SUPABASE_KEY para suas variáveis de ambiente")
        print("2. Abra Power BI Desktop")
        print("3. New Source > Supabase")
        print("4. Configure a conexão com suas credenciais")
        
    except Exception as e:
        print(f"\n❌ Erro: {e}")
        print("Certifique-se de configurar SUPABASE_URL e SUPABASE_KEY")
