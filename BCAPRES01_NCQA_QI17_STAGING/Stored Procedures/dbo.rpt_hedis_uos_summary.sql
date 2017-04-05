SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE proc [dbo].[rpt_hedis_uos_summary]

as

--select top 10 * from hedis_benchmark_metric_uos_prodline_prod_level_dim a

select	
		hedis_product_line_code,
		hedis_dss_report_metric_cohort_desc
		,visit_event_value			= sum(visit_event_value)
		,procedure_event_value		= sum(procedure_event_value)
		,member_months_value		= sum(member_months_value)
		,member_months_value		= sum(member_months_value)
		,visit1000					= sum(visit_event_value*1000.0)/sum(member_months_value)
		,visit1000_percentile_10		= max(visit1000_percentile_10)
		,visit1000_percentile_90		= max(visit1000_percentile_90)
		,service1000_percentile_10		= max(service1000_percentile_10)
		,service1000_percentile_90		= max(service1000_percentile_90)
		
--select count(*) 
--select top 100 *
--select sum(visit_event_value), sum(procedure_event_value)
from	hedis_report_metric_uos_fact a
		inner join hedis_report_metric_uos_cohort_dim b on
			a.hedis_report_metric_uos_cohort_key = b.hedis_report_metric_uos_cohort_key
		inner join hedis_product_line_dim c on
			a.hedis_product_line_key = c.hedis_product_line_key
		inner join hedis_benchmark_metric_uos_prodline_prod_level_dim d on
			a.hedis_benchmark_metric_uos_prodline_prod_level_key = d.hedis_benchmark_metric_uos_prodline_prod_level_key
group by hedis_product_line_code,
		hedis_dss_report_metric_cohort_desc,
		b.hedis_dss_report_metric_cohort_id
order by hedis_product_line_code,
		b.hedis_dss_report_metric_cohort_id

GO
