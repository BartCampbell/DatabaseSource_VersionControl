SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE  proc [dbo].[usp_update_tbl] 
as
--**************************************************************************************
--**************************************************************************************
/*
Issues:
Consider adding identity to all original tables while adding mpi.
*/
--**************************************************************************************
--**************************************************************************************



--**************************************************************************************
--**************************************************************************************
/*

*/
--**************************************************************************************
--**************************************************************************************

IF OBJECT_ID('tempdb..#HealthPlan_xref') IS NOT NULL
    DROP TABLE #HealthPlan_xref

create table #HealthPlan_xref
(HealthPlanID int identity(1,1),
 HealthPlanName varchar(10),
 HealthPlanIDQualifier varchar(10),
 measureset varchar(10) )

insert into #HealthPlan_xref
select	distinct
		left(measureset,3),
		substring(measureset,5,6),
		measureset 
from	member_gm
order by measureset



truncate table tblHealthPlan

insert into tblHealthPlan
select	HealthPlanID				= HealthPlanID,
		HealthPlanIDQualifier		= HealthPlanIDQualifier,
		HealthPlanName				= HealthPlanName,
		HealthPlanAddress1			= '',
		HealthPlanAddress2			= '',
		HealthPlanCity				= '',
		HealthPlanState				= '',
		HealthPlanZip				= '',
		HealthPlanMainContact		= '',
		HealthPlanMainContactPhone	= '',
		HealthPlanMainContactEmail	= '',
		MPISourceName				= '',
		MeasureSetID				= measureset
from	#HealthPlan_xref



--**************************************************************************************
--**************************************************************************************





--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: General Membership 
NAME		FIELD								VALUE		DESCRIPTION
MemID		Member ID										Unique Member ID
Gender		Gender 								M			Male
												F			Female
DOB			Date of Birth						YYYYMMDD	(may be blank)
Lname		Member Last Name								Only used in sampling decks
Fname		Member First Name								Only used in sampling decks
MMidName	Member Middle Initial							Member Middle Initial
SubID		Subscriber or Family ID Number					This ID differentiates between individuals when family members share the subscriber ID 
Add1		Mailing Address 1								First Line of Mailing Address
Add2		Mailing Address 2									econd Line of Mailing Address
City		City		City
State		State											2-character State - see State Abbreviation tab
MZip		Zip												5-digit Zip Code
Mphone		Telephone Number								10-digit Phone Number, no separators
PFirstName	Parent/Caretaker First Name						Parent/Caretaker First Name
PMidName	Parent/Caretaker Middle Initial					Parent/Caretaker Middle Initial
PLastName	Parent/Caretaker Last Name						Parent/Caretaker Last Name
Race		Race								01			White
												02			Black or African American
												03			American Indian and Alaska Native
												04			Asian
												05			Native Hawaiian and Other Pacific Islander
												06			Some Other Race
												07			Two or More Races
												09			Unknown Race
Ethn		Ethnicity							11			Hispanic or Latino
												12			Not Hispanic or Latino
												19			Unknown Ethnicity
Int			Interpreter							0			No, does not want an interpreter
												1			Yes, wants an interpreter
												9			Unknown need for interpreter
Lang		Language							21			English
												22			Spanish
												23			Other Indo-European Language
												24			Asian and Pacific Island Languages 
												28			Other Languages
												29			Spoken Language Unknown

*/
--**************************************************************************************
--**************************************************************************************

truncate table tblMember

insert into tblMember
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		HealthPlanMbrID			= memid,
		MemberLastName			= lname,
		MemberFirstName			= fname,
		MemberMiddleInit		= mmidname,
		MemberNamePrefix		= '',
		MemberNameSuffix		= '',
		MemberGender			= gender,
		MemberDateOfBirth		= dob,
		MemberSSN				= '',
		MemberAddress1			= add1,
		MemberAddress2			= add2,
		MemberCity				= city,
		MemberState				= state,
		MemberZip				= mzip,
		ContractHolderID		= subid,
		GardianFirstName		= pfirstname,
		GardianMidName			= pmidname,
		GardianLastName			= plastname,
		MemberRace				= race,
		MemberEthnicity			= ethn,
		MemberInterpreterFlag	= [int],
		MemberLanguage			= lang,
		meiid					= meiid,
		MeasureSetID			= a.measureset
