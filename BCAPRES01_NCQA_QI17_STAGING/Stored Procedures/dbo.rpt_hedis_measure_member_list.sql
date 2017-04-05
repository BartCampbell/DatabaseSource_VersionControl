SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*

exec rpt_hedis_indicator_summary

exec rpt_hedis_measure_member_list
		@lchedis_report_metric_id = 'BCS2',  
		@lidenominator_value = '',
		@linumerator_value = '',
		@liexclusion_value = '1',
		@linumerator_negative_value = ''

*/
CREATE proc [dbo].[rpt_hedis_measure_member_list]

		@lchedis_report_metric_id VARCHAR(8) = '',  --ASM1,ASM2...
		@lidenominator_value int = 3,
		@linumerator_value int = 3,
		@liexclusion_value int = 3,
		@linumerator_negative_value int = 3

as


--declare @lchedis_report_metric_id VARCHAR(8),
--		@lidenominator_value int,
--		@linumerator_value int,
--		@liexclusion_value int,
--		@linumerator_negative_value int
--
--set		@lchedis_report_metric_id		= 'BCS2'
--set		@lidenominator_value			= 3
--set		@linumerator_value				= 3
--set		@liexclusion_value				= 1
--set		@linumerator_negative_value		= 3


select	hedis_report_metric_id,
		hedis_report_metric_desc
from	hedis_report_metric_dim
where	hedis_report_metric_id = @lchedis_report_metric_id

select	ihds_member_id,
		Subscriber_no,
		Full_name					= left(Full_name,25),
		DOB,
		eligible_population			= hedis_eligible_value,
		denominator					= denominator_value,
		numerator					= numerator_value,
		exclusion					= exclusion_value,
		numerator_neg				= numerator_negative_value
		
--select top 10 * 
--select 711628-count(*)
from	dbo.hedis_report_metric_fact a
		inner join hedis_report_metric_dim b on
			a.hedis_report_metric_key = b.hedis_report_metric_key
		inner join hedis_measure_dim c on
			a.hedis_measure_key = c.hedis_measure_key
--		inner join hedis_member_measure_sample_dim b on
--			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
--		inner join hedis_medical_record_site_dim c on
--			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
		inner join member_dim d on
			a.member_key = d.member_key
		inner join NCQA_IHDS_DS01..member d2 on
			d.Subscriber_no = d2.ihds_member_id
--		inner join pcp_dim e on
--			a.pcp_key = e.pcp_key
where	hedis_eligible_value = 1 and
		denominator_value = case when @lidenominator_value = 3 then denominator_value else @lidenominator_value end and
		numerator_value = case when @linumerator_value = 3 then numerator_value else @linumerator_value end and
		exclusion_value = case when @liexclusion_value = 3 then exclusion_value else @liexclusion_value end and
		numerator_negative_value = case when @linumerator_negative_value = 3 then numerator_negative_value else @linumerator_negative_value end and
		exists (	select	*
					from	hedis_report_metric_dim b2
					where	b2.hedis_report_metric_id = @lchedis_report_metric_id and
							a.hedis_report_metric_key = b2.hedis_report_metric_key )
order by Full_name


select	count(*),
		eligible_population			= sum(hedis_eligible_value),
		denominator					= sum(denominator_value),
		numerator					= sum(numerator_value),
		exclusion					= sum(exclusion_value),
		numerator_neg				= sum(numerator_negative_value)
		
--select top 10 * 
--select 711628-count(*)
from	dbo.hedis_report_metric_fact a
		inner join hedis_report_metric_dim b on
			a.hedis_report_metric_key = b.hedis_report_metric_key
		inner join hedis_measure_dim c on
			a.hedis_measure_key = c.hedis_measure_key
--		inner join hedis_member_measure_sample_dim b on
--			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
--		inner join hedis_medical_record_site_dim c on
--			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
		inner join member_dim d on
			a.member_key = d.member_key
--		inner join pcp_dim e on
--			a.pcp_key = e.pcp_key
where	hedis_eligible_value = 1 and
		denominator_value = case when @lidenominator_value = 3 then denominator_value else @lidenominator_value end and
		numerator_value = case when @linumerator_value = 3 then numerator_value else @linumerator_value end and
		exclusion_value = case when @liexclusion_value = 3 then exclusion_value else @liexclusion_value end and
		numerator_negative_value = case when @linumerator_negative_value = 3 then numerator_negative_value else @linumerator_negative_value end and
		exists (	select	*
					from	hedis_report_metric_dim b2
					where	b2.hedis_report_metric_id = @lchedis_report_metric_id and
							a.hedis_report_metric_key = b2.hedis_report_metric_key )




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
