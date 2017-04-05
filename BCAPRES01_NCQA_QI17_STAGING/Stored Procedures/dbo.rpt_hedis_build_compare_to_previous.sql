SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[rpt_hedis_build_compare_to_previous]
as



IF OBJECT_ID('tempdb..#new') is not null
    DROP TABLE #new

select	report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_desc,
		
		eligible_population			= sum(hedis_eligible_value),
		denominator					= sum(denominator_value),
		numerator					= sum(numerator_value),
		exclusion					= sum(exclusion_value),
		numerator_neg				= sum(numerator_negative_value)
into	#new 
from	dbo.hedis_report_metric_fact a
		inner join hedis_report_metric_dim b on
			a.hedis_report_metric_key = b.hedis_report_metric_key
		inner join hedis_measure_dim c on
			a.hedis_measure_key = c.hedis_measure_key
		inner join hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
--		inner join hedis_member_measure_sample_dim b on
--			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
--		inner join hedis_medical_record_site_dim c on
--			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
--		inner join member_dim d on
--			a.member_key = d.member_key
--		inner join pcp_dim e on
--			a.pcp_key = e.pcp_key
where	hedis_eligible_value = 1 and
		denominator_value + exclusion_value > 0
group by report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_order,
		hedis_report_metric_desc
order by report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_order,
		hedis_report_metric_desc



IF OBJECT_ID('tempdb..#previous') is not null
    DROP TABLE #previous

select	report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_desc,
		
		eligible_population			= sum(hedis_eligible_value),
		denominator					= sum(denominator_value),
		numerator					= sum(numerator_value),
		exclusion					= sum(exclusion_value),
		numerator_neg				= sum(numerator_negative_value)
into	#previous
from	NCQA_QI09_PROD.dbo.hedis_report_metric_fact a
		inner join NCQA_QI09_PROD.dbo.hedis_report_metric_dim b on
			a.hedis_report_metric_key = b.hedis_report_metric_key
		inner join NCQA_QI09_PROD.dbo.hedis_measure_dim c on
			a.hedis_measure_key = c.hedis_measure_key
		inner join NCQA_QI09_PROD.dbo.hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
--		inner join hedis_member_measure_sample_dim b on
--			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
--		inner join hedis_medical_record_site_dim c on
--			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
--		inner join member_dim d on
--			a.member_key = d.member_key
--		inner join pcp_dim e on
--			a.pcp_key = e.pcp_key
where	hedis_eligible_value = 1 and
		denominator_value + exclusion_value > 0
group by report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_order,
		hedis_report_metric_desc
order by report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_order,
		hedis_report_metric_desc




IF OBJECT_ID('tempdb..#metrics') is not null
    DROP TABLE #metrics

select	distinct
		report_ending_char_full_date,
		hedis_report_metric_id,
		hedis_report_metric_desc
into	#metrics
from	#new
union
select	distinct
		report_ending_char_full_date,
		hedis_report_metric_id,
		hedis_report_metric_desc
from	#previous



select	a.report_ending_char_full_date,
		a.hedis_report_metric_id,
		a.hedis_report_metric_id,
		EP_CHG			= isnull(b.eligible_population,0)-isnull(c.eligible_population,0)	,
		DEN_CHG			= isnull(b.denominator,0)-isnull(c.denominator,0)	,
		NUM_CHG			= isnull(b.numerator,0)-isnull(c.numerator,0)	,
		EXCL_CHG		= isnull(b.exclusion,0)-isnull(c.exclusion,0)	,
		EP_OLD			= c.eligible_population,
		EP_NEW			= b.eligible_population,
		DEN_OLD			= c.denominator,
		DEN_NEW			= b.denominator,
		NUM_OLD			= c.numerator,
		NUM_NEW			= b.numerator,
		EXCL_OLD		= c.exclusion,
		EXCL_NEW		= b.exclusion
