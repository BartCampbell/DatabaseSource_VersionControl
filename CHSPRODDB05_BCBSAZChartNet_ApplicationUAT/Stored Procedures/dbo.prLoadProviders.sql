SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadProviders]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: Providers, from Client Import table: Providers
*/
--select * from Providers
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO Providers
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
         PhysicianAsstFlag
        )
        SELECT  CustomerProviderID = '',
                NameEntityFullName = '',
                ProviderEntityType = '',
                NameFirst = '',
                NameLast = '',
                NameMiddleInitial = '',
                NamePrefix = '',
                NameSuffix = '',
                NameTitle = '',
                DateOfBirth = '',
                Gender = '',
                EIN = '',
                SSN = '',
                TaxID = '',
                UPIN = '',
                NPI = '',
                MedicaidID = '',
                DEANumber = '',
                LicenseNumber = '',
                ProviderType = '',
                SpecialtyCode1 = '',
                SpecialtyCode2 = '',
                PCPFlag = '',
                OBGynFlag = '',
                ProviderPrescribingPrivFlag = '',
                MentalHealthFlag = '',
                EyeCareFlag = '',
                DentistFlag = '',
                NephrologistFlag = '',
                CDProviderFlag = '',
                NursePractFlag = '',
                PhysicianAsstFlag = ''
        UNION ALL
        SELECT  CustomerProviderID = CustomerProviderID,
                NameEntityFullName = LEFT(NameEntityFullName, 50),
                ProviderEntityType = ProviderEntityType,
                NameFirst = LEFT(NameFirst, 20),
                NameLast = LEFT(NameLast, 20),
                NameMiddleInitial = NameMiddleInitial,
                NamePrefix = NamePrefix,
                NameSuffix = NameSuffix,
                NameTitle = NameTitle,
                DateOfBirth = DateOfBirth,
                Gender = Gender,
                EIN = EIN,
                SSN = SSN,
                TaxID = TaxID,
                UPIN = UPIN,
                NPI = NPI,
                MedicaidID = MedicaidID,
                DEANumber = DEANumber,
                LicenseNumber = LicenseNumber,
                ProviderType = ProviderType,
                SpecialtyCode1 = SpecialtyCode1,
                SpecialtyCode2 = SpecialtyCode2,
                PCPFlag = PCPFlag,
                OBGynFlag = OBGynFlag,
                ProviderPrescribingPrivFlag = ProviderPrescribingPrivFlag,
                MentalHealthFlag = MentalHealthFlag,
                EyeCareFlag = EyeCareFlag,
                DentistFlag = DentistFlag,
                NephrologistFlag = NephrologistFlag,
                CDProviderFlag = CDProviderFlag,
                NursePractFlag = NursePractFlag,
                PhysicianAsstFlag = PhysicianAsstFlag
        FROM    RDSM.Providers
		WHERE	CustomerProviderID <> ''






GO
