SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Import].[LoadGuardianAngelConsultingData]
AS
BEGIN
	SET NOCOUNT ON;

	/*
	DROP SYNONYM Import.Provider;
	DROP SYNONYM Import.ProviderSite;
	DROP SYNONYM Import.PursuitEvent;

	CREATE SYNONYM Import.Provider FOR Import.Provider_20170221;
	CREATE SYNONYM Import.ProviderSite FOR Import.ProviderSite_20170221;
	CREATE SYNONYM Import.PursuitEvent FOR Import.PursuitEvent_20170221V2;
	*/

    TRUNCATE TABLE dbo.Providers;
	TRUNCATE TABLE dbo.ProviderSite;
	TRUNCATE TABLE dbo.PursuitEvent;

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

	SELECT * FROM dbo.PursuitEvent 

	--UPDATE dbo.Member SET SSN = RIGHT(CustomerMemberID, LEN(CustomerMemberID) - CHARINDEX('_', CustomerMemberID)); --Make the SSN the real member id for searching purposes
	--UPDATE dbo.PursuitEvent SET Product = 'P1' WHERE Product IN ('PIC','PCHP');

	--UPDATE M
	--SET		M.NamePrefix = t.Product,
	--		M.NameSuffix = t.Product,
	--		M.SSN = t.Product
	--		SELECT m.NameLast,t.NameLast,m.SSN,t.Product,
	--FROM	dbo.Member AS M
	--		LEFT OUTER JOIN Import.Member_20170221 AS t
	--				ON M.CustomerMemberID = t.MemberID;
						

INSERT INTO dbo.MemberMeasureMetricScoring
        ( ProductLine ,
          Product ,
          CustomerMemberID ,
          HEDISMeasure ,
          EventDate ,
          HEDISSubMetric ,
          DenominatorCount ,
          AdministrativeHitCount ,
          MedicalRecordHitCount ,
          HybridHitCount ,
          SuppIndicator ,
          ExclusionAdmin ,
          ExclusionValidDataError ,
          ExclusionPlanEmployee
        )
SELECT [ProductLine]
      ,[Product]
      ,[CustomerMemberID]
      ,[HEDISMeasure]
      ,[EventDate]
      ,[HEDISSubMetric]
      ,[DenominatorCount]
      ,[AdministrativeHitCount]
      ,[MedicalRecordHitCount]
      ,[HybridHitCount]
      ,[SuppIndicator]
      ,[ExclusionAdmin]
      ,[ExclusionValidDataError]
      ,[ExclusionPlanEmployee]
  FROM [Import].[MemberMeasureMetricScoring_Append_20170221]

  INSERT INTO dbo.MemberMeasureSample
          ( ProductLine ,
            Product ,
            CustomerMemberID ,
            HEDISMeasure ,
            EventDate ,
            SampleType ,
            SampleDrawOrder ,
            PPCPrenatalCareStartDate ,
            PPCPrenatalCareEndDate ,
            PPCPostpartumCareStartDate ,
            PPCPostpartumCareEndDate ,
            PPCEnrollmentCategory ,
            PPCLastEnrollSegStartDate ,
            PPCLastEnrollSegEndDate ,
            PPCGestationalDays ,
            DiabetesDiagnosisDate
          )
SELECT [ProductLine]
      ,[Product]
      ,[CustomerMemberID]
      ,[HEDISMeasure]
      ,[EventDate]
      ,[SampleType]
      ,[SampleDrawOrder]
      ,[PPCPrenatalCareStartDate]
      ,[PPCPrenatalCareEndDate]
      ,[PPCPostpartumCareStartDate]
      ,[PPCPostpartumCareEndDate]
      ,[PPCEnrollmentCategory]
      ,[PPCLastEnrollSegStartDate]
      ,[PPCLastEnrollSegEndDate]
      ,[PPCGestationalDays]
      ,[DiabetesDiagnosisDate]
  FROM [Import].[MemberMeasureSample_Append_20170221]


  

--  TRUNCATE TABLE dbo.Member

