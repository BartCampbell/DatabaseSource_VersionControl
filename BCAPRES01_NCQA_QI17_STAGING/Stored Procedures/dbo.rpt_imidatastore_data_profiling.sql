SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[rpt_imidatastore_data_profiling]

AS
/*
exec rpt_imidatastore_data_profiling
*/

declare	@Member_rowcount		int,
		@Eligibility_rowcount	int,
		@Provider_rowcount		int,
		@LabResult_rowcount		int,
		@PharmacyClaim_rowcount	int,
		@Claim_rowcount			int,
		@ClaimLineItem_rowcount	int

select	@Member_rowcount		= count(*) from Member
select	@Eligibility_rowcount	= count(*) from Eligibility
select	@Provider_rowcount		= count(*) from Provider
select	@LabResult_rowcount		= count(*) from LabResult
select	@PharmacyClaim_rowcount = count(*) from PharmacyClaim
select	@Claim_rowcount			= count(*) from Claim
select	@ClaimLineItem_rowcount = count(*) from ClaimLineItem


IF OBJECT_ID('tempdb..#hedis_profiling_validation_summary_error_codes') IS NOT NULL
	DROP TABLE #hedis_profiling_validation_summary_error_codes

create table #hedis_profiling_validation_summary_error_codes
(		validation_code		varchar(3),
		validation_desc		varchar(100),
		table_rows_total	int)

insert into #hedis_profiling_validation_summary_error_codes
select	'001', 'Empty Member.CustomerMemberID', @Member_rowcount union all
select	'002', 'Multiple records with same Member.CustomerMemberID', @Member_rowcount union all
select	'003', 'Invalid Member.Gender', @Member_rowcount union all
select	'004', 'Member.DateOfBirth is Empty', @Member_rowcount union all
select	'005', 'Member.DateOfBirth is outside of expected range (01/01/1875 through today)', @Member_rowcount union all
select	'006', 'Invalid Member.Race', @Member_rowcount union all
select	'007', 'Invalid Member.Ethnicity', @Member_rowcount union all
select	'008', 'Invalid Member.InterpreterFlag', @Member_rowcount union all
select	'009', 'Invalid Member.MemberLanguage', @Member_rowcount union all
select	'010', 'Eligibility.MemberID has no corresponding record in Member table', @Eligibility_rowcount union all
select	'011', 'Eligibility.DateEffective > Eligibility.DateTerminated', @Eligibility_rowcount union all
select	'012', 'Invalid Eligibility.ProductType', @Eligibility_rowcount union all
select	'013', 'Invalid Eligibility.HealthPlanEmployeeFlag', @Eligibility_rowcount union all
select	'014', 'Invalid Eligibility.CoverageDentalFlag', @Eligibility_rowcount union all
select	'015', 'Invalid Eligibility.CoveragePharmacyFlag', @Eligibility_rowcount union all
select	'016', 'Invalid Eligibility.CoverageMHInpatientFlag', @Eligibility_rowcount union all
select	'017', 'Invalid Eligibility.CoverageMHDayNightFlag', @Eligibility_rowcount union all
select	'018', 'Invalid Eligibility.CoverageMHAmbulatoryFlag', @Eligibility_rowcount union all
select	'019', 'Invalid Eligibility.CoverageCDInpatientFlag', @Eligibility_rowcount union all
select	'020', 'Invalid Eligibility.CoverageCDDayNightFlag', @Eligibility_rowcount union all
select	'021', 'Invalid Eligibility.CoverageCDAmbulatoryFlag', @Eligibility_rowcount union all
select	'022', 'Empty Provider.TaxID', @Provider_rowcount union all--fix, should be a CustomerProviderID 
select	'023', 'Multiple records with same Provider.TaxID', @Provider_rowcount union all --fix, should be a CustomerProviderID 
select	'024', 'Invalid Provider.ProviderPrescribingPrivFlag', @Provider_rowcount union all
select	'025', 'Invalid Provider.PCPFlag', @Provider_rowcount union all
select	'026', 'Invalid Provider.OBGynFlag', @Provider_rowcount union all
select	'027', 'Invalid Provider.MentalHealthFlag', @Provider_rowcount union all
select	'028', 'Invalid Provider.EyeCareFlag', @Provider_rowcount union all
select	'029', 'Invalid Provider.DentistFlag', @Provider_rowcount union all
select	'030', 'Invalid Provider.NephrologistFlag', @Provider_rowcount union all
select	'031', 'Invalid Provider.CDProviderFlag', @Provider_rowcount union all
select	'032', 'Invalid Provider.NursePractFlag', @Provider_rowcount union all
select	'033', 'Invalid Provider.PhysicianAsstFlag', @Provider_rowcount union all
select	'034', 'Provider.ProviderPrescribingPrivFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'035', 'Provider.PCPFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'036', 'Provider.OBGynFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'037', 'Provider.MentalHealthFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'038', 'Provider.EyeCareFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'039', 'Provider.DentistFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'040', 'Provider.NephrologistFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'041', 'Provider.CDProviderFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'042', 'Provider.NursePractFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'043', 'Provider.PhysicianAsstFlag=N and high volume of potentially qualifying claims', @Provider_rowcount union all
select	'044', 'LabResult.MemberID has no corresponding record in Member table', @LabResult_rowcount union all
select	'045', 'Multiple records with same LabResult.ClaimNumber+LabResult.ClaimSequenceNumber', @LabResult_rowcount union all
select	'046', 'Nonempty LabResult.HCPCSProcedureCode is other than 5 characters', @LabResult_rowcount union all
select	'047', 'LabResult.LOINCCode of invalid format', @LabResult_rowcount union all
select	'048', 'Invalid LabResult.PNIndicator', @LabResult_rowcount union all
select	'049', 'PharmacyClaim.MemberID has no corresponding record in Member table', @PharmacyClaim_rowcount union all
select	'050', 'Multiple records with same PharmacyClaim.ClaimNumber', @PharmacyClaim_rowcount union all
select	'051', 'PharmacyClaim.NDC of invalid format', @PharmacyClaim_rowcount union all
select	'052', 'Invalid PharmacyClaim.SupplyFlag', @PharmacyClaim_rowcount union all
select	'053', 'Invalid PharmacyClaim.ClaimStatus', @PharmacyClaim_rowcount union all
select	'054', 'Multiple records with same Claim.PayerClaimID+Claim.PayerClaimIDSuffix+ClaimLineItem.LineItemNumber+', @Claim_rowcount union all
select	'055', 'Claim.MemberID has no corresponding record in Member table', @Claim_rowcount union all
select	'056', 'Claim.ServicingProviderID has no corresponding record in Provider table', @Claim_rowcount union all
select	'057', 'Invalid Claim.ClaimStatus', @Claim_rowcount union all
select	'058', 'ClaimLineItem.CPTProcedureCode of invalid format', @ClaimLineItem_rowcount union all
select	'059', 'ClaimLineItem.CPTProcedureCode values that are not eligible for HEDIS', @ClaimLineItem_rowcount union all
select	'060', 'ClaimLineItem.CPTProcedureCodeModifier1 of invalid format', @ClaimLineItem_rowcount union all
select	'061', 'ClaimLineItem.CPTProcedureCodeModifier2 of invalid format', @ClaimLineItem_rowcount union all
select	'062', 'ClaimLineItem.CPTProcedureCodeModifier1 has value, but ClaimLineItem.CPTProcedureCode is empty', @ClaimLineItem_rowcount union all
select	'063', 'ClaimLineItem.CPTProcedureCodeModifier1 has value, but ClaimLineItem.CPTProcedureCode is empty', @ClaimLineItem_rowcount union all
select	'064', 'ClaimLineItem.HCPCSProcedureCode of invalid format', @ClaimLineItem_rowcount union all
select	'065', 'ClaimLineItem.HCPCSProcedureCode values that are not eligible for HEDIS', @ClaimLineItem_rowcount union all
select	'066', 'ClaimLineItem.RevenueCode of invalid format', @ClaimLineItem_rowcount union all
select	'067', 'ClaimLineItem.RevenueCode values that are not eligible for HEDIS', @ClaimLineItem_rowcount union all
select	'068', 'ClaimLineItem.CPT_II of invalid format', @ClaimLineItem_rowcount union all
select	'069', 'ClaimLineItem.CPT_II values that are not eligible for HEDIS', @ClaimLineItem_rowcount union all
select	'070', 'Claim.DiagnosisCode1 of invalid format', @Claim_rowcount union all
select	'071', 'Claim.DiagnosisCode2 of invalid format', @Claim_rowcount union all
select	'072', 'Claim.DiagnosisCode3 of invalid format', @Claim_rowcount union all
select	'073', 'Claim.DiagnosisCode4 of invalid format', @Claim_rowcount union all
select	'074', 'Claim.DiagnosisCode5 of invalid format', @Claim_rowcount union all
select	'075', 'Claim.DiagnosisCode6 of invalid format', @Claim_rowcount union all
select	'076', 'Claim.DiagnosisCode7 of invalid format', @Claim_rowcount union all
select	'077', 'Claim.DiagnosisCode8 of invalid format', @Claim_rowcount union all
select	'078', 'Claim.DiagnosisCode9 of invalid format', @Claim_rowcount union all
select	'079', 'Claim.DiagnosisCode10 of invalid format', @Claim_rowcount union all
select	'080', 'Claim.DiagnosisCodexx values that are not eligible for HEDIS', @Claim_rowcount union all
select	'081', 'Claim.DiagnosisRelatedGroup of invalid format', @Claim_rowcount union all
select	'082', 'Claim.DiagnosisRelatedGroup values that are not eligible for HEDIS', @Claim_rowcount union all
select	'083', 'Invalid Claim.DiagnosisRelatedGroupType', @Claim_rowcount union all
select	'084', 'Claim.SurgicalProcedure1 of invalid format', @Claim_rowcount union all
select	'085', 'Claim.SurgicalProcedure2 of invalid format', @Claim_rowcount union all
select	'086', 'Claim.SurgicalProcedure3 of invalid format', @Claim_rowcount union all
select	'087', 'Claim.SurgicalProcedure4 of invalid format', @Claim_rowcount union all
select	'088', 'Claim.SurgicalProcedure5 of invalid format', @Claim_rowcount union all
select	'089', 'Claim.SurgicalProcedure6 of invalid format', @Claim_rowcount union all
select	'090', 'Claim.SurgicalProcedurexx values that are not eligible for HEDIS', @Claim_rowcount union all
select	'091', 'Claim.BillType of invalid format', @Claim_rowcount union all
select	'092', 'Claim.BillType values that are not eligible for HEDIS', @Claim_rowcount union all
select	'093', 'Claim.DischargeStatus of invalid format', @Claim_rowcount union all
select	'094', 'Claim.PlaceOfService of invalid format', @Claim_rowcount union all
select	'095', 'Claim events with NO DiagnosisCodexx codes', @Claim_rowcount union all
select	'096', 'Claim events with NO DiagnosisRelatedGroup codes', @Claim_rowcount union all
select	'097', 'ClaimLineItem events with NO CPTProcedureCode codes', @ClaimLineItem_rowcount union all
select	'098', 'ClaimLineItem events with NO RevenueCode codes', @ClaimLineItem_rowcount union all
select	'099', 'ClaimLineItem events with NO HCPCSProcedureCode codes', @ClaimLineItem_rowcount union all
select	'100', 'ClaimLineItem events with NO CPT_II codes', @ClaimLineItem_rowcount union all
select	'101', 'ClaimLineItem events with NO procedureal event (CPT,Revenue,HCPCS,CPTII)', @ClaimLineItem_rowcount