from	#metrics a
		left join #new b on
			a.report_ending_char_full_date = b.report_ending_char_full_date and
			a.hedis_report_metric_id = b.hedis_report_metric_id 
		left join #previous c on
			a.report_ending_char_full_date = c.report_ending_char_full_date and
			a.hedis_report_metric_id = c.hedis_report_metric_id
order by 1,2,3





IF OBJECT_ID('tempdb..#new_uos') is not null
    DROP TABLE #new_uos

select	
		report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc
		,visit_event_value			= sum(visit_event_value)
		,procedure_event_value		= sum(procedure_event_value)
		,member_months_value		= sum(member_months_value)
into	#new_uos 
from	hedis_report_metric_uos_fact a
		inner join hedis_report_metric_uos_cohort_dim b on
			a.hedis_report_metric_uos_cohort_key = b.hedis_report_metric_uos_cohort_key
		inner join hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
group by report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc
order by report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc


IF OBJECT_ID('tempdb..#previous_uos') is not null
    DROP TABLE #previous_uos

select	
		report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc
		,visit_event_value			= sum(visit_event_value)
		,procedure_event_value		= sum(procedure_event_value)
		,member_months_value		= sum(member_months_value)
into	#previous_uos
from	NCQA_QI09_PROD.dbo.hedis_report_metric_uos_fact a
		inner join NCQA_QI09_PROD.dbo.hedis_report_metric_uos_cohort_dim b on
			a.hedis_report_metric_uos_cohort_key = b.hedis_report_metric_uos_cohort_key
		inner join NCQA_QI09_PROD.dbo.hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
group by report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc
order by report_ending_char_full_date,
		b.hedis_dss_report_metric_cohort_id,
		b.hedis_dss_report_metric_cohort_desc



IF OBJECT_ID('tempdb..#metrics_uos') is not null
    DROP TABLE #metrics_uos

select	distinct
		report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc
into	#metrics_uos
from	#new_uos
union
select	distinct
		report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc
from	#previous_uos



select	a.report_ending_char_full_date,
		a.hedis_dss_report_metric_cohort_id,
		a.hedis_dss_report_metric_cohort_desc,
		VISIT_CHG			= isnull(b.visit_event_value,0)-isnull(c.visit_event_value,0)	,
		PROC_CHG			= isnull(b.procedure_event_value,0)-isnull(c.procedure_event_value,0)	,
		MM_CHG				= isnull(b.member_months_value,0)-isnull(c.member_months_value,0)	,
		VISIT_OLD			= c.visit_event_value,
		VISIT_NEW			= b.visit_event_value,
		PROC_OLD			= c.procedure_event_value,
		PROC_NEW			= b.procedure_event_value,
		MM_OLD				= c.member_months_value,
		MM_NEW				= b.member_months_value
from	#metrics_uos a
		left join #new_uos b on
			a.report_ending_char_full_date = b.report_ending_char_full_date and
			a.hedis_dss_report_metric_cohort_id = b.hedis_dss_report_metric_cohort_id 
		left join #previous_uos c on
			a.report_ending_char_full_date = c.report_ending_char_full_date and
			a.hedis_dss_report_metric_cohort_id = c.hedis_dss_report_metric_cohort_id
order by 1,2







IF OBJECT_ID('tempdb..#new_coc') is not null
    DROP TABLE #new_coc

select	report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc,
		eligible_population_count			= sum(eligible_population_count),
		medical_member_months				= sum(medical_member_months),
		rx_member_months					= sum(rx_member_months),
		standard_cost_inpatient				= sum(standard_cost_inpatient),
		standard_cost_eval_and_mgt			= sum(standard_cost_eval_and_mgt),
		standard_cost_surgery_and_proc		= sum(standard_cost_surgery_and_proc),
		standard_cost_pharmacy				= sum(standard_cost_pharmacy),
		frequency_inpatient					= sum(frequency_inpatient),
		frequency_emergency_dept			= sum(frequency_emergency_dept)
