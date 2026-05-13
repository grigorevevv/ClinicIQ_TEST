CREATE OR REPLACE VIEW public.v_redirection_doctor AS
with first_visit as (
	select ss.doctor_id as first_docid, aa.patient_id
			, MIN(aa.start_time) as start_time
	from appointments_appointment aa 
	left join schedules_schedule ss on ss.id = aa.schedule_id 
	where aa.status = 'completed'
	group by ss.doctor_id, aa.patient_id
)
select au.last_name || ' ' || au.first_name AS doctor_name
		, COUNT(distinct aa.patient_id)
from appointments_appointment aa 
inner join first_visit fv on aa.patient_id = fv.patient_id
left join schedules_schedule ss on ss.id = aa.schedule_id 
left join auth_user au ON au.id = fv.first_docid
where fv.first_docid != ss.doctor_id 
group by au.last_name || ' ' || au.first_name
order by au.last_name || ' ' || au.first_name 