from	member_gm a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset
--**************************************************************************************
--**************************************************************************************







--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Member Elig History

NAME		FIELD								VALUE		DESCRIPTION
MemID		Member ID										Unique Member ID
StartDate	Start Date							YYYYMMDD	Contains the greater of the enrollment date or the notification date (may be blank in some decks)
FinishDate	Disenrollment Date					YYYYMMDD	Date the member disnerolled, If there is a start date and this date is blank that indicates the member is currently enrolled
Dental		Dental Benefit						Y			"Indicates if member has a dental benefit
															(blank for all measures except ADV)"
												N			"Indicates if member has a dental benefit
															(blank for all measures except ADV)"
Drug		Drug Benefit						Y			Indicates if the member has an ambulatory prescription benefit (may be blank)
												N	
MHInpt		Mental Health Benefit - Inpatient	Y			Indicates if the member has an inpatient MH benefit (may be blank)
												N	
MHdn		Mental Health Benefit - Day/Night	Y			"Indicates if the member has a day/night 
															MH benefit (may be blank)"
												N	
Mhamb		Mental Health Benefit - Ambulatory	Y			Indicates if the member has an ambulatory MH benefit (may be blank)
												N	
CDInpt		ChemDep Benefit - Inpatient			Y			Indicates if the member has an inpatient CD benefit (may be blank)
												N	
CDdn		ChemDep Benefit - Day/Night			Y			"Indicates if the member has a day/night 
															CD benefit (may be blank)"
												N	
CDamb		ChemDep Benefit - Ambulatory		Y			Indicates if the member has an ambulatory CD benefit (may be blank)
												N	
Payer		Payer								MDE			Medicaid Dual Eligible HMO
												MD			Medicaid Disabled HMO
												MLI			Medicaid Low Income HMO
												MRB			Medicaid Restricted Benefit HMO
												MR			Medicare Advantage HMO
												MP			Medicare Advantage PPO
												MC			Medicare Cost
												PPO			Commercial PPO
												POS			Commercial POS
												HMO			Commercial HMO
												CHP			Child Health Insurance Program 
PEflag		Health Plan Employee Flag			Y			"Indicates if the member is a health plan 
															employee flag (may be blank) Currently not in use"
												N	
Ind			Indicator							Y			P4P Testing only, contains either the PO or the MCO the member is enrolled in (may be blank)
															N	

*/
--**************************************************************************************
--**************************************************************************************

truncate table tblMemberEligHistory

insert into tblMemberEligHistory
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		HealthPlanMbrID			= a.memid,
		MemberEffDate			= startdate,
		MemberTermDate			= finishdate,
		ProductType				= payer,
		BenefitType				= '',
		HealthPlanEmployeeFlag	= peflag,
		CoverageDental			= dental,
		CoveragePharmacy		= drug,
		CoverageMHInpatient		= mhinpt,
		CoverageMHDayNight		= mhdn,
		CoverageMHAmbulatory	= mhamb,
		CoverageCDInpatient		= cdinpt,
		CoverageCDDayNight		= cddn,
		CoverageCDAmbulator		= cdamb,
		--ind --testing element at NCQA, not loading
		meiid					= a.meiid,
		MeasureSetID			= a.measureset,
		MemberState				= c.state --ncqa data does not currently allow state changes over time.
from	member_en a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset
		inner join member_gm c on
			a.memid = c.memid and
			a.measureset = c.measureset


--**************************************************************************************
--**************************************************************************************









