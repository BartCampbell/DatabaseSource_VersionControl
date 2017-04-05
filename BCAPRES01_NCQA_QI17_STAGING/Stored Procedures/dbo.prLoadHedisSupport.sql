SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE PROCEDURE [dbo].[prLoadHedisSupport]
	@vcMeasureSetID	varchar( 10 ) = NULL
AS
/*
exec prLoadHedisSupport 'BCS_Sample'

declare @vcMeasureSetID	varchar( 10 )
set		@vcMeasureSetID = null

*/
truncate table dw_hedis_member_elig
truncate table dw_hedis_member
truncate table dw_hedis_claim_hdr
truncate table dw_hedis_claim_dtl
truncate table dw_hedis_proc_list
truncate table dw_hedis_surg_proc_list
truncate table dw_hedis_pharmacy
truncate table dw_hedis_lab
truncate table dw_hedis_drg
truncate table dw_hedis_diag_list
truncate table dw_hedis_provider


-- This procedure loads the tables used by the Hedis procedures
-- Note that dw_keys are included for backward compatibility.  Going forward, we'll use
-- DRI IDs from the standard tables.



--load dw_hedis_provider
INSERT INTO dw_hedis_provider
	(	ihds_prov_id, 
		ProviderId,
		ProviderPrescribingPrivFlag,
--		ProviderPaidInpatientRateFlag,
--		ProviderPaidOutpatientRateFlag,
		PCPFlag, 
		OBGynFlag, 
		MentalhealthFlag, 
		EyeCareFlag, 
		DentistFlag, 
		NephrologistFlag, 
		CDProviderFlag, 
		NursePractFlag, 
		PhysicianAsstFlag, 
		ClinicalPharmacistFlag, 
		AnesthesiologistFlag)
SELECT	
		ihds_prov_id					= a.ihds_prov_id,
		ProviderId						= a.ProviderId,
		ProviderPrescribingPrivFlag		= a.ProviderPrescribingPrivFlag,
--		ProviderPaidInpatientRateFlag	= a.ProviderPaidInpatientRateFlag,
--		ProviderPaidOutpatientRateFlag	= a.ProviderPaidOutpatientRateFlag,
		PCPFlag							= a.PCPFlag,
		OBGynFlag						= a.OBGynFlag,
		MentalhealthFlag				= a.MentalhealthFlag,
		EyeCareFlag						= a.EyeCareFlag,
		DentistFlag						= a.DentistFlag,
		NephrologistFlag				= a.NephrologistFlag,
		CDProviderFlag					= a.CDProviderFlag,
		NursePractFlag					= a.NursePractFlag,
		PhysicianAsstFlag				= a.PhysicianAsstFlag, 
		ClinicalPharmacistFlag			= a.ClinicalPharmacistFlag , 
		AnesthesiologistFlag			= a.AnesthesiologistFlag 
FROM	dbo.Provider a
--WHERE	a.HedisMeasureID = ISNULL( @vcMeasureSetID, a.HedisMeasureID ) 
WHERE	isnull(a.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(a.HedisMeasureID,'empty') ) 




-- Load dw_hedis_member_elig
INSERT INTO dw_hedis_member_elig
(		ihds_member_id, 
		mem_hist_pk1, 
		mem_hist_pk2, 
		mem_hist_pk3, 
		mem_hist_pk4,
		mem_hist_pk5, 
		eff_date, 
		term_date, 
		lob,
		member_state,
		HealthPlanEmployeeFlag,
		CoverageDentalFlag,
		CoveragePharmacyFlag,
		CoverageMHInpatientFlag,
		CoverageMHDayNightFlag,
		CoverageMHAmbulatoryFlag,
		CoverageCDInpatientFlag,
		CoverageCDDayNightFlag,
		CoverageCDAmbulatoryFlag,
		create_datetime, 
		update_datetime )
