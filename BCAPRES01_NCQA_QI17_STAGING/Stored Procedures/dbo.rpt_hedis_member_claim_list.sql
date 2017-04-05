SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--rpt_hedis_member_claim_list '179495'

CREATE procedure [dbo].[rpt_hedis_member_claim_list]
	@ihds_member_id int
as

--declare @ihds_member_id int
--set		@ihds_member_id = '179495'


select	Age_20071231 = datediff(yy,DateOfBirth,'12/31/2007'),
		DateOfBirth,
		Gender ,
		*
from	member 
where ihds_member_id = @ihds_member_id

print 'BCS-A like procedures'
select	b.DateServiceBegin,
		CPTProcedureCode,
		--CPT_SHORT_DESC,
		RevenueCode,
		HCPCSProcedureCode,
		PlaceOfService,
		DiagnosisCode1,
		DiagnosisCode2,
		DiagnosisCode3,
		DiagnosisCode4,
		DiagnosisCode5,
		DiagnosisCode6,
		DiagnosisCode7,
		DiagnosisCode8,
		DiagnosisCode9,
				*
from	hh08_ihds_ds01..Claim a
		inner join hh08_ihds_ds01..ClaimLineItem b on
			a.ClaimID = b.ClaimID
		inner join hh08_ihds_ds01..Member c on
			a.MemberID = c.MemberID
--		left join imicodestore..CPT d on
--			b.CPTProcedureCode = d.CPT_CD
where	c.ihds_member_id = @ihds_member_id and
		left(CPTProcedureCode,3) in ('760','770','G02')
order by 1


select	b.DateServiceBegin,
		CPTProcedureCode,
		--CPT_SHORT_DESC,
		RevenueCode,
		HCPCSProcedureCode,
		PlaceOfService,
		DiagnosisCode1,
		DiagnosisCode2,
		DiagnosisCode3,
		DiagnosisCode4,
		DiagnosisCode5,
		DiagnosisCode6,
		DiagnosisCode7,
		DiagnosisCode8,
		DiagnosisCode9,
				*
from	hh08_ihds_ds01..Claim a
		inner join hh08_ihds_ds01..ClaimLineItem b on
			a.ClaimID = b.ClaimID
		inner join hh08_ihds_ds01..Member c on
			a.MemberID = c.MemberID
--		left join imicodestore..CPT d on
--			b.CPTProcedureCode = d.CPT_CD
where	c.ihds_member_id = @ihds_member_id
order by 1

select	DateEffective,
		DateTerminated,
		*
from	eligibility a
		inner join member b on
			a.memberid = b.memberid
where	b.ihds_member_id = @ihds_member_id
GO