--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Lab
NAME		FIELD				DESCRIPTION
MemID		Member ID			Unique Member ID
CPT Code	Test				CPT Code for LDL or HbA1c (blank values are tested)
LOINC		LOINC Code			Indicates LOINC code for this lab event (dash included)
Value		Value				Value with decimal (blank values are tested)
Date_S		Date of Service		(blank values are tested)
PNInd		Indicator			Positive (used for macro and micro albumen tests only) / Negative  (used for macro and micro albumen tests only)
*/
--**************************************************************************************
--**************************************************************************************

truncate table tblLab

insert into tblLab
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		OrderNum				= '',
		ServiceDate				= case	when date_s = '' 
										then null 
										when isdate(date_s)=0 
										then null 
										else date_s 
								  end,
		OrderingProviderID		= '',
		OrderingProvIDType		= '',
		HealthPlanMbrID			= memid,
		LabProvID				= '',
		HCPCSProcCode			= cptcode,
		LOINCCode				= ltrim(rtrim(loinc)),
		LabValue				= case	when isnumeric(ltrim(rtrim([value])))=1 
										then convert(decimal(9,4),ltrim(rtrim([value])))
										else null 
								  end,
		PNInd					= pnind,
		meiid					= meiid,
		MeasureSetID			= a.measureset
from	lab a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset
--**************************************************************************************
--**************************************************************************************







--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Provider
NAME		FIELD								VALUE	DESCRIPTION
ProvID		Provider ID									Unique Provider ID
PCP			PCP Flag							Y		Indicates if provider is a PCP or not (blank if not necessary for the measure)
												N	
OBGYN		OBGYN Flag							Y		Indicates if provider is a OBGYN or not (blank if not necessary for the measure)
												N	
MHProv		MH Provider Flag					Y		Indicates if provider is a MH provider or not (blank if not necessary for the measure)
												N	
EyeCProv	EyeCare Provider Flag				Y		Indicates if provider is an eye care provider or not (blank if not necessary for the measure)
												N	
Dentist		Dentist Flag						Y		Indicates if provider is a dentist or not (blank if not necessary for the measure)
												N	
Neph		Nephrologist Flag					Y		Indicates if provider is a nephrologist or not (blank if not necessary for the measure)
												N	
CDProv		CD Provider Flag					Y		Indicates if provider is a CD provider or not (blank if not necessary for the measure)
												N	
NPR			NPR Provider Flag					Y		Indicates if provider is a nurse practitioner or not (blank if not necessary for the measure)
												N	
PAS			PAS Provider Flag					Y		Indicates if provider is a Physician Assistant or not (blank if not necessary for the measure)
												N	
ProvPres	Provider Prescribing Privileges		Y		Indicates if provider has prescribing privileges  or not (blank if not necessary for the measure)
												N	
Inp			Inpatient Provider Flag **			Y		Indicates if provider is paid at an inpatient rate or not (blank if not necessary for the measure)
												N	
Out			Outpatient Provider Flag **			Y		Indicates if provider is paid at an outpatient rate or not (blank if not necessary for the measure)
												N	
*/
--**************************************************************************************
--**************************************************************************************

truncate table tblProvider

insert into tblProvider
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		ProviderId				= provid,
		ProviderLastName		= '',
		ProviderFirstName		= '',
		ProviderMiddleInit		= '',
		ProviderSuffix			= '',
		ProviderTitle			= '',
		ProviderBirthDate		= '',
		ProviderGender			= '',
		ProviderLicenseNo		= '',
		ProviderBoardCert1		= '',
		ProviderBoardCert2		= '',
		ProviderDEA				= '',
		ProviderUPIN			= '',
		ProviderMedicaidID		= '',
		ProviderNPI				= '',
		ProviderSpec1Code		= '',
		ProviderSpec2Code		= '',
		ProviderEIN				= '',
		ProviderSSN				= '',
		ProviderPrimPhone		= '',
		ProviderSecondPhone		= '',
		ProviderEmail			= '',
		ProviderType			= '',
		ProviderPrescribPrivFlag		= provpres,
		ProviderPaidInpatientRateFlag	= inp,
		ProviderPaidOutpatientRateFlag	= out,
		PCPFlag					= pcp,
		OBGynFlag				= obgyn,
		MentalhealthFlag		= mhprov,
		EyeCareFlag				= eyecprov,
		DentistFlag				= dentist,
		NephrologistFlag		= neph,
		CDProviderFlag			= cdprov,
		NursePractFlag			= npr,
		PhysicianAsstFlag		= pas,
		meiid					= meiid,
		MeasureSetID			= a.measureset 