IF OBJECT_ID('tempdb..#imidatastore_valid_values') IS NOT NULL
	DROP TABLE #imidatastore_valid_values

create table #imidatastore_valid_values
(		table_name					varchar(50),
		field_name					varchar(50),
		field_value					varchar(50),
		value_description_short		varchar(200),
		value_description			varchar(200) )

truncate table #imidatastore_valid_values

insert into #imidatastore_valid_values
select	table_name					= 'Member',
		field_name					= 'Gender',
		field_value					= 'M',
		value_description_short		= 'Male',
		value_description			= 'Male'
union all
select	table_name					= 'Member',
		field_name					= 'Gender',
		field_value					= 'F',
		value_description_short		= 'Female',
		value_description			= 'Female'
union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '01',
		value_description_short		= 'White',
		value_description			= 'White'
union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '02',
		value_description_short		= 'Black or African American',
		value_description			= 'Black or African American'

union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '03',
		value_description_short		= 'American Indian and Alaska Native',
		value_description			= 'American Indian and Alaska Native'

union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '04',
		value_description_short		= 'Asian',
		value_description			= 'Asian'

union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '05',
		value_description_short		= 'Native Hawaiian and Other Pacific Islander',
		value_description			= 'Native Hawaiian and Other Pacific Islander'

union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '06',
		value_description_short		= 'Some Other Race',
		value_description			= 'Some Other Race'
union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '07',
		value_description_short		= 'Two or More Races',
		value_description			= 'Two or More Races'
union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '09',
		value_description_short		= 'Unknown Race',
		value_description			= 'Unknown Race'
union all
select	table_name					= 'Member',
		field_name					= 'Race',
		field_value					= '',
		value_description_short		= '',
		value_description			= ''
