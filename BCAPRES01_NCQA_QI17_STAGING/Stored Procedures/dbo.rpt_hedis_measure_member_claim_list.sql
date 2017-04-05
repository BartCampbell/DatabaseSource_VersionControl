SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*

exec rpt_hedis_indicator_summary

exec rpt_hedis_measure_member_list
		@lchedis_report_metric_id = 'ASM3',  
		@lidenominator_value = '1',
		@linumerator_value = '3',
		@liexclusion_value = '3',
		@linumerator_negative_value = '3'


exec rpt_hedis_measure_member_claim_list
		@lchedis_measure_id = 'BCS',  
		@lcCustomerMemberID = '00006276001',
		@lchedis_measure_sub_metric_class = 'Exclusion'

exec NCQA_IHDS_DS01..rpt_member_detail '16895'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '16895', 'ASM-A'
exec NCQA_IHDS_DS01..rpt_member_detail '31033'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '31033', 'CMC-B'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '31033', 'CMC-A'
exec NCQA_IHDS_DS01..rpt_member_detail '25612'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '25612', 'CMC-B'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '25612', 'CMC-C'
exec NCQA_IHDS_DS01..rpt_member_detail_hedis_codeset '25612', 'CMC-A'

select ihds_member_id from NCQA_IHDS_DS01..Member where CustomerMemberID = '00000212401'

select	*
from	NCQA_IHDS_DS01..dw_hedis_pharmacy a
		inner join ncqa_rdsm..tblNDCListing2008 b on
			a.ndc_code = b.ndc_code and
			measureid = 'ASM-C' and
			[ROUTE] <> 'inhalation'
where	ihds_member_id = '1280'


*/
CREATE proc [dbo].[rpt_hedis_measure_member_claim_list]

		@lchedis_measure_id VARCHAR(8) = '',  
		@lcCustomerMemberID VARCHAR(20) = '',  
		@lchedis_measure_sub_metric_class varchar(50) = ''
AS


--declare @lchedis_measure_id VARCHAR(8),
--		@lcCustomerMemberID VARCHAR(20),
--		@lchedis_measure_sub_metric_class varchar(50)
--
--set		@lchedis_measure_id			= 'BCS'
--set		@lcCustomerMemberID					= '3433210'
--set		@lchedis_measure_sub_metric_class	= 'Numerator'

--select top 10 * from hedis_service_dtl_claim_dtl_dim

select	hedis_measure_sub_metric,
		service_date_begin,
		diagnosis_1,
		diagnosis_2,
		diagnosis_3,
		diagnosis_4,
		icd9_proc1,
		icd9_proc2,
		drg,
		place_of_service,
		bill_type,
		e3.procedure_cpt,
		procedure_hcpcs,
		procedure_revenue_code,
		procedure_cpt_II,
		modifier_1,
		ndc_code,
		ndc_desc,
		claim_number,
		datasource
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
where	exists (	select	*
					from	dbo.hedis_measure_sub_metric_dim b2
					where	a.hedis_measure_sub_metric_key = b2.hedis_measure_sub_metric_key and
							hedis_measure_sub_metric_class = @lchedis_measure_sub_metric_class and
							hedis_measure_id = @lchedis_measure_id  ) and
		exists (	select	*
					from	dbo.hedis_member_dim d2
					where	a.hedis_member_key = d2.hedis_member_key and
							Subscriber_no = @lcCustomerMemberID  ) 

GO
