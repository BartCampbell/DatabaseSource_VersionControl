SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE proc [dbo].[rpt_hedis_coc_summary]
as

--select top 10 * from hedis_dss_age_dim

--select	ras_dss_product_line,
--		ras_std_price_inpatient		= sum(ras_std_price_inpatient),
--		ras_std_price_em			= sum(ras_std_price_em),
--		ras_std_price_surg			= sum(ras_std_price_surg),
--		ras_std_price_pharm			= sum(ras_std_price_pharm),
--		ras_freq_inpatient			= sum(ras_freq_inpatient),
--		ras_freq_ed					= sum(ras_freq_ed),
--		ras_freq_obs				= sum(ras_freq_obs),
--		ras_medical_member_months	= sum(ras_medical_member_months),
--		ras_rx_member_months		= sum(ras_rx_member_months)
--from	utb_hedis_ras
--group by ras_dss_product_line

select	--subscriber_no, person_no,
		--g.hedis_measure_init,
		--hedis_ras_age_cohort,
		--gender_code,
		hedis_product_line_code,
		hedis_coc_clinical_category_desc,
		hedis_coc_comorbidity_desc,
		eligible_population_count	= sum(eligible_population_count),
		medical_member_months	= sum(medical_member_months),
		rx_member_months		= sum(rx_member_months),
		standard_cost_inpatient				= sum(standard_cost_inpatient),
		standard_cost_eval_and_mgt			= sum(standard_cost_eval_and_mgt),
		standard_cost_surgery_and_proc		= sum(standard_cost_surgery_and_proc),
		standard_cost_pharmacy				= sum(standard_cost_pharmacy),
		frequency_inpatient				= sum(frequency_inpatient),
		frequency_emergency_dept			= sum(frequency_emergency_dept)
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
where	exists (	select	*
					from	hedis_measure_dim g2
					where	a.hedis_measure_key = g2.hedis_measure_key and
							g2.hedis_measure_init = 'RAS')
group by --subscriber_no, person_no,
		--g.hedis_measure_init,
		--hedis_ras_age_cohort,
		--gender_code,
		hedis_product_line_code,
		hedis_coc_clinical_category_desc,
		hedis_coc_comorbidity_desc
order by 1,2,3,4


--lob                  comorbid_categorization type_1_elig_pop type_2_elig_pop
---------------------- ----------------------- --------------- ---------------
--CHP                  without_comorbidity     1               3
--MLI                  with_comorbidity        112             575
--MLI                  without_comorbidity     50              301
--
--
--
--
--select	hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort,
--		medical_member_months	= sum(medical_member_months),
--		rx_member_months		= sum(rx_member_months)
----select	top 10 *
--from	HEDIS_REPORT_METRIC_COC_FACT a
--		inner join gender_dim b on
--			a.gender_key = b.gender_key
--		inner join hedis_dss_age_dim c on
--			a.hedis_dss_age_key = c.hedis_dss_age_key
--		inner join hedis_coc_comorbidity_dim d on
--			a.hedis_coc_comorbidity_key = d.hedis_coc_comorbidity_key
--		inner join hedis_coc_clinical_category_dim e on
--			a.hedis_coc_clinical_category_key = e.hedis_coc_clinical_category_key
--		inner join hedis_product_line_dim f on
--			a.hedis_product_line_key = f.hedis_product_line_key
--group by hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort
--order by 1,2,3,4,5
--
--
----lob                  age_cohort with_comorb_med_mm_male with_comorb_med_mm_female without_comorb_med_mm_male without_comorb_med_mm_female
------------------------ ---------- ----------------------- ------------------------- -------------------------- ----------------------------
----MLI                  1844       36                      251                       132                        198
----MLI                  4554       251                     239                       36                         96
----MLI                  5564       108                     408                       12                         96
----MLI                  6575       12                      36                        12                         12
--
--
--select	hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort,
--		standard_cost_inpatient				= sum(standard_cost_inpatient),
--		standard_cost_eval_and_mgt			= sum(standard_cost_eval_and_mgt),
--		standard_cost_surgery_and_proc		= sum(standard_cost_surgery_and_proc),
--		standard_cost_pharmacy				= sum(standard_cost_pharmacy)
----select	top 10 *
--from	HEDIS_REPORT_METRIC_COC_FACT a
--		inner join gender_dim b on
--			a.gender_key = b.gender_key
--		inner join hedis_dss_age_dim c on
--			a.hedis_dss_age_key = c.hedis_dss_age_key
--		inner join hedis_coc_comorbidity_dim d on
--			a.hedis_coc_comorbidity_key = d.hedis_coc_comorbidity_key
--		inner join hedis_coc_clinical_category_dim e on
--			a.hedis_coc_clinical_category_key = e.hedis_coc_clinical_category_key
--		inner join hedis_product_line_dim f on
--			a.hedis_product_line_key = f.hedis_product_line_key
--group by hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort
--order by 1,2,3,4,5
--
--
--
--
--
--select	hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort,
--		frequency_inpatient				= sum(frequency_inpatient),
--		frequency_emergency_dept			= sum(frequency_emergency_dept)
----select	top 10 *
--from	HEDIS_REPORT_METRIC_COC_FACT a
--		inner join gender_dim b on
--			a.gender_key = b.gender_key
--		inner join hedis_dss_age_dim c on
--			a.hedis_dss_age_key = c.hedis_dss_age_key
--		inner join hedis_coc_comorbidity_dim d on
--			a.hedis_coc_comorbidity_key = d.hedis_coc_comorbidity_key
--		inner join hedis_coc_clinical_category_dim e on
--			a.hedis_coc_clinical_category_key = e.hedis_coc_clinical_category_key
--		inner join hedis_product_line_dim f on
--			a.hedis_product_line_key = f.hedis_product_line_key
--group by hedis_product_line_code,
--		hedis_coc_clinical_category_desc,
--		hedis_coc_comorbidity_desc,
--		gender_desc,
--		hedis_rdi_age_cohort
--order by 1,2,3,4,5
--
--
--
GO