union all
select	table_name					= 'Member',
		field_name					= 'Ethnicity',
		field_value					= '11',
		value_description_short		= 'Hispanic or Latino',
		value_description			= 'Hispanic or Latino'
union all
select	table_name					= 'Member',
		field_name					= 'Ethnicity',
		field_value					= '12',
		value_description_short		= 'Not Hispanic or Latino',
		value_description			= 'Not Hispanic or Latino'
union all
select	table_name					= 'Member',
		field_name					= 'Ethnicity',
		field_value					= '19',
		value_description_short		= 'Unknown Ethnicity',
		value_description			= 'Unknown Ethnicity'
union all
select	table_name					= 'Member',
		field_name					= 'Ethnicity',
		field_value					= '',
		value_description_short		= '',
		value_description			= ''
union all
select	table_name					= 'Member',
		field_name					= 'InterpreterFlag',
		field_value					= '0',
		value_description_short		= 'No, does not want an interpreter',
		value_description			= 'No, does not want an interpreter'
union all
select	table_name					= 'Member',
		field_name					= 'InterpreterFlag',
		field_value					= '1',
		value_description_short		= 'Yes, wants an interpreter',
		value_description			= 'Yes, wants an interpreter'
union all
select	table_name					= 'Member',
		field_name					= 'InterpreterFlag',
		field_value					= '9',
		value_description_short		= 'Unknown need for interpreter',
		value_description			= 'Unknown need for interpreter'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '21',
		value_description_short		= 'English',
		value_description			= 'English'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '22',
		value_description_short		= 'Spanish',
		value_description			= 'Spanish'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '23',
		value_description_short		= 'Other Indo-European Language',
		value_description			= 'Other Indo-European Language'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '24',
		value_description_short		= 'Asian and Pacific Island Languages',
		value_description			= 'Asian and Pacific Island Languages'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '28',
		value_description_short		= 'Other Languages',
		value_description			= 'Other Languages'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '29',
		value_description_short		= 'Spoken Language Unknown',
		value_description			= 'Spoken Language Unknown'
union all
select	table_name					= 'Member',
		field_name					= 'MemberLanguage',
		field_value					= '',
		value_description_short		= '',
		value_description			= ''
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= '',
		value_description_short		= '',
		value_description			= ''
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MDE',
		value_description_short		= 'Medicaid Dual Eligible HMO',
		value_description			= 'Medicaid Dual Eligible HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MD',
		value_description_short		= 'Medicaid Disabled HMO',
		value_description			= 'Medicaid Disabled HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MLI',
		value_description_short		= 'Medicaid Low Income HMO',
		value_description			= 'Medicaid Low Income HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MRB',
		value_description_short		= 'Medicaid Restricted Benefit HMO',
		value_description			= 'Medicaid Restricted Benefit HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MR',
		value_description_short		= 'Medicare Advantage HMO',
		value_description			= 'Medicare Advantage HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MP',
		value_description_short		= 'Medicare Advantage PPO',
		value_description			= 'Medicare Advantage PPO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'MC',
		value_description_short		= 'Medicare Cost',
		value_description			= 'Medicare Cost'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'PPO',
		value_description_short		= 'Commercial PPO',
		value_description			= 'Commercial PPO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'POS',
		value_description_short		= 'Commercial POS',
		value_description			= 'Commercial POS'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'HMO',
		value_description_short		= 'Commercial HMO',
		value_description			= 'Commercial HMO'
union all
select	table_name					= 'Eligibility',
		field_name					= 'ProductType',
		field_value					= 'CHP',
		value_description_short		= 'Child Health Insurance Program',
		value_description			= 'Child Health Insurance Program'





IF OBJECT_ID('tempdb..#hedis_profiling_validation_summary') IS NOT NULL
	DROP TABLE #hedis_profiling_validation_summary

create table #hedis_profiling_validation_summary
(		validation_code		varchar(3),
		validation_count	int )


truncate table #hedis_profiling_validation_summary

insert	into #hedis_profiling_validation_summary
select	validation_code		= '001',
		validation_count	= count(*)
from	Member
where	CustomerMemberID = '' or
		CustomerMemberID is null




insert	into #hedis_profiling_validation_summary
select	validation_code		= '002',
		count(*) --select top 10 *
from	Member a
where	exists (	select	CustomerMemberID,
							HedisMeasureID,
							count(*)
					from	Member b
					group by CustomerMemberID,
							HedisMeasureID having	count(*)>1 and
													a.CustomerMemberID = b.CustomerMemberID and
													a.HedisMeasureID = b.HedisMeasureID)





insert	into #hedis_profiling_validation_summary
select	validation_code		= '003',
		count(*) --select top 10 *
from	Member a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Member' and
								field_name = 'Gender' and
								field_value = a.Gender)






insert	into #hedis_profiling_validation_summary
select	validation_code		= '004',
		count(*) --select top 10 *
from	Member a
where	DateOfBirth = '' or
		DateOfBirth is null





insert	into #hedis_profiling_validation_summary
select	validation_code		= '005',
		count(*) --select top 10 *
from	Member a
where	DateOfBirth not between '01/01/1875' and getdate()






insert	into #hedis_profiling_validation_summary
select	validation_code		= '006',
		count(*) --select top 10 *
from	Member a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Member' and
								field_name = 'Race' and
								field_value = a.Race)




insert	into #hedis_profiling_validation_summary
select	validation_code		= '007',
		count(*) --select top 10 *
from	Member a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Member' and
								field_name = 'Ethnicity' and
								field_value = a.Ethnicity)



insert	into #hedis_profiling_validation_summary
select	validation_code		= '008',
		count(*) --select top 10 *
from	Member a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Member' and
								field_name = 'InterpreterFlag' and
								field_value = a.InterpreterFlag)


insert	into #hedis_profiling_validation_summary
select	validation_code		= '009',
		count(*) --select top 10 *
from	Member a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Member' and
								field_name = 'MemberLanguage' and
								field_value = a.MemberLanguage)





insert	into #hedis_profiling_validation_summary
select	validation_code		= '010',
		count(*) --select top 10 *
from	Eligibility a
		left join Member b on
			a.MemberID = b.MemberID
where	b.MemberID is null




insert	into #hedis_profiling_validation_summary
select	validation_code		= '011',
		count(*) --select top 10 *
from	Eligibility a
where	DateEffective > DateTerminated



insert	into #hedis_profiling_validation_summary
select	validation_code		= '012',
		count(*) --select top 10 *
from	Eligibility a
where	not exists (	select	*
						from	#imidatastore_valid_values b
						where	table_name = 'Eligibility' and
								field_name = 'ProductType' and
								field_value = a.ProductType)