from	provider  a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset
--**************************************************************************************
--**************************************************************************************









--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Pharmacy
NAME		FIELD										VALUE	DESCRIPTION
MemID		Member ID											Unique Member ID
PDaysSup	Days supply of prescription							Indicates the number of days the prescription should last if taken according to the directions
Supply		Supply flag									Y		Indicates if the claim is for a supply or not (may be balnk)
														N	
PrServDate	Service Date								YYYYMMDD	
PDiscIng	Discounted Ingredient Cost (right justified)		No decimal point
PDisR		Discount/Rebate (right justified)			Positive values	No decimal point
PDispFee	Dispense Fee (right justified)						No decimal point
PAdmFee		Administration Fee (right justified)				No decimal point
PMemberCo	Member copay/deductible (right justified)			No decimal point
NDC			NDC Drug Code										Indicates type of drug
Clmstat		Claim status								1		Paid
														2		Denied
mquant		Metric Quantity										Indicates metric quantity dispensed


*/
--**************************************************************************************
--**************************************************************************************

truncate table tblPharmacyClaim

insert into tblPharmacyClaim
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		ClaimNum				= '',
		DispenseDate			= case when prservdate = '' then null else prservdate end,
		PaidDate				= '',
		OrderDate				= '',
		PrescribingProvID		= '',
		PrescribingProvIDType	= '',
		HealthPlanMbrID			= memid,
		PharmacyProvID			= '',
		NDCCode					= ndc,
		NDCFormat				= '',
		Quantity				= case when isnumeric(mquant)=1 then mquant else 0 end,
		DaysSupply				= case when isnumeric(pdayssup)=1 then pdayssup else 0 end,
		AdjIndicator			= '',
		MailOrderIndicator		= '',
		DispenseAsWritten		= '',
		SupplyFlag				= supply,
		DiscountIngredientCost	= pdiscing,
		DiscountRebate			= pdisr,
		DiscountDispFee			= pdispfee,
		DiscountAdminFee		= padmfee,
		MemberCopay				= pmemberco,
		ClaimStatus				= clmstat,
		meiid					= meiid,
		MeasureSetID			= a.measureset
from	pharm a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset
--**************************************************************************************
--**************************************************************************************









