SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROC [dbo].[rpt_member_detail_hedis_codeset]
@ihds_member_id int,
@tableid_all					varchar(20)
/*
exec rpt_member_detail_hedis_codeset '3085728', 'IPU-A'

created by Randy Wilson
used for results validation
shows full information on a specific ihds_member_id

NOT COMPLETE!!!!!!!

*/
AS

declare @tableid_diagnosis				varchar(20),
		@tableid_diagnosis_principal	varchar(20),
		@tableid_pos					varchar(20),
		@tableid_billtype				varchar(20),
		@tableid_hcpcs					varchar(20),
		@tableid_revenue				varchar(20),
		@tableid_cpt					varchar(20)


set		@tableid_diagnosis	= @tableid_all
set		@tableid_diagnosis_principal = @tableid_all
set		@tableid_pos		= @tableid_all
set		@tableid_billtype	= @tableid_all
set		@tableid_hcpcs		= @tableid_all
set		@tableid_revenue	= @tableid_all
set		@tableid_cpt		= @tableid_all


-------------------------------------------------
--DECLARE @ihds_member_id int
--SET @ihds_member_id = '298'
--
--DECLARE @tableid_diagnosis varchar(20)
--set		@tableid_diagnosis = 'LBP-B'
--
--DECLARE @tableid_diagnosis_principal varchar(20)
--set		@tableid_diagnosis_principal = 'LBP-B'
--
--DECLARE @tableid_pos varchar(20)
--set		@tableid_pos = 'LBP-B'
--
--DECLARE @tableid_billtype varchar(20)
--set		@tableid_billtype = 'LBP-B'
--
--DECLARE @tableid_hcpcs varchar(20)
--set		@tableid_hcpcs = 'LBP-B'
--
--DECLARE @tableid_revenue varchar(20)
--set		@tableid_revenue = 'LBP-B'
--
--DECLARE @tableid_cpt varchar(20)
--set		@tableid_cpt = 'LBP-B'
-------------------------------------------------



--******************************************************************************
--******************************************************************************
--******************************************************************************
--******************************************************************************
/*
codetype
--------------------------------------------------
ICD-9-CM_Diagnosis						#codeset_diagnosis			@tableid_diagnosis
HCPCS
LOINC
ICD-9-CM_Principal_Diagnosis			#codeset_diagnosis_principal @tableid_diagnosis_principal
CDT-3_and_HCPCS
CMS_1500_Place_Of_Service_Codes			#codeset_pos			@tableid_pos
UB-92_Revenue
POS
ICD-9-CM
ICD-9-CM_Procedure
UP-92_Revenue
UB-92_Type_of_Bill						#codeset_billtype	@tableid_billtype
DRG
Place_of_Service_Codes_HCFA_1500
CPT
CPT_Category_II
*/





IF OBJECT_ID('tempdb..#codeset_diagnosis') IS NOT NULL
DROP TABLE #codeset_diagnosis

create table #codeset_diagnosis
(		CodeValue varchar(20) null )

insert into #codeset_diagnosis
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_diagnosis and
		codetype = 'ICD-9-CM_Diagnosis'






IF OBJECT_ID('tempdb..#codeset_diagnosis_principal') IS NOT NULL
DROP TABLE #codeset_diagnosis_principal

create table #codeset_diagnosis_principal
(		CodeValue varchar(20) null )

insert into #codeset_diagnosis_principal
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_diagnosis_principal and
		codetype = 'ICD-9-CM_Principal_Diagnosis'




IF OBJECT_ID('tempdb..#codeset_pos') IS NOT NULL
DROP TABLE #codeset_pos

create table #codeset_pos
(		CodeValue varchar(20) null )

insert into #codeset_pos
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_pos and
		codetype = 'CMS_1500_Place_Of_Service_Codes'




IF OBJECT_ID('tempdb..#codeset_billtype') IS NOT NULL
DROP TABLE #codeset_billtype

create table #codeset_billtype
(		CodeValue varchar(20) null )

insert into #codeset_billtype
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_billtype and
		codetype = 'UB-92_Type_of_Bill'





IF OBJECT_ID('tempdb..#codeset_hcpcs') IS NOT NULL
DROP TABLE #codeset_hcpcs

create table #codeset_hcpcs
(		CodeValue varchar(20) null )

insert into #codeset_hcpcs
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_hcpcs and
		codetype = 'HCPCS'






IF OBJECT_ID('tempdb..#codeset_cpt') IS NOT NULL
DROP TABLE #codeset_cpt

create table #codeset_cpt
(		CodeValue varchar(20) null )

insert into #codeset_cpt
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_cpt and
		codetype = 'CPT'





IF OBJECT_ID('tempdb..#codeset_revenue') IS NOT NULL
DROP TABLE #codeset_revenue

create table #codeset_revenue
(		CodeValue varchar(20) null )

insert into #codeset_revenue
SELECT	distinct
		codevalue
FROM	ncqa_rdsm..tblcodesets
WHERE	tableid = @tableid_revenue and
		codetype = 'UB-92_Revenue'

--******************************************************************************
--******************************************************************************
--******************************************************************************
--******************************************************************************






