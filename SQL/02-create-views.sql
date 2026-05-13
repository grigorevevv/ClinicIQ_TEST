-- Представление для аналитики выручки
-- Мы отдаем детальные данные с датами, чтобы Superset сам группировал их по месяцам и считал SUM()
CREATE OR REPLACE VIEW public.v_revenue_analytics AS
SELECT au.id AS doctor_id,
    au.last_name || ' ' || au.first_name AS doctor_name,
    -- Отдаем дату события для фильтрации в Superset
    COALESCE(at2.valid_until, at2.completed_at) AS appointment_date,
    atp.id AS procedure_id,
    atp.frozen_price AS price
FROM appointments_treatmentplan at2
LEFT JOIN appointments_treatmentplanstage ats ON ats.treatment_plan_id = at2.id 
LEFT JOIN appointments_treatmentplanstageprocedure atp ON atp.stage_id = ats.id  
LEFT JOIN auth_user au ON au.id = at2.created_by_id
WHERE COALESCE(at2.valid_until, at2.completed_at) IS NOT NULL;