SELECT	ihds_member_id				= m.ihds_member_id, 
		mem_hist_pk1				= e.EligibilityID, 
		mem_hist_pk2				= NULL, 
		mem_hist_pk3				= NULL, 
		mem_hist_pk4				= NULL,
		mem_hist_pk5				= NULL, 
		eff_date					= convert(varchar(8),e.DateEffective,112), 
		term_date					= convert(varchar(8),e.DateTerminated,112), 
		lob							= ProductType,
		member_state				= State,
		HealthPlanEmployeeFlag		= HealthPlanEmployeeFlag,
		CoverageDentalFlag			= CoverageDentalFlag,
		CoveragePharmacyFlag		= CoveragePharmacyFlag,
		CoverageMHInpatientFlag		= CoverageMHInpatientFlag,
		CoverageMHDayNightFlag		= CoverageMHDayNightFlag,
		CoverageMHAmbulatoryFlag	= CoverageMHAmbulatoryFlag,
		CoverageCDInpatientFlag		= CoverageCDInpatientFlag,
		CoverageCDDayNightFlag		= CoverageCDDayNightFlag,
		CoverageCDAmbulatoryFlag	= CoverageCDAmbulatoryFlag,
		create_datetime				= GETDATE(), 
		update_datetime				= GETDATE() 
FROM	dbo.Member m
	JOIN dbo.Eligibility e ON m.MemberID = e.MemberID
--WHERE	m.HedisMeasureID = ISNULL( @vcMeasureSetID, m.HedisMeasureID ) 
WHERE	isnull(m.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(m.HedisMeasureID,'empty') ) 



-- Load dw_hedis_member
INSERT INTO dbo.dw_hedis_member
	(	ihds_member_id, 
		gender, 
		dob, 
		race, 
		ethnicity, 
		member_language, 
		interpreter_flag, 
		SourceName )
SELECT	ihds_member_id	= ihds_member_id, 
		gender				= Gender, 
		dob					= convert(varchar(8),DateOfBirth,112),
		race				= Race, 
		ethnicity			= Ethnicity, 
		member_language		= MemberLanguage, 
		interpreter_flag	= InterpreterFlag, 
		SourceName			= 'Member' 
FROM	dbo.Member
WHERE	ihds_member_id NOT IN( SELECT ihds_member_id FROM dbo.dw_hedis_member ) and
		--HedisMeasureID = ISNULL( @vcMeasureSetID, HedisMeasureID ) 
		isnull(HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(HedisMeasureID,'empty') ) 






DROP INDEX dw_hedis_claim_hdr.fk_dw_hedis_claim_hdr
DROP STATISTICS dw_hedis_claim_hdr.sp_fk_dw_hedis_claim_hdr

-- Load dw_hedis_claim_hdr
INSERT INTO dbo.dw_hedis_claim_hdr( 
	claim_src, 
	claim_pk1, 
	claim_pk2, 
	claim_pk3, 
	claim_pk4,
	claim_pk5, 
	claim_pk6, 
	claim_pk7, 
	claim_pk8, 
	claim_pk9, 
	claim_pk10, 
	claim_type )
SELECT	
	claim_src	= 'dbo.Claim', 
	claim_pk1	= ClaimID, 
	claim_pk2	= '', 
	claim_pk3	= '', 
	claim_pk4	= '', 
	claim_pk5	= '', 
	claim_pk6	= '', 
	claim_pk7	= '', 
	claim_pk8	= '', 
	claim_pk9	= '', 
	claim_pk10	= '', 
	claim_type	= ClaimType
FROM	dbo.Claim
--WHERE	HedisMeasureID = ISNULL( @vcMeasureSetID, HedisMeasureID ) 
WHERE	isnull(HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(HedisMeasureID,'empty') ) 
UNION
SELECT
	claim_src	= 'dbo.PharmacyClaim', 
	claim_pk1	= PharmacyClaimID, 
	claim_pk2	= '', 
	claim_pk3	= '', 
	claim_pk4	= '', 
	claim_pk5	= '', 
	claim_pk6	= '', 
	claim_pk7	= '', 
	claim_pk8	= '', 
	claim_pk9	= '', 
	claim_pk10	= '', 
	claim_type	= 'Pharmacy' 
FROM	dbo.PharmacyClaim
--WHERE	HedisMeasureID = ISNULL( @vcMeasureSetID, HedisMeasureID ) 
WHERE	isnull(HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(HedisMeasureID,'empty') ) 
UNION
SELECT
	claim_src	= 'dbo.LabResult', 
	claim_pk1	= LabResultID, 
	claim_pk2	= '', 
	claim_pk3	= '', 
	claim_pk4	= '', 
	claim_pk5	= '', 
	claim_pk6	= '', 
	claim_pk7	= '', 
	claim_pk8	= '', 
	claim_pk9	= '', 
	claim_pk10	= '', 
	claim_type	= 'Lab' 