print 'Member'
select	ihds_member_id,
		dob,
		gender,
		measurement_end_age	=	datepart(yyyy,'20071231')
								-datepart(yyyy,dob)
								-	case	when right(dob,4)>right(convert(varchar(8),'20071231',112),4) 
											then 1 
											else 0 
									end,
		* 
from	dw_hedis_member
where	ihds_member_id = @ihds_member_id


print 'Eligibility'
select	a.lob,
		a.eff_date,
		a.term_date,
		gap_days	= datediff(	dd,
								(	select	max(b.term_date)
									from	dw_hedis_member_elig b
									where	a.ihds_member_id = b.ihds_member_id and
											b.term_date < a.eff_date),
								a.eff_date)-1,
		*
from	dw_hedis_member_elig a
where	a.ihds_member_id = @ihds_member_id
order by 1,2





print	'Diagnosis'
select	service_date,
		diag_code_source,
		diag_code,
		diag_code_hit				= case when dx.codevalue is null then '' else 'Y' end,
		diag_code_pr_hit			= case when dx_pr.codevalue is null then '' else 'Y' end,
		place_of_service,
		place_of_service_hit		= case when pos.codevalue is null then '' else 'Y' end,
		bill_type,
		bill_type_hit				= case when billtype.codevalue is null then '' else 'Y' end,
		prov_spec,
		discharge_status,
		admit_date,
		thru_date,
		claim_status,
		*
from	dw_hedis_diag_list a
		left join #codeset_diagnosis dx on
			a.diag_code = dx.codevalue
		left join #codeset_diagnosis_principal dx_pr on
			a.diag_code = dx_pr.codevalue
		left join #codeset_billtype billtype on
			a.bill_type = billtype.codevalue
		left join #codeset_pos pos on
			a.place_of_service = pos.codevalue
where	a.ihds_member_id = @ihds_member_id
order by 1




print	'Procedure'
select	service_date,
		procedure_code,
		procedure_code_cpt_hit			= case when cpt.codevalue is null then '' else 'Y' end,
		procedure_code_hcpcs_hit		= case when hcpcs.codevalue is null then '' else 'Y' end,
		procedure_code_revenue_hit		= case when revenue.codevalue is null then '' else 'Y' end,
		procedure_modifier2,
		place_of_service,
		place_of_service,
		place_of_service_hit			= case when pos.codevalue is null then '' else 'Y' end,
		bill_type,
		bill_type_hit					= case when billtype.codevalue is null then '' else 'Y' end,
		prov_spec,
		* 
from	dw_hedis_proc_list a
		left join #codeset_cpt cpt on
			a.procedure_code = cpt.codevalue
		left join #codeset_revenue revenue on
			a.procedure_code = revenue.codevalue
		left join #codeset_hcpcs hcpcs on
			a.procedure_code = hcpcs.codevalue
		left join #codeset_billtype billtype on
			a.bill_type = billtype.codevalue
		left join #codeset_pos pos on
			a.place_of_service = pos.codevalue
where	a.ihds_member_id = @ihds_member_id
order by 1


--
--declare	@subno varchar(20)
--declare @persno varchar(2)
--
--set	@subno = left((	select	mem_pk3
--					from	dw_xref_ihds_member_id
--					where	ihds_member_id = @ihds_member_id),7)
--set	@persno = right((	select	mem_pk3
--						from	dw_xref_ihds_member_id
--						where	ihds_member_id = @ihds_member_id),2)
--print 'x'+@subno+'x'
--print 'x'+@persno+'x'
--
--select	CAPRIMDATE,
--		CBPROCCODE,
--		CBQUANT,
--		CBNET,
--		CBCLAIMSTAT,
--		CAPROVTYPE,
--		CAPROVSPEC,
--		CAPLACE,
--		CABILLTYPE
--FROM	HHPD_RDSM..JINSTDM0_dat a  
--		INNER JOIN HHPD_RDSM..JINSTHM0_dat b on
--			a.cbdate = b.caprimdate and
--			a.cbclaim = b.caclaim
--WHERE	cbnotcovrsn NOT IN ( 'EXDUP', 'MH/SA','MHSA*' )
--		AND cbproccode <> 'UNKCODE'
--		AND cbclaim <> '0000000000000001'
--		AND	CASUBNO = @subno
--		AND CAPERSNO = @persno
--order by 1
--
--
--
--select	CAPRIMDATE,
--		CBPROCCODE,
--		CBQUANT,
--		CBNET,
--		CBCLAIMSTAT,
--		CAPROVTYPE,
--		CAPROVSPEC,
--		CAPLACE
--FROM	HHPD_RDSM..JUTILDM0_dat a  
--		INNER JOIN HHPD_RDSM..JUTILHM0_dat b on
--			a.cbdate = b.caprimdate and
--			a.cbclaim = b.caclaim
--WHERE	cbnotcovrsn NOT IN ( 'EXDUP', 'MH/SA', 'MHSA*' )
--		AND cbproccode <> 'UNKCODE'
--		AND	CASUBNO = @subno
--		AND CAPERSNO = @persno
--order by 1
--
GO