into	#new_coc
--select	top 10 *
from	HEDIS_REPORT_METRIC_COC_FACT a
		inner join hedis_gender_dim b on
			a.hedis_gender_key = b.hedis_gender_key
		inner join hedis_dss_age_dim c on
			a.hedis_dss_age_key = c.hedis_dss_age_key
		inner join hedis_coc_comorbidity_dim d on
			a.hedis_coc_comorbidity_key = d.hedis_coc_comorbidity_key
		inner join hedis_coc_clinical_category_dim e on
			a.hedis_coc_clinical_category_key = e.hedis_coc_clinical_category_key
		inner join hedis_product_line_dim f on
			a.hedis_product_line_key = f.hedis_product_line_key
		inner join hedis_measure_dim g on
			a.hedis_measure_key = g.hedis_measure_key
		inner join hedis_member_dim h on
			a.hedis_member_key = h.hedis_member_key
		inner join hedis_report_metric_coc_cohort_dim i on
			a.hedis_report_metric_coc_cohort_key = i.hedis_report_metric_coc_cohort_key
		inner join hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
--where	exists (	select	*
--					from	hedis_measure_dim g2
--					where	a.hedis_measure_key = g2.hedis_measure_key and
--							g2.hedis_measure_init = 'RAS')
group by report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc





IF OBJECT_ID('tempdb..#previous_coc') is not null
    DROP TABLE #previous_coc

select	report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc,
		eligible_population_count			= sum(eligible_population_count),
		medical_member_months				= sum(medical_member_months),
		rx_member_months					= sum(rx_member_months),
		standard_cost_inpatient				= sum(standard_cost_inpatient),
		standard_cost_eval_and_mgt			= sum(standard_cost_eval_and_mgt),
		standard_cost_surgery_and_proc		= sum(standard_cost_surgery_and_proc),
		standard_cost_pharmacy				= sum(standard_cost_pharmacy),
		frequency_inpatient					= sum(frequency_inpatient),
		frequency_emergency_dept			= sum(frequency_emergency_dept)
into	#previous_coc
--select	top 10 *
from	NCQA_QI09_PROD.dbo.HEDIS_REPORT_METRIC_COC_FACT a
		inner join NCQA_QI09_PROD.dbo.hedis_gender_dim b on
			a.hedis_gender_key = b.hedis_gender_key
		inner join NCQA_QI09_PROD.dbo.hedis_dss_age_dim c on
			a.hedis_dss_age_key = c.hedis_dss_age_key
		inner join NCQA_QI09_PROD.dbo.hedis_coc_comorbidity_dim d on
			a.hedis_coc_comorbidity_key = d.hedis_coc_comorbidity_key
		inner join NCQA_QI09_PROD.dbo.hedis_coc_clinical_category_dim e on
			a.hedis_coc_clinical_category_key = e.hedis_coc_clinical_category_key
		inner join NCQA_QI09_PROD.dbo.hedis_product_line_dim f on
			a.hedis_product_line_key = f.hedis_product_line_key
		inner join NCQA_QI09_PROD.dbo.hedis_measure_dim g on
			a.hedis_measure_key = g.hedis_measure_key
		inner join NCQA_QI09_PROD.dbo.hedis_member_dim h on
			a.hedis_member_key = h.hedis_member_key
		inner join NCQA_QI09_PROD.dbo.hedis_report_metric_coc_cohort_dim i on
			a.hedis_report_metric_coc_cohort_key = i.hedis_report_metric_coc_cohort_key
		inner join NCQA_QI09_PROD.dbo.hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
--where	exists (	select	*
--					from	hedis_measure_dim g2
--					where	a.hedis_measure_key = g2.hedis_measure_key and
--							g2.hedis_measure_init = 'RAS')
group by report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc





IF OBJECT_ID('tempdb..#metrics_coc') is not null
    DROP TABLE #metrics_coc

select	distinct
		report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc
into	#metrics_coc
from	#new_coc
union
select	distinct
		report_ending_char_full_date,
		hedis_dss_report_metric_cohort_id,
		hedis_dss_report_metric_cohort_desc
from	#previous_coc