FROM	dbo.LabResult
--WHERE	HedisMeasureID = ISNULL( @vcMeasureSetID, HedisMeasureID ) 
WHERE	isnull(HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(HedisMeasureID,'empty') ) 

create index fk_dw_hedis_claim_hdr on dw_hedis_claim_hdr 
(claim_src, claim_pk1,claim_pk2,claim_pk3,claim_pk4,claim_pk5,claim_pk6,claim_pk7,claim_pk8,claim_pk9,claim_pk10)

create statistics sp_fk_dw_hedis_claim_hdr on dw_Hedis_claim_hdr
(claim_src, claim_pk1,claim_pk2,claim_pk3,claim_pk4,claim_pk5,claim_pk6,claim_pk7,claim_pk8,claim_pk9,claim_pk10) with fullscan






DROP INDEX dw_hedis_claim_dtl.fk_dw_hedis_claim_dtl
DROP STATISTICS dw_hedis_claim_dtl.sp_fk_dw_hedis_claim_dtl

-- Load dw_hedis_claim_dtl
INSERT INTO dbo.dw_hedis_claim_dtl( 
	dw_hedis_claim_hdr_key, 
	claim_src, 
	claim_pk1, 
	claim_pk2,
	claim_pk3, 
	claim_pk4, 
	claim_pk5, 
	claim_pk6, 
	claim_pk7, 
	claim_pk8, 
	claim_pk9, 
	claim_pk10,
	claim_type )
SELECT	
	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
	claim_src				= 'dbo.Claim', 
	claim_pk1				= l.ClaimID, 
	claim_pk2				= l.ClaimLineItemID, 
	claim_pk3				= '', 
	claim_pk4				= '', 
	claim_pk5				= '', 
	claim_pk6				= '', 
	claim_pk7				= '', 
	claim_pk8				= '', 
	claim_pk9				= '', 
	claim_pk10				= '', 
	claim_type				= c.ClaimType
FROM	dbo.Claim c
	JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID
	JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			'dbo.Claim' = h.claim_src
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) 
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) 

create index fk_dw_hedis_claim_dtl on dw_hedis_claim_dtl
(claim_src, claim_pk1, claim_pk2, claim_pk3, claim_pk4, claim_pk5, claim_pk6, claim_pk7, claim_pk8, claim_pk9, claim_pk10)

create statistics sp_fk_dw_hedis_claim_dtl on dw_hedis_claim_dtl
(claim_src, claim_pk1, claim_pk2, claim_pk3, claim_pk4, claim_pk5, claim_pk6, claim_pk7, claim_pk8, claim_pk9, claim_pk10) with fullscan







DROP INDEX dw_hedis_diag_list.ix_dw_hedis_diag_list
DROP STATISTICS dw_hedis_diag_list.sp_dw_hedis_diag_list
DROP INDEX dw_hedis_diag_list.ix_dw_hedis_diag_list_ihds_member_id
DROP STATISTICS dw_hedis_diag_list.sp_dw_hedis_diag_list_ihds_member_id

-- Load dw_hedis_diag_list
INSERT INTO dbo.dw_hedis_diag_list
(		dw_hedis_claim_hdr_key, 
		claim_type, 
		ihds_prov_id, 
		service_date, 
		ihds_member_id,
		diag_code, 
		diag_code_source, 
		place_of_service, 
		bill_type, 
		prov_spec, 
		discharge_status,
		claim_status,
		admit_date, 
		thru_date )
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode1, 
		diag_code_source		= 'DiagnosisCode1', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status		= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd 
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode1 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode2, 
		diag_code_source		= 'DiagnosisCode2', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode2 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode3, 
		diag_code_source		= 'DiagnosisCode3', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode3 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode4, 
		diag_code_source		= 'DiagnosisCode4', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode4 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode5, 
		diag_code_source		= 'DiagnosisCode5', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode5 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode6, 
		diag_code_source		= 'DiagnosisCode6', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode6 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode7, 
		diag_code_source		= 'DiagnosisCode7', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode7 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0),  
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode8, 
		diag_code_source		= 'DiagnosisCode8', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode8 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0),  
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode9, 
		diag_code_source		= 'DiagnosisCode9', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode9 <> ''
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key,
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0),  
		service_date			= c.DateServiceBegin, 
		ihds_member_id			= m.ihds_member_id,
		diag_code				= c.DiagnosisCode10, 
		diag_code_source		= 'DiagnosisCode10', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		discharge_status			= c.DischargeStatus, 
		claim_status			= c.ClaimStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd
FROM	dbo.Claim c
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON
			c.ihds_prov_id_servicing = p.ihds_prov_id
		JOIN dbo.dw_hedis_claim_hdr h ON 
				c.ClaimID = h.claim_pk1 and
				h.claim_src = 'dbo.Claim'
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisCode10 <> ''

create index ix_dw_hedis_diag_list on dw_hedis_diag_list
(diag_code)

create statistics sp_dw_hedis_diag_list on dw_hedis_diag_list
(diag_code) with fullscan


create index ix_dw_hedis_diag_list_ihds_member_id on dw_hedis_diag_list
(ihds_member_id)

create statistics sp_dw_hedis_diag_list_ihds_member_id on dw_hedis_diag_list
(ihds_member_id) with fullscan







-- Load dw_hedis_drg

IF OBJECT_ID('tempdb..#claim_level_covered_days') IS NOT NULL
DROP TABLE #claim_level_covered_days

select	ClaimID,
		CoveredDays		= sum(isnull(CoveredDays,0))
into	#claim_level_covered_days
FROM	dbo.ClaimLineItem l 
group by ClaimID



INSERT INTO dbo.dw_hedis_drg
	(	dw_hedis_claim_hdr_key, 
		claim_type, 
		ihds_member_id, 
		ihds_prov_id,
		service_date, 
		drg_code, 
		drg_type,
		drg_source, 
		place_of_service, 
		bill_type, 
		provider_specialty,
		primary_diagnosis_code, 
		discharge_status, 
		admit_date, 
		thru_date,
		claim_status,
		covered_days )
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_member_id			= m.ihds_member_id, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		drg_code				= c.DiagnosisRelatedGroup,
		drg_type				= c.DiagnosisRelatedGroupType, 
		drg_source				= 'Claim', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		provider_specialty		= p.SpecialtyCode1,
		primary_diagnosis_code	= c.DiagnosisCode1, 
		discharge_status			= c.DischargeStatus, 
		admit_date				= c.DateServiceBegin, 
		thru_date				= c.DateServiceEnd, 
		claim_status			= c.ClaimStatus , 
		covered_days			= isnull(cov.CoveredDays,0)
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
		left join #claim_level_covered_days cov on
			c.ClaimID = cov.ClaimID
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )  and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		c.DiagnosisRelatedGroup not in  ('','000')





-- Load dw_hedis_lab
INSERT INTO dbo.dw_hedis_lab
	(	dw_hedis_claim_hdr_key, 
		dw_hedis_claim_dtl_key, 
		source_table,
		source_db, 
		ihds_member_id, 
		ihds_prov_id, 
		service_date, 
		loinc, 
		procedure_code, 
		plan_code,
		measurement, 
		pos_neg_indicator,
		hedis_measure )
SELECT	dw_hedis_claim_hdr_key	= dw_hedis_claim_hdr_key, 
		dw_hedis_claim_dtl_key	= NULL, 
		source_table			= 'LabResult',
		source_db				= 'WSMA_IMIDataStore', 
		ihds_member_id			= m.ihds_member_id, 
		ihds_prov_id			= 0, 
		service_date			= l.DateOfService, 
		loinc					= ltrim(rtrim(l.LOINCCode)), 
		procedure_code			= l.HCPCSProcedureCode, 
		plan_code				= NULL,
		measurement				= l.LabValue, 
		pos_neg_indicator		= l.PNIndicator,
		hedis_measure			= l.HedisMeasureID 
FROM	dbo.LabResult l
		JOIN dbo.Member m ON 
			l.CustomerMemberID = m.CustomerMemberID
		JOIN dbo.dw_hedis_claim_hdr h ON 
			l.LabResultID = h.claim_pk1 and
			h.claim_src = 'dbo.LabResult'
