SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prCreateCGFTest]

AS

UPDATE cgf.clientlist SET client = 'CGFTest'
	
UPDATE CGF.ResultsByMember SET EnrollmentGroupDesc = 'Medicaid' WHERE EnrollmentGroupDesc = 'DHP Medicaid'
UPDATE CGF.ResultsByMember SET EnrollmentGroupDesc = 'Commercial' WHERE EnrollmentGroupDesc = 'Plan A'
UPDATE dbo.ProviderMedicalGroup SET MedicalGroupName = 'Grp_' + CONVERT(Varchar(10),ProviderMedicalGroupID)

UPDATE cgf.ResultsByMember SET PopulationDesc = CASE WHEN PopulationDesc = 'Denver Health CHP' THEN 'CHP'
WHEN PopulationDesc = 'Denver Health Commercial' THEN 'Commercial'
WHEN PopulationDesc = 'Denver Health Medicaid' THEN 'Medicaid'
WHEN PopulationDesc = 'Denver Health Medicare' THEN 'Medicare'
END

UPDATE P
	SET 
	DataSource = 'CGF.Provider', 
	NameFirst = CASE WHEN p.gender = 'F' THEN f.NameFirst ELSE m.NameFirst END,
	NameLast = CASE WHEN p.gender = 'f' THEN f.Namelast ELSE m.namelast END ,
	TaxID = CASE WHEN p.gender = 'f' THEN f.ssn ELSE m.ssn ENd,
	NameShort = CASE WHEN p.gender = 'F' THEN f.NameLast + ', ' + f.NameFirst ELSE m.NameLast + ', ' + m.NameFirst END,
	ProviderFullName = CASE WHEN p.gender = 'F' THEN f.NameLast + ', ' + f.NameFirst ELSE m.NameLast + ', ' + m.NameFirst END
FROM dbo.Provider p
	INNER JOIN IMICodeStore.dbo.IMITestDataMember_Female f
		ON p.ProviderID = f.memberID
	INNER JOIN imicodestore.dbo.IMITestDataMember_male  m
		ON p.providerID = m.MemberID


SELECT 'update ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' SET ' + COLUMN_NAME + ' = ''CGFTest'''
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE column_name = 'Client'




SELECT TOP 10 * FROM IMICodeStore.dbo.test

UPDATE claim SET Client = 'CGFTest'
UPDATE claimlineitem SET Client = 'CGFTest'
UPDATE member SET Client = 'CGFTest'
UPDATE eligibility SET Client = 'CGFTest'
UPDATE provider SET Client = 'CGFTest'
UPDATE pharmacyclaim SET Client = 'CGFTest'


update dbo.MemberGroup SET Client = 'CGFTest'
update dbo.MemberProvider SET Client = 'CGFTest'
update dbo.ProviderMedicalGroup SET Client = 'CGFTest'
update dbo.Vendor SET Client = 'CGFTest'
update dbo.NonActiveEligibility SET Client = 'CGFTest'
update CGF.ResultsByMember SET Client = 'CGFTest'
update CGF.ClientList SET Client = 'CGFTest'
update dbo.AuthHeader SET Client = 'CGFTest'
update dbo.pharmacy SET Client = 'CGFTest'
update dbo.AuthDetail SET Client = 'CGFTest'
update dbo.ProviderAddress SET Client = 'CGFTest'
update dbo.MemberAddress SET Client = 'CGFTest'
update dbo.DiagnosisCodeList SET Client = 'CGFTest'
update dbo.ProcedureCodeList SET Client = 'CGFTest'
update dbo.PlaceOfServiceList SET Client = 'CGFTest'
update dbo.ReasonCodeList SET Client = 'CGFTest'
update CGF.ResultsByMember_sum SET client = 'CGFTest'
update dbo.HealthPlan SET Client = 'CGFTest'
update dbo.BrXref_MemberMonth SET Client = 'CGFTest'

UPDATE cgf.clientlist SET client = 'CGFTest'

UPDATE claim SET Client = 'CGFTest'
UPDATE claim SET Client = 'CGFTest'
UPDATE claim SET Client = 'CGFTest'
UPDATE claim SET Client = 'CGFTest'


SELECT 'update ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' SET ' + COLUMN_NAME + ' = ''CGFTest'''
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE column_name = 'Client'




	/*

UPDATE M 
SET 
		Address1 = tdf.Address1,
        Address2 = '',
        City = tdf.City,--'Knoxville' ,
        Client = 'CGFTest',
        County = 'Knox',
        CustomerMemberID = m.MemberID,
        CustomerSubscriberID = 0,
        DataSource ='TestMember',
        NameFirst = CASE WHEN gd.Gender_code = 'F' THEN tdf.NameFirst ELSE tdm.NameFirst END,--'FirstName',
        NameLast = CASE WHEN gd.Gender_code = 'F' THEN tdf.NameLast ELSE tdm.NameLast END,--LEFT(md.Last_name,3)+'_LastName'+ CONVERT(VARCHAR(10),md.Member_key),
        NameMiddleInitial = LEFT(md.Middle_init,1),
        NamePrefix = '',
        NameSuffix = '',
        Phone = tdf.phone,--'865-999-9999',
        RelationshipToSubscriber = '',
        SSN = tdf.ssn, --'987123456',
        State = tdf.State,--'TN',
        ZipCode = tdf.ZipCode, --'37920',
        Ethnicity = tdf.Ethnicity,
					--CASE WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '1' AND '5' THEN 'Unknown'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '6' AND '7' THEN 'Unknown'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '8' AND '8' THEN 'Asian'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '9' AND '9' THEN 'Hispanic'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '0' AND '0' THEN 'Unknown'
					--	END,
        InterpreterFlag = '',
        MemberLanguage = tdf.MemberLanguage,
        Race = tdf.race,
					--CASE WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '1' AND '5' THEN 'White'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '6' AND '7' THEN 'Black'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '8' AND '8' THEN 'Asian'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '9' AND '9' THEN 'Hispanic'
					--	WHEN RIGHT(RTRIM(CONVERT(VARCHAR(10),md.member_key)),1) BETWEEN '0' AND '0' THEN 'Other'
					--	END,
        MedicareNumber = tdf.MedicareNumber, --CONVERT(VARCHAR(10),8000000000 + md.member_key),
        MedicaidNumber = tdf.MedicaidNumber, --CONVERT(VARCHAR(10),7000000000 + md.member_key)
	FROM Member m
		INNER JOIN IMISQl15.IMI_IMIStaging.dbo.IMITestDataMember_Female tdf
			ON m.MemberID = tdf.RowID
		INNER JOIN IMISQl15.IMI_IMIStaging.dbo.IMITestDataMember_male tdm
			ON m.MemberID = tdm.RowID

*/