select	a.report_ending_char_full_date,
		a.hedis_dss_report_metric_cohort_id,
		a.hedis_dss_report_metric_cohort_desc,
		EP_CHG				= isnull(b.eligible_population_count,0)-isnull(c.eligible_population_count,0)	,
		MedMM_CHG			= isnull(b.medical_member_months,0)-isnull(c.medical_member_months,0)	,
		RxMM_CHG			= isnull(b.rx_member_months,0)-isnull(c.rx_member_months,0)	,
		IPCOST_CHG			= isnull(b.standard_cost_inpatient,0)-isnull(c.standard_cost_inpatient,0)	,
		EMCOST_CHG			= isnull(b.standard_cost_eval_and_mgt,0)-isnull(c.standard_cost_eval_and_mgt,0)	,
		SPCOST_CHG			= isnull(b.standard_cost_surgery_and_proc,0)-isnull(c.standard_cost_surgery_and_proc,0)	,
		RXCOST_CHG			= isnull(b.standard_cost_pharmacy,0)-isnull(c.standard_cost_pharmacy,0)	,
		IPFREQ_CHG			= isnull(b.frequency_inpatient,0)-isnull(c.frequency_inpatient,0)	,
		EDFREQ_CHG			= isnull(b.frequency_emergency_dept,0)-isnull(c.frequency_emergency_dept,0)	,
		EP_OLD				= c.eligible_population_count,
		EP_NEW				= b.eligible_population_count,
		MedMM_OLD			= c.medical_member_months,
		MedMM_NEW			= b.medical_member_months,
		RxMM_OLD			= c.rx_member_months,
		RxMM_NEW			= b.rx_member_months,
		IPCOST_OLD			= c.standard_cost_inpatient,
		IPCOST_NEW			= b.standard_cost_inpatient,
		EMCOST_OLD			= c.standard_cost_eval_and_mgt,
		EMCOST_NEW			= b.standard_cost_eval_and_mgt,
		SPCOST_OLD			= c.standard_cost_surgery_and_proc,
		SPCOST_NEW			= b.standard_cost_surgery_and_proc,
		RXCOST_OLD			= c.standard_cost_pharmacy,
		RXCOST_NEW			= b.standard_cost_pharmacy,
		IPFREQ_OLD			= c.frequency_inpatient,
		IPFREQ_NEW			= b.frequency_inpatient,
		EDFREQ_OLD			= c.frequency_emergency_dept,
		EDFREQ_NEW			= b.frequency_emergency_dept
from	#metrics_coc a
		left join #new_coc b on
			a.report_ending_char_full_date = b.report_ending_char_full_date and
			a.hedis_dss_report_metric_cohort_id = b.hedis_dss_report_metric_cohort_id 
		left join #previous_coc c on
			a.report_ending_char_full_date = c.report_ending_char_full_date and
			a.hedis_dss_report_metric_cohort_id = c.hedis_dss_report_metric_cohort_id
order by 1,2





IF OBJECT_ID('tempdb..#new_svc_dtl') is not null
    DROP TABLE #new_svc_dtl

select	report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric,
		event_count = count(*)
into	#new_svc_dtl
from	dbo.hedis_service_dtl_fact a
		inner join hedis_measure_sub_metric_dim b on
			a.hedis_measure_sub_metric_key = b.hedis_measure_sub_metric_key 
		inner join hedis_member_dim d on
			a.hedis_member_key = d.hedis_member_key
		inner join hedis_service_dtl_indicative_dim e on
			a.hedis_service_dtl_indicative_key = e.hedis_service_dtl_indicative_key
		inner join hedis_service_dtl_claim_hdr_dim e2 on
			a.hedis_service_dtl_claim_hdr_key = e2.hedis_service_dtl_claim_hdr_key
		inner join hedis_service_dtl_claim_dtl_dim e3 on
			a.hedis_service_dtl_claim_dtl_key = e3.hedis_service_dtl_claim_dtl_key
		inner join hedis_service_dtl_lab_result_dim e4 on
			a.hedis_service_dtl_lab_result_key = e4.hedis_service_dtl_lab_result_key
		inner join hedis_service_dtl_pharmacy_claim_dim e5 on
			a.hedis_service_dtl_pharmacy_claim_key = e5.hedis_service_dtl_pharmacy_claim_key
		inner join hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
