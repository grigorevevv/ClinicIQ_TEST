import os
from datetime import date
from typing import Optional

from fastapi import FastAPI, Query, HTTPException
from sqlalchemy import create_engine, text


app = FastAPI(title="Medical Analytics API")

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

@app.get("/api/analytics")
def get_analytics(
    start_month: Optional[str] = Query(None, regex=r"^\d{4}-\d{2}$", description="Начало периода (YYYY-MM)"),
    end_month: Optional[str] = Query(None, regex=r"^\d{4}-\d{2}$", description="Конец периода (YYYY-MM)")
):
    """
    Эндпоинт для получения аналитики по врачам.
    Принимает опциональные параметры дат для фильтрации.
    """
    try:
        with engine.connect() as connection:
            sql_query = text("""
                SELECT 
                    au.id AS doctor_id,
                    au.last_name || ' ' || au.first_name AS doctor_name,  
                    SUM(atp.frozen_price) AS total_price
                FROM appointments_treatmentplan at2
                LEFT JOIN appointments_treatmentplanstage ats ON ats.treatment_plan_id = at2.id 
                LEFT JOIN appointments_treatmentplanstageprocedure atp ON atp.stage_id = ats.id  
                LEFT JOIN auth_user au ON au.id = at2.created_by_id 
                WHERE (:start_month IS NULL OR TO_CHAR(COALESCE(at2.valid_until, at2.completed_at), 'YYYY-MM') >= :start_month)
                    AND (:end_month IS NULL OR TO_CHAR(COALESCE(at2.valid_until, at2.completed_at), 'YYYY-MM') <= :end_month)
                GROUP BY au.id, doctor_name
                ORDER BY total_price DESC, doctor_name ASC;
            """)
            
            # Выполняем запрос, безопасно передавая параметры дат
            result = connection.execute(
                sql_query, 
                {"start_month": start_month, "end_month": end_month}
            )
            
            data = [dict(row) for row in result.mappings()]
            
            return {"status": "success", "data": data}
            
    except Exception as e:
        # Если что-то пошло не так (например, ошибка в SQL), возвращаем 500 ошибку
        raise HTTPException(status_code=500, detail=str(e))