--WHERE	l.HedisMeasureID = ISNULL( @vcMeasureSetID, l.HedisMeasureID ) 
WHERE	isnull(l.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(l.HedisMeasureID,'empty') )





-- Load dw_hedis_pharmacy
INSERT INTO dbo.dw_hedis_pharmacy
	(	dw_hedis_claim_hdr_key, 
		source_table, 
		source_db, 
		ihds_member_id, 
		ihds_prov_id, 
		service_date, 
		ndc_code, 
		therapeutic_class,
		gpi14_code, 
		drug_name, 
		generic_product_name, 
		drug_dosage_form, 
		drug_strength,
		hedis_measure, 
		days_supply, 
		quantity,
		claim_status,
		discounted_ingredient_cost,
		rebate,
		dispensing_fee,
		administration_fee,
		member_liability,
		supply_flag )
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		source_table			= 'PharmacyClaim', 
		source_db				= 'WSMA_IMIDataStore', 
		ihds_member_id			= m.ihds_member_id, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateDispensed,112), 
		ndc_code				= c.NDC, 
		therapeutic_class		= NULL,
		gpi14_code				= NULL, 
		drug_name				= NULL, 
		generic_product_name	= NULL, 
		drug_dosage_form		= NULL, 
		drug_strength			= NULL,
		hedis_measure			= NULL, 
		days_supply				= c.DaysSupply, 
		quantity				= c.Quantity,
		claim_status			= c.ClaimStatus,
		discounted_ingredient_cost	= c.CostIngredient,
		rebate					= c.CostRebate,
		dispensing_fee			= c.CostDispensingFee,
		administration_fee		= c.CostAdministrationFee,
		member_liability		= c.CostCopay,
		supply_flag				= c.SupplyFlag
FROM	dbo.PharmacyClaim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.PharmacyClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.PharmacyClaim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.PrescribingProviderID = p.ProviderID
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) 
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )







DROP INDEX dw_hedis_proc_list.ix_dw_hedis_proc_list
DROP STATISTICS dw_hedis_proc_list.sp_dw_hedis_proc_list

-- Load dw_hedis_proc_list
INSERT INTO dbo.dw_hedis_proc_list
	(	dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key, 
		claim_type,
		ihds_prov_id, 
		service_date, 
		service_from_date, 
		service_to_date, 
		ihds_member_id,
		procedure_code, 
		procedure_modifier1, 
		procedure_modifier2, 
		procedure_code_source, 
		place_of_service, 
		bill_type,
		prov_spec, 
		primary_diag_code, 
		claim_status, 
		discharge_status,
		units,
		covered_days )
SELECT	dw_hedis_claim_dtl_key	= d.dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key	= d.dw_hedis_claim_hdr_key, 
		claim_type				= isnull(c.ClaimType,''),
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd, 
		ihds_member_id			= m.ihds_member_id,
		procedure_code			= l.CPTProcedureCode, 
		procedure_modifier1		= l.CPTProcedureCodeModifier1, 
		procedure_modifier2		= l.CPTProcedureCodeModifier2, 
		procedure_code_source	= 'CPTProcedureCode', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType,
		prov_spec				= p.SpecialtyCode1, 
		primary_diag_code		= c.DiagnosisCode1, 
		claim_status			= c.ClaimStatus, 
		discharge_status		= DischargeStatus,
		units					= l.Units,
		covered_days			= l.CoveredDays
FROM	dbo.Claim c
	INNER HASH JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID 
	INNER HASH JOIN dbo.dw_hedis_claim_dtl d ON 
			'dbo.Claim' = d.claim_src and
			l.ClaimID = d.claim_pk1 and
			l.ClaimLineItemID = d.claim_pk2
	JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
	LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		l.CPTProcedureCode <> ''






INSERT INTO dbo.dw_hedis_proc_list
	(	dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key, 
		claim_type,
		ihds_prov_id, 
		service_date, 
		service_from_date, 
		service_to_date, 
		ihds_member_id,
		procedure_code, 
		procedure_modifier1, 
		procedure_modifier2, 
		procedure_code_source, 
		place_of_service, 
		bill_type,
		prov_spec, 
		primary_diag_code, 
		claim_status, 
		discharge_status,
		units,
		covered_days )