group by report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric




IF OBJECT_ID('tempdb..#previous_svc_dtl') is not null
    DROP TABLE #previous_svc_dtl

select	report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric,
		event_count = count(*)
into	#previous_svc_dtl
from	NCQA_QI09_PROD.dbo.hedis_service_dtl_fact a
		inner join NCQA_QI09_PROD.dbo.hedis_measure_sub_metric_dim b on
			a.hedis_measure_sub_metric_key = b.hedis_measure_sub_metric_key 
		inner join NCQA_QI09_PROD.dbo.hedis_member_dim d on
			a.hedis_member_key = d.hedis_member_key
		inner join NCQA_QI09_PROD.dbo.hedis_service_dtl_indicative_dim e on
			a.hedis_service_dtl_indicative_key = e.hedis_service_dtl_indicative_key
		inner join NCQA_QI09_PROD.dbo.hedis_service_dtl_claim_hdr_dim e2 on
			a.hedis_service_dtl_claim_hdr_key = e2.hedis_service_dtl_claim_hdr_key
		inner join NCQA_QI09_PROD.dbo.hedis_service_dtl_claim_dtl_dim e3 on
			a.hedis_service_dtl_claim_dtl_key = e3.hedis_service_dtl_claim_dtl_key
		inner join NCQA_QI09_PROD.dbo.hedis_service_dtl_lab_result_dim e4 on
			a.hedis_service_dtl_lab_result_key = e4.hedis_service_dtl_lab_result_key
		inner join NCQA_QI09_PROD.dbo.hedis_service_dtl_pharmacy_claim_dim e5 on
			a.hedis_service_dtl_pharmacy_claim_key = e5.hedis_service_dtl_pharmacy_claim_key
		inner join NCQA_QI09_PROD.dbo.hedis_report_ending_date_dim rptdt on
			a.hedis_report_ending_date_key = rptdt.hedis_report_ending_date_key
group by report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric






IF OBJECT_ID('tempdb..#metrics_svc_dtl') is not null
    DROP TABLE #metrics_svc_dtl

select	distinct
		report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric
into	#metrics_svc_dtl
from	#new_svc_dtl
union
select	distinct
		report_ending_char_full_date,
		hedis_measure_id,
		hedis_measure_name,
		hedis_measure_sub_metric_class,
		hedis_measure_sub_metric
from	#previous_svc_dtl



select	a.report_ending_char_full_date,
		a.hedis_measure_id,
		a.hedis_measure_name,
		a.hedis_measure_sub_metric_class,
		a.hedis_measure_sub_metric,
		EVENTCNT_CHG		= isnull(b.event_count,0)-isnull(c.event_count,0)	,
		EVENTCNT_OLD		= c.event_count,
		EVENTCNT_NEW		= b.event_count
from	#metrics_svc_dtl a
		left join #new_svc_dtl b on
			a.report_ending_char_full_date = b.report_ending_char_full_date and
			a.hedis_measure_id = b.hedis_measure_id and
			a.hedis_measure_name = b.hedis_measure_name and
			a.hedis_measure_sub_metric_class = b.hedis_measure_sub_metric_class and
			a.hedis_measure_sub_metric = b.hedis_measure_sub_metric 
		left join #previous_svc_dtl c on
			a.report_ending_char_full_date = c.report_ending_char_full_date and
			a.hedis_measure_id = c.hedis_measure_id and
			a.hedis_measure_name = c.hedis_measure_name and
			a.hedis_measure_sub_metric_class = c.hedis_measure_sub_metric_class and
			a.hedis_measure_sub_metric = c.hedis_measure_sub_metric 
order by 1,2

GO
