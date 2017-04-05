SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[rpt_hedis_indicator_summary]
as




select	report_ending_char_full_date,
		c.hedis_measure_type,
		hedis_report_metric_id,
		hedis_report_metric_desc,
		
		eligible_population			= sum(hedis_eligible_value),
		denominator					= sum(denominator_value),
		numerator					= sum(numerator_value),
		exclusion					= sum(exclusion_value),
		numerator_neg				= sum(numerator_negative_value),

		denominator_mr				= sum(denominator_medical_record_value),
		numerator_mr				= sum(numerator_medical_record_value),
		exclusion_mr				= sum(exclusion_medical_record_value),
		numerator_neg_mr			= sum(numerator_negative_medical_record_value),

		denominator_hyb				= sum(denominator_hybrid_value),
		numerator_hyb				= sum(numerator_hybrid_value),
		exclusion_hyb				= sum(exclusion_hybrid_value),
		numerator_neg_hyb			= sum(numerator_negative_hybrid_value)
		
--select top 10 * 
--select 711628-count(*)
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



--select top 10 * from hedis_report_metric_dim



--where	hedis_eligible_value = 1 and
--		exclusion_value = 0 and
--		denominator_value = 1 and
--		exists (	select	*
--					from	dbo.hedis_measure_dim f2
--					where	a.hedis_measure_key = f2.hedis_measure_key and
--							hedis_measure_init = 'AWC') --and
--		exists (	select	*
--					from	dbo.hedis_member_measure_sample_dim b2
--					where	a.hedis_member_measure_sample_key = b2.hedis_member_measure_sample_key and
--							numerator_pursuit_status = 0 and
--							(sample_type in ('sample','oversample') or hedis_measure_init='CDC') ) --and
--		exists (	select	*
--					from	dbo.hedis_medical_record_site_dim c2
--					where	a.hedis_medical_record_site_key = c2.hedis_medical_record_site_key and
--							medical_group_name_qarr = 'Access Medical Group')
--order by 1,2,3,8,9



GO