insert	into #hedis_profiling_validation_summary
select	validation_code		= '013',
		count(*) --select top 10 *
from	Eligibility a
where	HealthPlanEmployeeFlag not in ('Y','N') or
		HealthPlanEmployeeFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '014',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageDentalFlag not in ('Y','N') or
		CoverageDentalFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '015',
		count(*) --select top 10 *
from	Eligibility a
where	CoveragePharmacyFlag not in ('Y','N') or
		CoveragePharmacyFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '016',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageMHInpatientFlag not in ('Y','N') or
		CoverageMHInpatientFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '017',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageMHDayNightFlag not in ('Y','N') or
		CoverageMHDayNightFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '018',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageMHAmbulatoryFlag not in ('Y','N') or
		CoverageMHAmbulatoryFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '019',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageCDInpatientFlag not in ('Y','N') or
		CoverageCDInpatientFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '020',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageCDDayNightFlag not in ('Y','N') or
		CoverageCDDayNightFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '021',
		count(*) --select top 10 *
from	Eligibility a
where	CoverageCDAmbulatoryFlag not in ('Y','N') or
		CoverageCDAmbulatoryFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '022',
		validation_count	= count(*) --select top 10 *
from	Provider
where	TaxID = '' or
		TaxID is null




insert	into #hedis_profiling_validation_summary
select	validation_code		= '023',
		count(*) --select top 10 *
from	Provider a
where	exists (	select	TaxID,
							HedisMeasureID,
							count(*)
					from	Provider b
					group by TaxID,
							HedisMeasureID having	count(*)>1 and
													a.TaxID = b.TaxID and
													a.HedisMeasureID = b.HedisMeasureID)


insert	into #hedis_profiling_validation_summary
select	validation_code		= '024',
		count(*) --select top 10 *
from	Provider a
where	ProviderPrescribingPrivFlag not in ('Y','N') or
		ProviderPrescribingPrivFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '025',
		count(*) --select top 10 *
from	Provider a
where	PCPFlag not in ('Y','N') or
		PCPFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '026',
		count(*) --select top 10 *
from	Provider a
where	OBGynFlag not in ('Y','N') or
		OBGynFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '027',
		count(*) --select top 10 *
from	Provider a
where	MentalHealthFlag not in ('Y','N') or
		MentalHealthFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '028',
		count(*) --select top 10 *
from	Provider a
where	EyeCareFlag not in ('Y','N') or
		EyeCareFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '029',
		count(*) --select top 10 *
from	Provider a
where	DentistFlag not in ('Y','N') or
		DentistFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '030',
		count(*) --select top 10 *
from	Provider a
where	NephrologistFlag not in ('Y','N') or
		NephrologistFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '031',
		count(*) --select top 10 *
from	Provider a
where	CDProviderFlag not in ('Y','N') or
		CDProviderFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '032',
		count(*) --select top 10 *
from	Provider a
where	NursePractFlag not in ('Y','N') or
		NursePractFlag is null


insert	into #hedis_profiling_validation_summary
select	validation_code		= '033',
		count(*) --select top 10 *
from	Provider a
where	PhysicianAsstFlag not in ('Y','N') or
		PhysicianAsstFlag is null




--****************************************************************************************
--****************************************************************************************

IF OBJECT_ID('tempdb..#claim_detail_ProviderPrescribingPrivFlag') is not null
    DROP TABLE #claim_detail_ProviderPrescribingPrivFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_ProviderPrescribingPrivFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	tableid = 'AMM-C'
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_ProviderPrescribingPrivFlag') is not null
    DROP TABLE #provider_counts_ProviderPrescribingPrivFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_ProviderPrescribingPrivFlag
from	#claim_detail_ProviderPrescribingPrivFlag
group by ServicingProviderID




insert	into #hedis_profiling_validation_summary
select	validation_code		= '034',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_ProviderPrescribingPrivFlag b on
			a.ProviderID = b.ServicingProviderID
where	ProviderPrescribingPrivFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_PCPFlag') is not null
    DROP TABLE #claim_detail_PCPFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_PCPFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','AWC','CAP','FPC','PPC','W15','W34')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_PCPFlag') is not null
    DROP TABLE #provider_counts_PCPFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_PCPFlag
from	#claim_detail_PCPFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '035',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_PCPFlag b on
			a.ProviderID = b.ServicingProviderID
where	PCPFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************

IF OBJECT_ID('tempdb..#claim_detail_OBGynFlag') is not null
    DROP TABLE #claim_detail_OBGynFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_OBGynFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','AWC','FPC','PPC','W15')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_OBGynFlag') is not null
    DROP TABLE #provider_counts_OBGynFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_OBGynFlag
from	#claim_detail_OBGynFlag
group by ServicingProviderID



insert	into #hedis_profiling_validation_summary
select	validation_code		= '036',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_OBGynFlag b on
			a.ProviderID = b.ServicingProviderID
where	OBGynFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_MentalHealthFlag') is not null
    DROP TABLE #claim_detail_MentalHealthFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_MentalHealthFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','FUH','MPT')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_MentalHealthFlag') is not null
    DROP TABLE #provider_counts_MentalHealthFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_MentalHealthFlag
from	#claim_detail_MentalHealthFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '037',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_MentalHealthFlag b on
			a.ProviderID = b.ServicingProviderID
where	MentalHealthFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_EyeCareFlag') is not null
    DROP TABLE #claim_detail_EyeCareFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_EyeCareFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','CDC','GSO')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode

IF OBJECT_ID('tempdb..#provider_counts_EyeCareFlag') is not null
    DROP TABLE #provider_counts_EyeCareFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_EyeCareFlag
from	#claim_detail_EyeCareFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '038',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_EyeCareFlag b on
			a.ProviderID = b.ServicingProviderID
where	EyeCareFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_DentistFlag') is not null
    DROP TABLE #claim_detail_DentistFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_DentistFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','ADV')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode

IF OBJECT_ID('tempdb..#provider_counts_DentistFlag') is not null
    DROP TABLE #provider_counts_DentistFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_DentistFlag
from	#claim_detail_DentistFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '039',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_DentistFlag b on
			a.ProviderID = b.ServicingProviderID
where	DentistFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_NephrologistFlag') is not null
    DROP TABLE #claim_detail_NephrologistFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_NephrologistFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM','CDC')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode

IF OBJECT_ID('tempdb..#provider_counts_NephrologistFlag') is not null
    DROP TABLE #provider_counts_NephrologistFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_NephrologistFlag
from	#claim_detail_NephrologistFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '040',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_NephrologistFlag b on
			a.ProviderID = b.ServicingProviderID