SELECT	dw_hedis_claim_dtl_key	= d.dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key	= d.dw_hedis_claim_hdr_key, 
		claim_type				= isnull(c.ClaimType,''),
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd, 
		ihds_member_id			= m.ihds_member_id,
		procedure_code			= l.HCPCSProcedureCode, 
		procedure_modifier1		= l.CPTProcedureCodeModifier1, 
		procedure_modifier2		= l.CPTProcedureCodeModifier2, 
		procedure_code_source	= 'HCPCSProcedureCode', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType,
		prov_spec				= p.SpecialtyCode1, 
		primary_diag_code		= c.DiagnosisCode1, 
		claim_status			= c.ClaimStatus, 
		discharge_status		= DischargeStatus,
		units					= l.Units,
		covered_days			= l.CoveredDays
FROM	dbo.Claim c
	INNER HASH JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID 
	INNER HASH JOIN dbo.dw_hedis_claim_dtl d ON 
			'dbo.Claim' = d.claim_src and
			l.ClaimID = d.claim_pk1 and
			l.ClaimLineItemID = d.claim_pk2
	JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
	LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		l.HCPCSProcedureCode <> ''



INSERT INTO dbo.dw_hedis_proc_list
	(	dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key, 
		claim_type,
		ihds_prov_id, 
		service_date, 
		service_from_date, 
		service_to_date, 
		ihds_member_id,
		procedure_code, 
		procedure_modifier1, 
		procedure_modifier2, 
		procedure_code_source, 
		place_of_service, 
		bill_type,
		prov_spec, 
		primary_diag_code, 
		claim_status, 
		discharge_status, 
		units,
		covered_days )
SELECT	dw_hedis_claim_dtl_key	= d.dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key	= d.dw_hedis_claim_hdr_key, 
		claim_type				= isnull(c.ClaimType,''),
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd, 
		ihds_member_id			= m.ihds_member_id,
		procedure_code			= l.RevenueCode, 
		procedure_modifier1		= '', 
		procedure_modifier2		= '', 
		procedure_code_source	= 'RevenueCode', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType,
		prov_spec				= p.SpecialtyCode1, 
		primary_diag_code		= c.DiagnosisCode1, 
		claim_status			= c.ClaimStatus, 
		discharge_status		= DischargeStatus,
		units					= l.Units,
		covered_days			= l.CoveredDays
FROM	dbo.Claim c
	INNER HASH JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID 
	INNER HASH JOIN dbo.dw_hedis_claim_dtl d ON 
			'dbo.Claim' = d.claim_src and
			l.ClaimID = d.claim_pk1 and
			l.ClaimLineItemID = d.claim_pk2
	JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
	LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		l.RevenueCode <> ''





INSERT INTO dbo.dw_hedis_proc_list
	(	dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key, 
		claim_type,
		ihds_prov_id, 
		service_date, 
		service_from_date, 
		service_to_date, 
		ihds_member_id,
		procedure_code, 
		procedure_modifier1, 
		procedure_modifier2, 
		procedure_code_source, 
		place_of_service, 
		bill_type,
		prov_spec, 
		primary_diag_code, 
		claim_status, 
		discharge_status,
		units,
		covered_days )
SELECT	dw_hedis_claim_dtl_key	= d.dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key	= d.dw_hedis_claim_hdr_key, 
		claim_type				= isnull(c.ClaimType,''),
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd, 
		ihds_member_id			= m.ihds_member_id,
		procedure_code			= l.CPT_II, 
		procedure_modifier1		= '', 
		procedure_modifier2		= '', 
		procedure_code_source	= 'CPT_II', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType,
		prov_spec				= p.SpecialtyCode1, 
		primary_diag_code		= c.DiagnosisCode1, 
		claim_status			= c.ClaimStatus, 
		discharge_status		= DischargeStatus,
		units					= l.Units,
		covered_days			= l.CoveredDays
FROM	dbo.Claim c
	INNER HASH JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID 
	INNER HASH JOIN dbo.dw_hedis_claim_dtl d ON 
			'dbo.Claim' = d.claim_src and
			l.ClaimID = d.claim_pk1 and
			l.ClaimLineItemID = d.claim_pk2
	JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
	LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		l.CPT_II <> ''






