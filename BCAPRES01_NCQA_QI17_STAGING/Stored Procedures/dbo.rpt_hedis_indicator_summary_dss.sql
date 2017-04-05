SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[rpt_hedis_indicator_summary_dss]
		@report_ending_char_full_date	varchar(8)
as
--exec rpt_hedis_indicator_summary_dss '20071201'
--declare @report_ending_char_full_date varchar(8)
--set		@report_ending_char_full_date = '20071201'

select	c.hedis_measure_type,
		b.hedis_report_metric_id,
		b.hedis_report_metric_desc,
		
		eligible_population			= sum(hedis_eligible_value),
		denominator					= sum(denominator_value),
		numerator					= sum(numerator_value),
		exclusion					= sum(exclusion_value),
		admin_metric_rate			= sum(numerator_value*100.0)/sum(denominator_value),
		
		MRSS						= 0,
		FSS							= 0,
		numerator_FSS				= sum(case when denominator_medical_record_value = 1 then numerator_value else 0 end),

		exclusion_mr				= sum(	case	when	denominator_medical_record_value = 1 and
															(exclusion_medical_record_value = 1 or
															sample_void_value = 1)
													then	1 
													else	0 
											end),
		oversample_add				= sum(	case	when	denominator_hybrid_value = 1 and
															sample_type = 'oversample'
													then	1 
													else	0 
											end),
		
		denominator_hyb				= sum(denominator_hybrid_value),
		numerator_hyb				= sum(numerator_hybrid_value),
		exclusion_hyb				= sum(exclusion_hybrid_value),
		numerator_neg_hyb			= sum(numerator_negative_hybrid_value),

		hyb_metric_rate				= case	when sum(denominator_hybrid_value) = 0 
											then 0.00
											else sum(numerator_hybrid_value*100.0)/sum(denominator_hybrid_value)
									  end

--		percentile_10				= max(ncqa07_percentile_10),
--		percentile_25				= max(ncqa07_percentile_25),
--		percentile_50				= max(ncqa07_percentile_50),
--		percentile_75				= max(ncqa07_percentile_75),
--		percentile_90				= max(ncqa07_percentile_90)

--select top 10 * 
--select 711628-count(*)
from	dbo.hedis_report_metric_fact a
		inner join hedis_report_metric_dim b on
			a.hedis_report_metric_key = b.hedis_report_metric_key
		inner join hedis_measure_dim c on
			a.hedis_measure_key = c.hedis_measure_key
		inner join hedis_benchmark_metric_prodline_prod_level_dim d on
			a.hedis_benchmark_metric_prodline_prod_level_key = d.hedis_benchmark_metric_prodline_prod_level_key
		inner join hedis_member_measure_sample_dim e on
			a.hedis_member_measure_sample_key = e.hedis_member_measure_sample_key 
--		inner join hedis_medical_record_site_dim c on
--			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
--		inner join member_dim d on
--			a.member_key = d.member_key
--		inner join pcp_dim e on
--			a.pcp_key = e.pcp_key
where	hedis_eligible_value = 1 and
		denominator_value + exclusion_value > 0 and
		exists (	select	*
					from	hedis_report_ending_date_dim a2
					where	a.hedis_report_ending_date_key = a2.hedis_report_ending_date_key and
							report_ending_char_full_date = @report_ending_char_full_date )
group by c.hedis_measure_type,
		b.hedis_report_metric_id,
		b.hedis_report_metric_order,
		b.hedis_report_metric_desc
order by c.hedis_measure_type,
		b.hedis_report_metric_id,
		b.hedis_report_metric_order,
		b.hedis_report_metric_desc



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