where	NephrologistFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_CDProviderFlag') is not null
    DROP TABLE #claim_detail_CDProviderFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_CDProviderFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AMM')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_CDProviderFlag') is not null
    DROP TABLE #provider_counts_CDProviderFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_CDProviderFlag
from	#claim_detail_CDProviderFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '041',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_CDProviderFlag b on
			a.ProviderID = b.ServicingProviderID
where	CDProviderFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_NursePractFlag') is not null
    DROP TABLE #claim_detail_NursePractFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_NursePractFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AWC','CAP','W15','W34')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode

IF OBJECT_ID('tempdb..#provider_counts_NursePractFlag') is not null
    DROP TABLE #provider_counts_NursePractFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_NursePractFlag
from	#claim_detail_NursePractFlag
group by ServicingProviderID


insert	into #hedis_profiling_validation_summary
select	validation_code		= '042',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_NursePractFlag b on
			a.ProviderID = b.ServicingProviderID
where	NursePractFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#claim_detail_PhysicianAsstFlag') is not null
    DROP TABLE #claim_detail_PhysicianAsstFlag

select	ServicingProviderID,
		CPTProcedureCode,
		claim_line_count	= count(*)
into	#claim_detail_PhysicianAsstFlag
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	CPTProcedureCode in (	SELECT	codevalue
								FROM	ncqa_rdsm..tblcodesets
								WHERE	left(tableid,3) in ('AWC','CAP','W15','W34')
										AND codetype in ('CPT','HCPCS','UB-92_Revenue')	)
group by ServicingProviderID,
		CPTProcedureCode


IF OBJECT_ID('tempdb..#provider_counts_PhysicianAsstFlag') is not null
    DROP TABLE #provider_counts_PhysicianAsstFlag

select	ServicingProviderID,
		claim_line_count	= sum(claim_line_count)
into	#provider_counts_PhysicianAsstFlag
from	#claim_detail_PhysicianAsstFlag
group by ServicingProviderID



insert	into #hedis_profiling_validation_summary
select	validation_code		= '043',
		count(*) --select top 10 *
from	Provider a
		left join #provider_counts_PhysicianAsstFlag b on
			a.ProviderID = b.ServicingProviderID
where	PhysicianAsstFlag = 'N' and
		claim_line_count > 0
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '044',
		count(*) --select top 10 *
from	LabResult a
		left join Member b on
			a.MemberID = b.MemberID
where	b.MemberID is null
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '045',
		count(*) --select top 10 *
from	LabResult a
where	exists (	select	LabResultID,
							count(*)
					from	LabResult b
					group by LabResultID having	count(*)>1 and
													a.LabResultID = b.LabResultID)
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '046',
		count(*) --select top 10 *
from	LabResult a
where	HCPCSProcedureCode <> '' and
		len(HCPCSProcedureCode) <> 5
--****************************************************************************************
--****************************************************************************************








--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '047',
		count(*) --select top 10 *
from	LabResult a
where	LOINCCode <> '' and
		not
		((	len(LOINCCode)=7 and
			isnumeric(right(LOINCCode,1)) = 1 and
			substring(LOINCCode,6,1) = '-' and
			isnumeric(left(LOINCCode,5))=1)
		 or
		 (	len(LOINCCode)=6 and
			isnumeric(right(LOINCCode,1)) = 1 and
			substring(LOINCCode,5,1) = '-' and
			isnumeric(left(LOINCCode,4))=1)
		 or
		 (	len(LOINCCode)=5 and
			isnumeric(right(LOINCCode,1)) = 1 and
			substring(LOINCCode,4,1) = '-' and
			isnumeric(left(LOINCCode,3))=1))
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '048',
		count(*) --select top 10 *
from	LabResult a
where	not
		(PNIndicator in ('P','N') or
		PNIndicator = '')
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '049',
		count(*) --select top 10 *
from	PharmacyClaim a
		left join Member b on
			a.MemberID = b.MemberID
where	b.MemberID is null
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '050',
		count(*) --select top 10 *
from	PharmacyClaim a
where	exists (	select	ClaimNumber,
							count(*)
					from	PharmacyClaim b
					group by ClaimNumber having	count(*)>1 and
													a.ClaimNumber = b.ClaimNumber)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '051',
		count(*) --select top 10 *
from	PharmacyClaim a
where	not(
		len(NDC) = 11 and
		isnumeric(NDC) = 1)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '052',
		count(*) --select top 10 *
from	PharmacyClaim a
where	not (
		SupplyFlag in ('Y','N') or
		SupplyFlag = '')
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '053',
		count(*) --select top 10 *
from	PharmacyClaim a
where	ClaimStatus not in ('1','2') or
		ClaimStatus is null
--****************************************************************************************
--****************************************************************************************








--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '054',
		count(*) --select top 10 *
from	Claim a
		inner join ClaimLineItem b on
			a.ClaimID = b.ClaimID
where	exists (	select	PayerClaimID,
							PayerClaimIDSuffix,
							LineItemNumber,
							count(*)
					from	Claim a2
							inner join ClaimLineItem b2 on
								a2.ClaimID = b2.ClaimID
					group by PayerClaimID,
							PayerClaimIDSuffix,
							LineItemNumber having	count(*)>1 and
													a2.PayerClaimID = a.PayerClaimID and
													a2.PayerClaimIDSuffix = a.PayerClaimIDSuffix and
													b2.LineItemNumber = b.LineItemNumber)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '055',
		count(*) --select top 10 *
from	Claim a
		left join Member b on
			a.MemberID = b.MemberID
where	b.MemberID is null
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '056',
		count(*) --select top 10 *
from	Claim a
		left join Provider b on
			a.ServicingProviderID = b.ProviderID
where	b.ProviderID is null
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '057',
		count(*) --select top 10 *
from	Claim a
where	ClaimStatus not in ('1','2') or
		ClaimStatus is null
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '058',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCode <> '' and
		not (
		len(CPTProcedureCode) = 5 and
		isnumeric(right(CPTProcedureCode,4))= 1)


--select	CPTProcedureCode, FCFULLDESC, count(*)
--from	ClaimLineItem a
--		left join JPROCDM0_DAT b on
--			a.CPTProcedureCode = b.FCPROCCODE
--where	CPTProcedureCode <> '' and
--		not (
--		len(CPTProcedureCode) = 5 and
--		isnumeric(right(CPTProcedureCode,4))= 1) and
--		not	(len(CPTProcedureCode)=3 and CPTProcedureCode between '000' and '999')
--group by CPTProcedureCode, FCFULLDESC order by count(*) desc

--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '059',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCode <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b
						WHERE	codetype in ('CPT','HCPCS') and
								a.CPTProcedureCode = b.codevalue)