--**************************************************************************************
--**************************************************************************************
/*
NCQA Test Deck: Visit
NAME		FIELD									VALUE		DESCRIPTION
MemID		Member ID											Unique Member ID
Date_S		Date of Service							YYYYMMDD	Date of Service for an ambulatory event, admission date for inpatient events
Date_Adm	Admission Date							YYYYMMDD	Date of admission for inpatient events (blank for ambulatory events)
Date_Disch	Discharge Date							YYYYMMDD	Date of discharge for inpatient events (blank for ambulatory events)
DaysCov		Covered Days										Total number of days covered for a particular admission (same number will appear on every claim line)(will be blank for ambulatory services)
CPT	CPT		Code												CPT-4 procedure code (blank for inpatient services)
CPTMod		CPT Modifiers							e.g.:50		No decimal point
HCPCS		HCPCS code											Valid HCPC codes (blank if measure does not include HCPCs codes)
CPT2		CPT II Code											Valid CDT II codes (blank if measure does not include CDT II codes)
Diag_I_1	Principal ICD-9 Diagnosis Code						Valid ICD-9 diagnosis codes (blank if measure does not include ICD-9 codes)
Diag_I_2	Secondary ICD-9 Diagnosis code (2)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_3	Secondary ICD-9 Diagnosis code (3)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_4	Secondary ICD-9 Diagnosis code (4)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_5	Secondary ICD-9 Diagnosis code (5)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_6	Secondary ICD-9 Diagnosis code (6)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_6	Secondary ICD-9 Diagnosis code (7)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_6	Secondary ICD-9 Diagnosis code (8)					Valid ICD-9 diagnosis codes (may be blank)
Diag_I_6	Secondary ICD-9 Diagnosis code (9)					Valid ICD-9 diagnosis codes (may be blank)
Proc_I_1	Principal ICD-9 Procedure Code						Valid ICD-9 procedure codes (blank if measure does not include ICD-9 codes)
Proc_I_2	Secondary ICD-9 Procedure code (2)					Valid ICD-9 procedure codes (may be blank)
Proc_I_3	Secondary ICD-9 Procedure code (3)					Valid ICD-9 procedure codes (may be blank)
Proc_I_4	Secondary ICD-9 Procedure code (4)					Valid ICD-9 procedure codes (may be blank)
Proc_I_5	Secondary ICD-9 Procedure code (5)					Valid ICD-9 procedure codes (may be blank)
Proc_I_6	Secondary ICD-9 Procedure code (6)					Valid ICD-9 procedure codes (may be blank)
DRG			DRG Code											Valid DRG codes (blank if measure does not include DRG codes)
DischStatus	Discharge Status 									Form Locator 22 Values (blank if measure does not require discharge status)
Rev			UB-92 Revenue Code									Valid revenue codes (blank if measure does not require revenue codes)
BillType	UB-92 Type of Bill Code								Valid type of bill codes (blank if measure does not require type of bill codes)
OccurCode	UB-92 Occurrence Code								Valid occurrence codes (blank if measure does not require occurrence codes)
HCFAPOS		CMS Place of Service Code							Valid place of service codes (blank if measure does not require place of service codes)
ClaimStatus	Claim Status								1		Paid
														2		Denied
														Blank	Denied
ProvID		Provider ID											Unique Proivider ID
PCP			PCP Flag									Y		Indicates if provider is a PCP or not (blank if not necessary for the measure)
														N	
OBGYN		OBGYN Flag									Y		Indicates if provider is a OBGYN or not (blank if not necessary for the measure)
														N	
MHProv		MH Provider Flag							Y		Indicates if provider is a MH provider or not (blank if not necessary for the measure)
														N	
EyeCProv	EyeCare Provider Flag						Y		Indicates if provider is an eye care provider or not (blank if not necessary for the measure)
														N	
Dentist		DentistFlag									Y		Indicates if provider is a dentist or not (blank if not necessary for the measure)
														N	
ProvPres	Provider Prescribing Privileges				Y		Indicates if provider has prescribing privileges  or not (blank if not necessary for the measure)
														N	
Neph		Nephrologist Flag							Y		Indicates if provider is a nephrologist or not (blank if not necessary for the measure)
														N	
CDProv		CD Provider Flag							Y		Indicates if provider is a CD provider or not (blank if not necessary for the measure)
														N	
NPRProv		NPR Provider Flag							Y		Indicates if provider is a Nurse Practitioner provider or not (blank if not necessary for the measure)
														N	
PASProv		PAS Provider Flag							Y		Indicates if provider is a Physicians Assistant provider or not (blank if not necessary for the measure)
														N	

*/
--**************************************************************************************
--**************************************************************************************

IF OBJECT_ID('tempdb..#visit') IS NOT NULL
    DROP TABLE #visit

create table #visit
(	claim_line_id int identity(1,1),
	[instance] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meiid] [uniqueidentifier] NULL,
	[memid] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_s] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_adm] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[date_disch] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dayscov] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpt] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cptmod] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hcpcs] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cpt2] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_1] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_2] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_3] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_4] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_5] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_6] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_7] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_8] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diag_i_9] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_1] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_2] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_3] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_4] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_5] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proc_i_6] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drg] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dischstatus] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rev] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[billtype] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[occurcode] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hcfapos] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[claimstatus] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[provid] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meiid_prov] [uniqueidentifier] NULL,
	[pcp] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[obgyn] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mhprov] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[eyecprov] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dentist] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[provpres] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[neph] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cdprov] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nprprov] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pasprov] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[measureset] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)




