SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Import].[LoadGuardianAngelConsultingData]
AS
BEGIN
	SET NOCOUNT ON;

	/*
	DROP SYNONYM Import.AdministrativeEvent;
	DROP SYNONYM Import.Member;
	DROP SYNONYM Import.MemberMeasureMetricScoring;
	DROP SYNONYM Import.MemberMeasureSample;
	DROP SYNONYM Import.Provider;
	DROP SYNONYM Import.ProviderSite;
	DROP SYNONYM Import.PursuitEvent;
	
	CREATE SYNONYM Import.AdministrativeEvent FOR Import.AdministrativeEvent_20160506;
	CREATE SYNONYM Import.Member FOR Import.Member_20160506;
	CREATE SYNONYM Import.MemberMeasureMetricScoring FOR Import.MemberMeasureMetricScoring_20160506;
	CREATE SYNONYM Import.MemberMeasureSample FOR Import.MemberMeasureSample_20160506;
	CREATE SYNONYM Import.Provider FOR Import.Provider_20160506;
	CREATE SYNONYM Import.ProviderSite FOR Import.ProviderSite_20160506;
	CREATE SYNONYM Import.PursuitEvent FOR Import.PursuitEvent_20160506;
	*/

	TRUNCATE TABLE dbo.AdministrativeEvent;
	TRUNCATE TABLE dbo.Member;
	TRUNCATE TABLE dbo.MemberMeasureMetricScoring;
	TRUNCATE TABLE dbo.MemberMeasureSample;
    TRUNCATE TABLE dbo.Providers;
	TRUNCATE TABLE dbo.ProviderSite;
	TRUNCATE TABLE dbo.PursuitEvent;

	INSERT INTO dbo.AdministrativeEvent
	        (AdministrativeEventID,
	         HEDISMeasure,
	         HEDISSubMetric,
	         CustomerMemberID,
	         CustomerProviderID,
	         ServiceDate,
	         ProcedureCode,
	         DiagnosisCode,
	         LOINC,
	         LabResult,
	         NDCCode,
	         NDCDescription,
	         CPT_IICode,
	         Data_Source
	        )
	SELECT	AdministrativeEventID,
            Measure,
            Metric,
            MemberID,
            ProviderID,
            ServiceDate,
            ProcedureCode, --New file doesn't need filtering, like below commented out section
			--REPLACE(ProcedureCode, '90681', '90680'), --Per Lorene, https://imihealth.worketc.com/Work?EntryID=6159
            DiagnosisCode,
            LOINC,
            LabResult,
            NDCCode,
            NDCDescription,
            CPT_IICode,
            [Description]
	FROM	Import.AdministrativeEvent;

	INSERT INTO dbo.Member
	        (ProductLine,
	         Product,
	         CustomerMemberID,
	         SSN,
	         NameFirst,
	         NameLast,
	         NameMiddleInitial,
	         NamePrefix,
	         NameSuffix,
	         DateOfBirth,
	         Gender,
	         Address1,
	         Address2,
	         City,
	         State,
	         ZipCode
	        )
	SELECT	ProductLine,
            Product,
            MemberID,
            SSN,
            NameFirst,
            NameLast,
            NameMiddleInitial,
            NamePrefix,
            NameSuffix,
            DateOfBirth,
            Gender,
            Address1,
            Address2,
            City,
            State,
            ZipCode
	FROM	Import.Member;
	
	WITH MetricConversion (OldMetric, NewMetric) AS
	(
		SELECT 'W15', 'W150'
		UNION
		SELECT 'W15', 'W151'
		UNION
		SELECT 'W15', 'W152'
		UNION
		SELECT 'W15', 'W153'
		UNION
		SELECT 'W15', 'W154'
		UNION
		SELECT 'W15', 'W155'
		UNION
		SELECT 'W15', 'W156'
	)
	INSERT INTO dbo.MemberMeasureMetricScoring
	        (ProductLine,
	         Product,
	         CustomerMemberID,
	         HEDISMeasure,
	         EventDate,
	         HEDISSubMetric,
	         DenominatorCount,
	         AdministrativeHitCount,
	         MedicalRecordHitCount,
	         HybridHitCount,
	         SuppIndicator,
			 ExclusionAdmin,
			 ExclusionValidDataError,
			 ExclusionPlanEmployee
	        )
	SELECT	ProductLine,
            Product,
            MemberID,
            Measure,
            KeyEventDate,
            COALESCE(MC.NewMetric, t.Metric) AS Metric,
            dbo.ConvertBit(ISNULL(NULLIF(Denominator, ''), '0')),
            dbo.ConvertBit(ISNULL(NULLIF(NumeratorCompliantAdmin, ''), '0')),
            dbo.ConvertBit(ISNULL(NULLIF(NumeratorCompliantMR, ''), '0')),
            dbo.ConvertBit(ISNULL(NULLIF(NumeratorCompliantHybrid, ''), '0')),
            dbo.ConvertBit(ISNULL(NULLIF(SupplementalIndicator, ''), '0')),
			0,
			0,
			0
	FROM	Import.MemberMeasureMetricScoring AS t
			LEFT OUTER JOIN MetricConversion AS MC
					ON MC.OldMetric = t.Metric;

	INSERT INTO dbo.MemberMeasureSample
	        (ProductLine,
	         Product,
	         CustomerMemberID,
	         HEDISMeasure,
	         EventDate,
	         SampleType,
	         SampleDrawOrder,
	         PPCPrenatalCareStartDate,
	         PPCPrenatalCareEndDate,
	         PPCPostpartumCareStartDate,
	         PPCPostpartumCareEndDate,
	         PPCEnrollmentCategory,
	         PPCLastEnrollSegStartDate,
	         PPCLastEnrollSegEndDate,
	         PPCGestationalDays,
	         DiabetesDiagnosisDate
	        )
	SELECT	ProductLine,
            Product,
            MemberID,
            Measure,
            KeyEventDate,
            'sample' AS SampleType, --Per Lorene, not receiving the whole sample, not possible to identify samples
            SampleDrawOrder,
            PPCPrenatalCareStartDate,
            PPCPrenatalCareEndDate,
            PPCPostpartumCareStartDat,
            PPCPostpartumCareEndDate,
            PPCEnrollmentCategory,
            PPCLastEnrollSegStartDate,
            PPCLastEnrollSegEndDate,
            PPCGestationalDays,
            DiabetesDiagnosisDate
	FROM	Import.MemberMeasureSample

	INSERT INTO dbo.Providers 
	        (CustomerProviderID,
	         NameEntityFullName,
	         ProviderEntityType,
	         NameFirst,
	         NameLast,
	         NameMiddleInitial,
	         NamePrefix,
	         NameSuffix,
	         NameTitle,
	         DateOfBirth,
	         Gender,
	         EIN,
	         SSN,
	         TaxID,
	         UPIN,
	         NPI,
	         MedicaidID,
	         DEANumber,
	         LicenseNumber,
	         ProviderType,
	         SpecialtyCode1,
	         SpecialtyCode2,
	         PCPFlag,
	         OBGynFlag,
	         ProviderPrescribingPrivFlag,
	         MentalHealthFlag,
	         EyeCareFlag,
	         DentistFlag,
	         NephrologistFlag,
	         CDProviderFlag,
	         NursePractFlag,
	         PhysicianAsstFlag)
	SELECT   t.ProviderID, -- CustomerProviderID - varchar(25)
	         LEFT(t.[Provider Name], 50), -- NameEntityFullName - varchar(50)
	         'Site', -- ProviderEntityType - varchar(25)
	         LEFT(t.NameFirst, 20), -- NameFirst - varchar(20)
	         LEFT(t.NameLast, 20), -- NameLast - varchar(20)
	         t.NameMiddleInitial, -- NameMiddleInitial - char(1)
	         t.NamePrefix, -- NamePrefix - varchar(10)
	         t.NameSuffix, -- NameSuffix - varchar(10)
	         t.NameTitle, -- NameTitle - varchar(10)
	         NULL, -- DateOfBirth - smalldatetime
	         '', -- Gender - char(1)
	         '', -- EIN - char(9)
	         '', -- SSN - char(9)
	         '', -- TaxID - varchar(11)
	         '', -- UPIN - varchar(20)
	         '', -- NPI - char(10)
	         '', -- MedicaidID - varchar(20)
	         '', -- DEANumber - char(10)
	         '', -- LicenseNumber - varchar(20)
	         '', -- ProviderType - varchar(100)
	         '', -- SpecialtyCode1 - varchar(100)
	         '', -- SpecialtyCode2 - varchar(100)
	         t.PCPFlag, -- PCPFlag - varchar(1)
	         t.OBGYNFlag, -- OBGynFlag - varchar(1)
	         t.ProviderPrescribingPrivFl, -- ProviderPrescribingPrivFlag - varchar(1)
	         t.MentalHealthFlag, -- MentalHealthFlag - varchar(1)
	         t.EyeCareFlag, -- EyeCareFlag - varchar(1)
	         t.DentistFlag, -- DentistFlag - varchar(1)
	         t.NephrologistFlag, -- NephrologistFlag - varchar(1)
	         t.CDProviderFlag, -- CDProviderFlag - varchar(1)
	         t.NursePractFlag, -- NursePractFlag - varchar(1)
	         t.PhysicianAsstFlag  -- PhysicianAsstFlag - varchar(1)
	FROM	Import.Provider AS t;

	INSERT INTO dbo.ProviderSite
	        (ProviderSiteID,
	         CustomerProviderID,
	         ProviderSiteName,
	         Address1,
	         Address2,
	         City,
	         State,
	         Zip,
	         Phone,
	         Fax,
	         Contact
	        )
	SELECT	 t.[Provider Site ID], -- ProviderSiteID - varchar(25)
	         t.[Provider Site ID], -- CustomerProviderID - varchar(25)
	         LEFT(t.ProviderSiteName, 75), -- ProviderSiteName - varchar(75)
	         LEFT(t.Address1, 50), -- Address1 - varchar(50)
	         LEFT(t.Address2, 50), -- Address2 - varchar(50)
	         LEFT(t.City, 50), -- City - varchar(50)
	         LEFT(t.[State], 2), -- State - varchar(2)
	         LEFT(t.Zip, 9), -- Zip - varchar(9)
	         t.Phone, -- Phone - varchar(25)
	         t.Fax, -- Fax - varchar(25)
	         t.Contact  -- Contact - varchar(50)
	FROM	Import.ProviderSite AS t;

	INSERT INTO dbo.PursuitEvent
	        (PursuitEventTrackingNumber,
	         CustomerMemberID,
	         ProductLine,
	         Product,
	         HEDISMeasure,
	         EventDate,
	         CustomerProviderID,
	         ProviderSiteID,
	         PriorityOrder,
	         PursuitCategory
	        )
	SELECT	 t.PursuitNumber, -- PursuitEventTrackingNumber - varchar(30)
	         t.MemberID, -- CustomerMemberID - varchar(20)
	         t.ProductLine, -- ProductLine - varchar(20)
	         t.Product, -- Product - varchar(20)
	         t.Measure, -- HEDISMeasure - varchar(3)
	         t.[Key Event Date], -- EventDate - datetime
	         t.ProviderID, -- CustomerProviderID - varchar(25)
	         t.ProviderSiteID, -- ProviderSiteID - varchar(25)
	         1, -- PriorityOrder - int
	         ''  -- PursuitCategory - varchar(50)
	FROM	Import.PursuitEvent AS t;

	--UPDATE dbo.Member SET SSN = RIGHT(CustomerMemberID, LEN(CustomerMemberID) - CHARINDEX('_', CustomerMemberID)); --Make the SSN the real member id for searching purposes
						
	EXEC dbo.GetRecordCounts @TableSchema = N'Import' -- nvarchar(128)
	EXEC dbo.GetRecordCounts @TableSchema = N'dbo' -- nvarchar(128)
	

END

GO