INSERT INTO dbo.dw_hedis_proc_list
	(	dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key, 
		claim_type,
		ihds_prov_id, 
		service_date, 
		service_from_date, 
		service_to_date, 
		ihds_member_id,
		procedure_code, 
		procedure_modifier1, 
		procedure_modifier2, 
		procedure_code_source, 
		place_of_service, 
		bill_type,
		prov_spec, 
		primary_diag_code, 
		claim_status, 
		discharge_status, 
		units,
		covered_days )
SELECT	dw_hedis_claim_dtl_key	= d.dw_hedis_claim_dtl_key, 
		dw_hedis_claim_hdr_key	= d.dw_hedis_claim_hdr_key, 
		claim_type				= isnull(c.ClaimType,''),
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_date			= convert(varchar(8),c.DateServiceBegin,112), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd, 
		ihds_member_id			= m.ihds_member_id,
		procedure_code			= '', 
		procedure_modifier1		= '', 
		procedure_modifier2		= '', 
		procedure_code_source	= '', 
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType,
		prov_spec				= p.SpecialtyCode1, 
		primary_diag_code		= c.DiagnosisCode1, 
		claim_status			= c.ClaimStatus, 
		discharge_status		= DischargeStatus,
		units					= l.Units,
		covered_days			= l.CoveredDays
FROM	dbo.Claim c
	INNER HASH JOIN dbo.ClaimLineItem l ON 
			c.ClaimID = l.ClaimID 
	INNER HASH JOIN dbo.dw_hedis_claim_dtl d ON 
			'dbo.Claim' = d.claim_src and
			l.ClaimID = d.claim_pk1 and
			l.ClaimLineItemID = d.claim_pk2
	JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
	LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
--WHERE	c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID ) and
WHERE	isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') ) and
		(l.HCPCSProcedureCode = '' and l.HCPCSProcedureCode = '' and l.RevenueCode = '' and l.CPT_II = '') and
		(c.PlaceOfService <> '' or c.BillType <> '')
		


create index ix_dw_hedis_proc_list on dw_hedis_proc_list
(procedure_code)

create statistics sp_dw_hedis_proc_list on dw_hedis_proc_list
(procedure_code) with fullscan







-- Load dw_hedis_surg_proc_list
INSERT INTO dbo.dw_hedis_surg_proc_list
	(	dw_hedis_claim_hdr_key, 
		claim_type, 
		ihds_prov_id,
		service_from_date, 
		service_to_date,
		ihds_member_id, 
		surg_procedure, 
		surg_procedure_date, 
		surg_procedure_source,
		place_of_service, 
		bill_type, 
		prov_spec,
		claim_status,
		discharge_status )
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure1, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure1',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure1 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure2, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure2',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure2 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure3, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure3',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure3 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure4, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure4',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure4 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure5, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure5',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure5 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )
UNION
SELECT	dw_hedis_claim_hdr_key	= h.dw_hedis_claim_hdr_key, 
		claim_type				= c.ClaimType, 
		ihds_prov_id			= isnull(p.ihds_prov_id,0), 
		service_from_date		= c.DateServiceBegin, 
		service_to_date			= c.DateServiceEnd,
		ihds_member_id			= m.ihds_member_id, 
		surg_procedure			= c.SurgicalProcedure6, 
		surg_procedure_date		= c.DateServiceBegin, 
		surg_procedure_source	= 'SurgicalProcedure6',
		place_of_service		= c.PlaceOfService, 
		bill_type				= c.BillType, 
		prov_spec				= p.SpecialtyCode1,
		claim_status			= c.ClaimStatus,
		discharge_status		= c.DischargeStatus 
FROM	dbo.Claim c
		JOIN dbo.dw_hedis_claim_hdr h ON 
			c.ClaimID = h.claim_pk1 and
			h.claim_src = 'dbo.Claim'
		JOIN dbo.Member m ON 
			c.MemberID = m.MemberID
		LEFT JOIN dbo.Provider p ON 
			c.ihds_prov_id_servicing = p.ihds_prov_id
WHERE	c.SurgicalProcedure6 not in ('','00000') and
		--c.HedisMeasureID = ISNULL( @vcMeasureSetID, c.HedisMeasureID )
		isnull(c.HedisMeasureID,'empty') = ISNULL( @vcMeasureSetID, isnull(c.HedisMeasureID,'empty') )














GO