insert into #visit
select	instance,
        meiid,
        memid,
        date_s,
        date_adm,
        date_disch,
        dayscov,
        cpt,
        cptmod,
        hcpcs,
        cpt2,
        diag_i_1,
        diag_i_2,
        diag_i_3,
        diag_i_4,
        diag_i_5,
        diag_i_6,
        diag_i_7,
        diag_i_8,
        diag_i_9,
        proc_i_1,
        proc_i_2,
        proc_i_3,
        proc_i_4,
        proc_i_5,
        proc_i_6,
        drg,
        dischstatus,
        rev,
        billtype,
        occurcode,
        hcfapos,
        claimstatus,
        provid,
        meiid_prov,
        pcp,
        obgyn,
        mhprov,
        eyecprov,
        dentist,
        provpres,
        neph,
        cdprov,
        nprprov,
        pasprov,
        measureset
from	visit



truncate table tblClaimHeader

insert into tblClaimHeader
select	distinct
		HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		ClaimNum				= claim_line_id,
		ClaimType				= '',
		HealthPlanMbrID			= memid,
		HealthPlanProviderID	= provid,
		From_date				= case	when	date_adm = '' 
										then	case	when isdate(date_s)=0 
														then null 
														else date_s 
												end 
										else	date_adm 
									end,
		Thru_date				= case when date_disch = '' then null else date_disch end,
		CoveredDays				= dayscov,
		Diag1					= diag_i_1,
		Diag2					= diag_i_2,
		Diag3					= diag_i_3,
		Diag4					= diag_i_4,
		Diag5					= diag_i_5,
		Diag6					= diag_i_6,
		Diag7					= diag_i_7,
		Diag8					= diag_i_8,
		Diag9					= diag_i_9,
		DRG						= drg,
		Icd9surgproc1			= proc_i_1,
		Icd9surgproc2			= proc_i_2,
		Icd9surgproc3			= proc_i_3,
		Icd9surgproc4			= proc_i_4,
		Icd9surgproc5			= proc_i_5,
		Icd9surgproc6			= proc_i_6,
		BillType				= billtype,
		DischargeStatus			= dischstatus,
		OccurrenceCode			= occurcode,
		PatientStatus			= '',
		PlaceOfService			= hcfapos,
		ClaimStatus				= claimstatus,
		meiid					= meiid,
		meiid_prov				= meiid_prov,
		MeasureSetID			= a.measureset
from	#visit a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset




truncate table tblClaimDetail

insert into tblClaimDetail
select	HealthPlanID			= HealthPlanID,
		HealthPlanIDQualifier	= HealthPlanIDQualifier,
		ClaimNum				= claim_line_id,
		LineNum					= '1',
		SubLineNo				= '',
		ClaimType				= '',
		ServiceDate				= case	when date_s = ''
										then case when date_adm = '' then null else date_adm end
										when isdate(date_s)=0 
										then null 
										else date_s end,
		PaidDate				= '',
		HCPCSProcCode			= case	when cpt <> '' then cpt
										when hcpcs <> '' then hcpcs
										else ''
								  end,
		HCPCSModifier			= cptmod,
		RevenueCode				= rev,
		Units					= null,
		AdjustDate				= '',
		ClaimStatus				= claimstatus,
		ApStatus				= '',
		CptIICode				= cpt2,
		meiid					= meiid,
		MeasureSetID			= a.measureset
from	#visit a
		inner join #HealthPlan_xref b on
			a.measureset = b.measureset



--**************************************************************************************
--**************************************************************************************



/* END OF PROCEDURE: [usp_update_tbl]  */













GO