--select	CPTProcedureCode, FCFULLDESC, count(*)
--from	ClaimLineItem a
--		left join JPROCDM0_DAT b on
--			a.CPTProcedureCode = b.FCPROCCODE
--where	CPTProcedureCode <> '' and
--		not exists (	select	*
--						from	ncqa_rdsm..tblcodesets b
--						WHERE	codetype in ('CPT','HCPCS') and
--								a.CPTProcedureCode = b.codevalue)
--group by CPTProcedureCode, FCFULLDESC
--order by count(*) desc

--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '060',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCodeModifier1 <> '' and
		len(CPTProcedureCodeModifier1) <> 2
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '061',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCodeModifier2 <> '' and
		len(CPTProcedureCodeModifier2) <> 2
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '062',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCodeModifier1 <> '' and
		CPTProcedureCode = ''
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '063',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCodeModifier2 <> '' and
		CPTProcedureCode = ''
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '064',
		count(*) --select top 10 *
from	ClaimLineItem a
where	HCPCSProcedureCode <> '' and
		not (
		len(HCPCSProcedureCode) = 5 and
		isnumeric(right(HCPCSProcedureCode,4))= 1)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '065',
		count(*) --select top 10 *
from	ClaimLineItem a
where	HCPCSProcedureCode <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b
						WHERE	codetype in ('CPT','HCPCS') and
								a.HCPCSProcedureCode = b.codevalue)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '066',
		count(*) --select top 10 *
from	ClaimLineItem a
where	RevenueCode <> '' and
		not (
		(len(RevenueCode) = 4 and
		isnumeric(RevenueCode)= 1)
		 or
		(len(RevenueCode) = 3 and
		isnumeric(RevenueCode)= 1))
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '067',
		count(*) --select top 10 *
from	ClaimLineItem a
where	RevenueCode <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b
						WHERE	codetype in ('UB-92_Revenue') and
								a.RevenueCode = b.codevalue)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '068',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPT_II <> '' and
		not (
		len(CPT_II) = 5 and
		isnumeric(left(CPT_II,4))= 1)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '069',
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPT_II <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('CPT_Category_II') and
								a.CPT_II = b.codevalue)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '070',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode1 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode1))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode1))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode1)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode1))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode1)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode1))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode1)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode1))) = 6 and
		left(ltrim(rtrim(DiagnosisCode1)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode1)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode1))) = 5 and
		left(ltrim(rtrim(DiagnosisCode1)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode1)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode1))) = 4 and
		left(ltrim(rtrim(DiagnosisCode1)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode1)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '071',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode2 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode2))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode2))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode2)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode2))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode2)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode2))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode2)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode2))) = 6 and
		left(ltrim(rtrim(DiagnosisCode2)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode2)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode2))) = 5 and
		left(ltrim(rtrim(DiagnosisCode2)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode2)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode2))) = 4 and
		left(ltrim(rtrim(DiagnosisCode2)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode2)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '072',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode3 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode3))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode3))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode3)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode3))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode3)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode3))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode3)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode3))) = 6 and
		left(ltrim(rtrim(DiagnosisCode3)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode3)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode3))) = 5 and
		left(ltrim(rtrim(DiagnosisCode3)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode3)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode3))) = 4 and
		left(ltrim(rtrim(DiagnosisCode3)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode3)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '073',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode4 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode4))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode4))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode4)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode4))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode4)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode4))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode4)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode4))) = 6 and
		left(ltrim(rtrim(DiagnosisCode4)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode4)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode4))) = 5 and
		left(ltrim(rtrim(DiagnosisCode4)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode4)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode4))) = 4 and
		left(ltrim(rtrim(DiagnosisCode4)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode4)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '074',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode5 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode5))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode5))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode5)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode5))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode5)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode5))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode5)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode5))) = 6 and
		left(ltrim(rtrim(DiagnosisCode5)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode5)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode5))) = 5 and
		left(ltrim(rtrim(DiagnosisCode5)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode5)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode5))) = 4 and
		left(ltrim(rtrim(DiagnosisCode5)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode5)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '075',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode6 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode6))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode6))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode6)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode6))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode6)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode6))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode6)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode6))) = 6 and
		left(ltrim(rtrim(DiagnosisCode6)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode6)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode6))) = 5 and
		left(ltrim(rtrim(DiagnosisCode6)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode6)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode6))) = 4 and
		left(ltrim(rtrim(DiagnosisCode6)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode6)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '076',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode7 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode7))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode7))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode7)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode7))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode7)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode7))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode7)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode7))) = 6 and
		left(ltrim(rtrim(DiagnosisCode7)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode7)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode7))) = 5 and
		left(ltrim(rtrim(DiagnosisCode7)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode7)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode7))) = 4 and
		left(ltrim(rtrim(DiagnosisCode7)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode7)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '077',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode8 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode8))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode8))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode8)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode8))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode8)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode8))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode8)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode8))) = 6 and
		left(ltrim(rtrim(DiagnosisCode8)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode8)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode8))) = 5 and
		left(ltrim(rtrim(DiagnosisCode8)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode8)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode8))) = 4 and
		left(ltrim(rtrim(DiagnosisCode8)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode8)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************


--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '078',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode9 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode9))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode9))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode9)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode9))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode9)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode9))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode9)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode9))) = 6 and
		left(ltrim(rtrim(DiagnosisCode9)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode9)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode9))) = 5 and
		left(ltrim(rtrim(DiagnosisCode9)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode9)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode9))) = 4 and
		left(ltrim(rtrim(DiagnosisCode9)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode9)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************


--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '079',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisCode10 <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisCode10))) = 3 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,2))= 1)
		or
		(len(ltrim(rtrim(DiagnosisCode10))) = 4 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode10)),4,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode10))) = 5 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode10)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),5,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode10))) = 6 and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,2))= 1 and
		substring(ltrim(rtrim(DiagnosisCode10)),4,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),5,2))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode10))) = 6 and
		left(ltrim(rtrim(DiagnosisCode10)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode10)),5,1)='.' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),6,1))=1)
		or 
		(len(ltrim(rtrim(DiagnosisCode10))) = 5 and
		left(ltrim(rtrim(DiagnosisCode10)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,3))= 1 and
		substring(ltrim(rtrim(DiagnosisCode10)),5,1)='.')
		or 
		(len(ltrim(rtrim(DiagnosisCode10))) = 4 and
		left(ltrim(rtrim(DiagnosisCode10)),1) = 'E' and
		isnumeric(substring(ltrim(rtrim(DiagnosisCode10)),2,3))= 1 )
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#diag_counts') is not null
    DROP TABLE #diag_counts

