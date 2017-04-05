SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[rpt_member_detail]
@ihds_member_id int
as

/*
This is a temporary sp to facilitate testing created by Randy Wilson
*/

-------------------------------------------------
--DECLARE @ihds_member_id int
--SET @ihds_member_id = '1224462'
-------------------------------------------------

DECLARE @MemberID int 
SET @MemberID =	(select	MemberID
				from	ncqa_qi10_staging..Member 
				where	ihds_member_id = @ihds_member_id)
print @MemberID



print 'Member'
select	CustomerMemberID,
		ihds_member_id,
		HedisMeasureID,
		DateOfBirth,
		Gender,
		*
from	Member
where	MemberID = @MemberID


print 'Eligibility'
select	DateEffective,
		DateTerminated,
		*
from	Eligibility e
where	MemberID = @MemberID
order by 1,2


print 'Claim'
select	DateServiceBegin,
		DateServiceEnd,
		DiagnosisCode1,
		DiagnosisCode2,
		DiagnosisCode3,
		DiagnosisCode4,
		DiagnosisCode5,
		DiagnosisCode6,
		DiagnosisCode7,
		DiagnosisCode8,
		DiagnosisCode9,
		DiagnosisCode10,
		TaxID,
		DischargeStatus,
		DiagnosisRelatedGroup,
		SurgicalProcedure1,
		SurgicalProcedure2,
		SurgicalProcedure3,
		SurgicalProcedure4,
		SurgicalProcedure5,
		SurgicalProcedure6,
		* --select top 10 *
from	claim a
		LEFT JOIN provider b ON
			a.ServicingProviderID = b.ProviderID
where	MemberID = @MemberID
order by 1,2




print 'ClaimLineItem'
select	a.DateServiceBegin,
		a.DateServiceEnd,
		a.CPTProcedureCode,
		a.CPTProcedureCodeModifier1,
		RevenueCode,
		HCPCSProcedureCode,
		CPT_II,
		a.* 
from	claimlineitem a
		inner join claim b on
			a.claimid = b.claimid
where	MemberID = @MemberID
order by 1,3,4,5

print 'LabResult'
select	DateOfService,
		HCPCSProcedureCode,
		LOINCCode,
		LabValue,
		PNIndicator,
		*  --select top 10 *
from	LabResult
where	MemberID = @MemberID
order by 1,2,3


print 'Pharmacy'
select	DateDispensed,
		NDC,
		Quantity,
		DaysSupply,
		* --select top 10 *
from	PharmacyClaim
where	MemberID = @MemberID
order by 1,2,3



GO