--  INSERT INTO dbo.Member
--          ( ProductLine ,
--            Product ,
--            CustomerMemberID ,
--            SSN ,
--            NameFirst ,
--            NameLast ,
--            NameMiddleInitial ,
--            NamePrefix ,
--            NameSuffix ,
--            DateOfBirth ,
--            Gender ,
--            Address1 ,
--            Address2 ,
--            City ,
--            State ,
--            ZipCode 
--          )  
--SELECT [ProductLine]
--      ,CASE WHEN [Product]='MNCM' THEN Product ELSE 'P1'END
--      ,[MemberID]
--      ,[SSN]
--      ,[NameFirst]
--      ,[NameLast]
--      ,[NameMiddleInitial]
--      ,[NamePrefix]
--      ,[NameSuffix]
--      ,[DateOfBirth]
--      ,[Gender]
--      ,[Address1]
--      ,[Address2]
--      ,[City]
--      ,[State]
--      ,[ZipCode]
--  FROM [Import].[Member_20170221]

INSERT INTO dbo.MemberAdds
        ( ProductLine ,
          Product ,
          CustomerMemberID ,
          SSN ,
          NameFirst ,
          NameLast ,
          NameMiddleInitial ,
          NamePrefix ,
          NameSuffix ,
          DateOfBirth ,
          Gender ,
          Address1 ,
          Address2 ,
          City ,
          State ,
          ZipCode        
        )
SELECT [ProductLine]
      ,[Product]
      ,[CustomerMemberID]
      ,[SSN]
      ,[NameFirst]
      ,[NameLast]
      ,[NameMiddleInitial]
      ,[NamePrefix]
      ,[NameSuffix]
      ,[DateOfBirth]
      ,[Gender]
      ,[Address1]
      ,[Address2]
      ,[City]
      ,[State]
      ,[ZipCode]
  FROM [Import].[Member_Append_20170221]

  TRUNCATE TABLE dbo.AdministrativeEvent

  INSERT INTO dbo.AdministrativeEvent
          ( AdministrativeEventID ,
            HEDISMeasure ,
            HEDISSubMetric ,
            CustomerMemberID ,
            CustomerProviderID ,
            ServiceDate ,
            ProcedureCode ,
            DiagnosisCode ,
            LOINC ,
            LabResult ,
            NDCCode ,
            NDCDescription ,
            CPT_IICode ,
            Data_Source
          )
SELECT [AdministrativeEventID]
      ,[HEDISMeasure]
      ,[HEDISSubMetric]
      ,[CustomerMemberID]
      ,[CustomerProviderID]
      ,[ServiceDate]
      ,[ProcedureCode]
      ,[DiagnosisCode]
      ,[LOINC]
      ,[LabResult]
      ,[NDCCode]
      ,[NDCDescription]
      ,[CPT_IICode]
      ,[Data_Source]
  FROM [Import].[AdministrativeEvent_20170221]

  TRUNCATE TABLE dbo.Member

  INSERT INTO dbo.Member
          ( ProductLine ,
            Product ,
            CustomerMemberID ,
            SSN ,
            NameFirst ,
            NameLast ,
            NameMiddleInitial ,
            NamePrefix ,
            NameSuffix ,
            DateOfBirth ,
            Gender ,
            Address1 ,
            Address2 ,
            City ,
            State ,
            ZipCode ,
            Race ,
            Ethnicity ,
            MemberLanguage ,
            InterpreterFlag ,
            SecondaryRefID
          )

SELECT [ProductLine]
      ,[Product]
      ,[CustomerMemberID]
      ,[SSN]
      ,[NameFirst]
      ,[NameLast]
      ,[NameMiddleInitial]
      ,[NamePrefix]
      ,[NameSuffix]
      ,[DateOfBirth]
      ,[Gender]
      ,[Address1]
      ,[Address2]
      ,[City]
      ,[State]
      ,[ZipCode]
      ,[Race]
      ,[Ethnicity]
      ,[MemberLanguage]
      ,[InterpreterFlag]
      ,[SecondaryRefID]
  FROM [Import].[Member_20170221v2]


 
  INSERT INTO dbo.Member
          ( ProductLine ,
            Product ,
            CustomerMemberID ,
            SSN ,
            NameFirst ,
            NameLast ,
            NameMiddleInitial ,
            NamePrefix ,
            NameSuffix ,
            DateOfBirth ,
            Gender ,
            Address1 ,
            Address2 ,
            City ,
            State ,
            ZipCode
          )
SELECT [ProductLine]
      ,[Product]
      ,[CustomerMemberID]
      ,[SSN]
      ,[NameFirst]
      ,[NameLast]
      ,[NameMiddleInitial]
      ,[NamePrefix]
      ,[NameSuffix]
      ,[DateOfBirth]
      ,[Gender]
      ,[Address1]
      ,[Address2]
      ,[City]
      ,[State]
      ,[ZipCode]
  FROM [Import].[Member_Append_20170221]
END

GO