select	diag_code			= DiagnosisCode1,
		claim_line_count	= count(*)
into	#diag_counts
from	Claim a
where	DiagnosisCode1 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode1 = b.codevalue)
group by DiagnosisCode1
union all
select	diag_code			= DiagnosisCode2,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode2 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode2 = b.codevalue)
group by DiagnosisCode2
union all
select	diag_code			= DiagnosisCode3,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode3 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode3 = b.codevalue)
group by DiagnosisCode3
union all
select	diag_code			= DiagnosisCode4,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode4 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode4 = b.codevalue)
group by DiagnosisCode4
union all
select	diag_code			= DiagnosisCode5,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode5 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode5 = b.codevalue)
group by DiagnosisCode5
union all
select	diag_code			= DiagnosisCode6,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode6 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode6 = b.codevalue)
group by DiagnosisCode6
union all
select	diag_code			= DiagnosisCode7,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode7 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode7 = b.codevalue)
group by DiagnosisCode7
union all
select	diag_code			= DiagnosisCode8,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode8 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode8 = b.codevalue)
group by DiagnosisCode8
union all
select	diag_code			= DiagnosisCode9,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode9 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode9 = b.codevalue)
group by DiagnosisCode9
union all
select	diag_code			= DiagnosisCode10,
		claim_line_count	= count(*)
from	Claim a
where	DiagnosisCode10 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Diagnosis') and
								a.DiagnosisCode10 = b.codevalue)
group by DiagnosisCode10



insert	into #hedis_profiling_validation_summary
select	validation_code		= '080',
		sum(claim_line_count) --select top 10 *
from	#diag_counts a
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '081',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisRelatedGroup <> '' and
		not (
		(len(ltrim(rtrim(DiagnosisRelatedGroup))) = 3 and
		isnumeric(ltrim(rtrim(DiagnosisRelatedGroup)))= 1)
		or
		(len(ltrim(rtrim(DiagnosisRelatedGroup))) = 2 and
		isnumeric(ltrim(rtrim(DiagnosisRelatedGroup)))= 1)
		or
		(len(ltrim(rtrim(DiagnosisRelatedGroup))) = 1 and
		isnumeric(ltrim(rtrim(DiagnosisRelatedGroup)))= 1))
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '082',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisRelatedGroup <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b
						WHERE	codetype in ('DRG','MS-DRG') and
								a.DiagnosisRelatedGroup = b.codevalue)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '083',
		count(*) --select top 10 *
from	Claim a
where	DiagnosisRelatedGroupType <> '' and
		DiagnosisRelatedGroupType not in ('C','M')
--****************************************************************************************
--****************************************************************************************







--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '084',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure1 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure1))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure1))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure1)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure1))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure1)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure1))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure1)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure1)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '085',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure2 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure2))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure2))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure2)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure2))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure2)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure2))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure2)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure2)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '086',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure3 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure3))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure3))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure3)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure3))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure3)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure3))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure3)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure3)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '087',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure4 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure4))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure4))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure4)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure4))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure4)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure4))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure4)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure4)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '088',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure5 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure5))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure5))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure5)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure5))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure5)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure5))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure5)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure5)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '089',
		count(*) --select top 10 *
from	Claim a
where	SurgicalProcedure6 <> '' and
		not (
		(len(ltrim(rtrim(SurgicalProcedure6))) = 2 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),1,2))= 1)
		or
		(len(ltrim(rtrim(SurgicalProcedure6))) = 3 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure6)),3,1)='.')
		or 
		(len(ltrim(rtrim(SurgicalProcedure6))) = 4 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure6)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),4,1))=1)
		or 
		(len(ltrim(rtrim(SurgicalProcedure6))) = 5 and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),1,2))= 1 and
		substring(ltrim(rtrim(SurgicalProcedure6)),3,1)='.' and
		isnumeric(substring(ltrim(rtrim(SurgicalProcedure6)),4,2))=1)
		)
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
IF OBJECT_ID('tempdb..#surg_counts') is not null
    DROP TABLE #surg_counts

select	surg_code			= SurgicalProcedure1,
		claim_line_count	= count(*)
into	#surg_counts
from	Claim a
where	SurgicalProcedure1 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure1 = b.codevalue)
group by SurgicalProcedure1
union all
select	surg_code			= SurgicalProcedure2,
		claim_line_count	= count(*)
from	Claim a
where	SurgicalProcedure2 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure2 = b.codevalue)
group by SurgicalProcedure2
union all
select	surg_code			= SurgicalProcedure3,
		claim_line_count	= count(*)
from	Claim a
where	SurgicalProcedure3 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure3 = b.codevalue)
group by SurgicalProcedure3
union all
select	surg_code			= SurgicalProcedure4,
		claim_line_count	= count(*)
from	Claim a
where	SurgicalProcedure4 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure4 = b.codevalue)
group by SurgicalProcedure4
union all
select	surg_code			= SurgicalProcedure5,
		claim_line_count	= count(*)
from	Claim a
where	SurgicalProcedure5 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure5 = b.codevalue)
group by SurgicalProcedure5
union all
select	surg_code			= SurgicalProcedure6,
		claim_line_count	= count(*)
from	Claim a
where	SurgicalProcedure6 <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('ICD-9-CM_Procedure') and
								a.SurgicalProcedure6 = b.codevalue)
group by SurgicalProcedure6


insert	into #hedis_profiling_validation_summary
select	validation_code		= '090',
		sum(claim_line_count) --select top 10 *
from	#surg_counts a
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '091',
		count(*) --select top 10 *
from	Claim a
where	BillType <> '' and
		not (
		(len(ltrim(rtrim(BillType))) = 3 and
		isnumeric(ltrim(rtrim(BillType)))= 1)
		or
		(len(ltrim(rtrim(BillType))) = 4 and
		isnumeric(ltrim(rtrim(BillType)))= 1)
		)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '092',
		count(*) --select top 10 *
from	Claim a
where	BillType <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b 
						WHERE	codetype in ('UB_Type_of_Bill') and
								a.BillType = b.codevalue)
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '093',
		count(*) --select top 10 *
from	Claim a
where	DischargeStatus <> '' and
		not (
		(len(ltrim(rtrim(DischargeStatus))) = 2 and
		isnumeric(ltrim(rtrim(DischargeStatus)))= 1)
		or
		(len(ltrim(rtrim(DischargeStatus))) = 1 and
		isnumeric(ltrim(rtrim(DischargeStatus)))= 1))
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '094',
		count(*) --select top 10 *
