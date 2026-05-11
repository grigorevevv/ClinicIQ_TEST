import streamlit as st
import requests
import pandas as pd
import plotly.express as px
import os
from datetime import date

# Получаем адрес API из переменных окружения
API_URL = os.getenv("API_URL", "http://localhost:8000")

# Настройка страницы
st.set_page_config(page_title="Аналитика клиники", page_icon="🏥", layout="wide")

st.title("🏥 Аналитика работы врачей")

# --- БОКОВАЯ ПАНЕЛЬ (ФИЛЬТРЫ) ---
st.sidebar.header("Фильтры")

start_date = st.sidebar.date_input("Начало периода", date(2023, 1, 1))
end_date = st.sidebar.date_input("Конец периода", date.today())

start_month_str = start_date.strftime("%Y-%m")
end_month_str = end_date.strftime("%Y-%m")

with st.spinner('Загрузка данных...'):
    try:
        response = requests.get(
            f"{API_URL}/api/analytics",
            params={"start_month": start_month_str, "end_month": end_month_str}
        )
        
        if response.status_code == 200:
            data = response.json().get("data", [])
            
            if not data:
                st.warning("За выбранный период нет данных.")
            else:
                df = pd.DataFrame(data)
                
                total_price = df["total_price"].fillna(0).sum()
                
                st.metric("Общая выручка", f"{total_price:,.0f} ₽".replace(",", " "))
                
                st.divider()
                
                st.subheader("Выручка по врачам")
                fig = px.bar(
                    df, 
                    x="doctor_name", 
                    y="total_price",
                    labels={"doctor_name": "Врач", "total_price": "Выручка (₽)"},
                    color="total_price",
                    color_continuous_scale="Viridis"
                )
                st.plotly_chart(fig, use_container_width=True)
                
                st.subheader("Детализация (Таблица)")
                st.dataframe(df, use_container_width=True, hide_index=True)
                
        else:
            st.error(f"Ошибка API: {response.status_code}")
            
    except requests.exceptions.ConnectionError:
         st.error(f"Не удалось подключиться к API по адресу {API_URL}. Проверьте, работает ли бэкенд.")