SELECT TOP 10 * FROM imisql14.DHMP_IMIStaging_PROD.dbo.Eligibility

UPDATE e 
SET Client = 'CGFTest',
	DataSource = 'CGF.Eligibility',
	BenefitPlanCode = ''
		
FROM Eligibility e
	INNER JOIN member m
		ON e.Memberid= m.MemberID

SELECT TOP 10 
		EligibilityID,
        Client,
        DataSource,
        DateEffective,
        DateRowCreated,
        DateTerminated,
        HashValue,
        HealthPlanID,
        MemberID,
        RowID,
        CoverageCDAmbulatoryFlag,
        CoverageCDDayNightFlag,
        CoverageCDInpatientFlag,
        CoverageDentalFlag,
        CoverageMHAmbulatoryFlag,
        CoverageMHDayNightFlag,
        CoverageMHInpatientFlag,
        CoveragePharmacyFlag,
        HealthPlanEmployeeFlag,
        ihds_prov_id_pcp,
        BenefitPlanCode,
        BenefitPlanDesc,
        EligRecordCreateDate,
        EligRecordCreateUser,
        EligRecordUpdateDate,
        EligRecordUpdateUser,
        TermReason,
        Relationship,
        RelationshipDesc,
        LineOfBusiness,
        CustomerPCPID,
        IPAID,
        IPADesc,
        PanelID,
        PanelDesc,
        CustomerEligibilityID,
        MemberGroupID,
        CustomerMemberGroupID,
        MedicareType,
        CustomerSubscriberSeqID,
        CopayCategory,
        LICSLevel,
        CustomerEligibilityStatus,
        HospitalPayorInsCode,
        SourceSystem,
        EnrollID,
        CustomerPlanID,
        EligibleOrigID,
        Carrerid,
        InsuredID,
        PlanDescription,
        PlanType,
        EligibleOrganizationName,
        EligibleOrganizationType,
        CarrierName,
        CarrierType,
        CarrierMemID,
        PlanID,
        InsuredMemberID,
        InsuredIHDS_Member_ID,
        RateCode,
        ProgramID,
        ProgramDescription,
        CustomerEligRatingCode,
        OrgPolicyID,
        policynum,
        ProductType
	FROM imisql14.DHMP_IMIStaging_PROD.dbo.Eligibility
GO