from	Claim a
where	PlaceOfService <> '' and
		not (
		(len(ltrim(rtrim(PlaceOfService))) = 2 and
		isnumeric(ltrim(rtrim(PlaceOfService)))= 1)
		or
		(len(ltrim(rtrim(PlaceOfService))) = 1 and
		isnumeric(ltrim(rtrim(PlaceOfService)))= 1))
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '095',
		count(*) --select top 10 *
from	Claim a
where	(DiagnosisCode1 = '' or DiagnosisCode1 is null) and
		(DiagnosisCode2 = '' or DiagnosisCode2 is null) and
		(DiagnosisCode3 = '' or DiagnosisCode3 is null) and
		(DiagnosisCode4 = '' or DiagnosisCode4 is null) and
		(DiagnosisCode5 = '' or DiagnosisCode5 is null) and
		(DiagnosisCode6 = '' or DiagnosisCode6 is null) and
		(DiagnosisCode7 = '' or DiagnosisCode7 is null) and
		(DiagnosisCode8 = '' or DiagnosisCode8 is null) and
		(DiagnosisCode9 = '' or DiagnosisCode9 is null) and
		(DiagnosisCode10 = '' or DiagnosisCode10 is null)
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '096',
		count(*) --select top 10 *
from	Claim a
where	(DiagnosisRelatedGroup = '' or DiagnosisRelatedGroup is null) 
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '097',
		count(*) --select top 10 *
from	ClaimLineItem a
where	(CPTProcedureCode = '' or CPTProcedureCode is null) 
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '098',
		count(*) --select top 10 *
from	ClaimLineItem a
where	(RevenueCode = '' or RevenueCode is null) 
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '099',
		count(*) --select top 10 *
from	ClaimLineItem a
where	(HCPCSProcedureCode = '' or HCPCSProcedureCode is null) 
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '100',
		count(*) --select top 10 *
from	ClaimLineItem a
where	(CPT_II = '' or CPT_II is null) 
--****************************************************************************************
--****************************************************************************************




--****************************************************************************************
--****************************************************************************************
insert	into #hedis_profiling_validation_summary
select	validation_code		= '101',
		count(*) --select top 10 *
from	ClaimLineItem a
where	(CPTProcedureCode = '' or CPTProcedureCode is null) and
		(RevenueCode = '' or RevenueCode is null) and
		(HCPCSProcedureCode = '' or HCPCSProcedureCode is null) and
		(CPT_II = '' or CPT_II is null)
		
--****************************************************************************************
--****************************************************************************************



--****************************************************************************************
--****************************************************************************************
print	'Summary Validation/Profiling Edits'
print	'Table row counts'

print	'Member                row count: '+convert(varchar(15), @Member_rowcount)
print	'Eligibility           row count: '+convert(varchar(15), @Eligibility_rowcount)
print	'Provider              row count: '+convert(varchar(15), @Provider_rowcount)
print	'LabResult             row count: '+convert(varchar(15), @LabResult_rowcount)
print	'PharmacyClaim         row count: '+convert(varchar(15), @PharmacyClaim_rowcount)
print	'Claim                 row count: '+convert(varchar(15), @Claim_rowcount)
print	'ClaimLineItem         row count: '+convert(varchar(15), @ClaimLineItem_rowcount)
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Summary Validation/Profiling Edits'
print	'ProviderPrescribingPrivFlag=N and high volume of potentially qualifying claims'

select	a.validation_code,
		validation_desc,
		validation_count,
		table_rows_total,
		percent_errors	=	convert(numeric(8,2),round(
							case	when	table_rows_total = 0
									then	0
									else	((validation_count*1.00)/(table_rows_total*1.00))*100.00
							end
							,2))
from	#hedis_profiling_validation_summary a
		left join #hedis_profiling_validation_summary_error_codes b on
			a.validation_code = b.validation_code
order by 1
--****************************************************************************************
--****************************************************************************************








--****************************************************************************************
--****************************************************************************************
print	'Validation Error 034 Detail'
print	'Provider.ProviderPrescribingPrivFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_ProviderPrescribingPrivFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(ProviderPrescribingPrivFlag = 'N' or ProviderPrescribingPrivFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 035 Detail'
print	'Provider.PCPFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_PCPFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(PCPFlag = 'N' or PCPFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 036 Detail'
print	'Provider.OBGynFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_OBGynFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(OBGynFlag = 'N' or OBGynFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 037 Detail'
print	'Provider.MentalHealthFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_MentalHealthFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(MentalHealthFlag = 'N' or MentalHealthFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 038 Detail'
print	'Provider.EyeCareFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_EyeCareFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(EyeCareFlag = 'N' or EyeCareFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 039 Detail'
print	'Provider.DentistFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_DentistFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(DentistFlag = 'N' or DentistFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 040 Detail'
print	'Provider.NephrologistFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_NephrologistFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(NephrologistFlag = 'N' or NephrologistFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 041 Detail'
print	'Provider.CDProviderFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_CDProviderFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(CDProviderFlag = 'N' or CDProviderFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 042 Detail'
print	'Provider.NursePractFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_NursePractFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(NursePractFlag = 'N' or NursePractFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************





--****************************************************************************************
--****************************************************************************************
print	'Validation Error 043 Detail'
print	'Provider.PhysicianAsstFlag=N and high volume of potentially qualifying claims'

select	ServicingProviderID,
		CustomerProviderID,
		NameLast,
		CPTProcedureCode,
		ProviderType		= left(ProviderType,10),
		SpecialtyCode1		= left(SpecialtyCode1,10),
		claim_line_count
from	#claim_detail_PhysicianAsstFlag a
		inner join Provider b on 
			a.ServicingProviderID = b.ProviderID and
			(PhysicianAsstFlag = 'N' or PhysicianAsstFlag is null)
order by ServicingProviderID,
		claim_line_count desc
--****************************************************************************************
--****************************************************************************************






--****************************************************************************************
--****************************************************************************************
--validation_code		= '059',

print	'Validation Error 059 Detail'
print	'ClaimLineItem.CPTProcedureCode values that are not eligible for HEDIS'

select	CPTProcedureCode,
		count(*) --select top 10 *
from	ClaimLineItem a
where	CPTProcedureCode <> '' and
		not exists (	select	*
						from	ncqa_rdsm..tblcodesets b
						WHERE	codetype in ('CPT','HCPCS') and
								a.CPTProcedureCode = b.codevalue)
group by CPTProcedureCode having count(*)>=100
order by 2 desc
--****************************************************************************************
--****************************************************************************************


GO
