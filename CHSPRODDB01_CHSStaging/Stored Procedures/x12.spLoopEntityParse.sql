SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse all Entity type loops and their repeated segments: Ref
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000002175') -- '000000001'
		AND LoopID = '2010BA'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopEntity
	TRUNCATE TABLE x12.SegPER
	TRUNCATE TABLE x12.SegDTP
	TRUNCATE TABLE x12.SegREF

	EXEC x12.spLoopEntityParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

		SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000000003') -- AND LoopID = '2330B'
		SELECT * FROM x12.LoopEntity WHERE Entity_TransactionControlNumber IN ('000000003') ORDER BY Entity_LoopID
		SELECT * FROM x12.SegPER WHERE PER_TransactionControlNumber IN ('000000003') ORDER BY PER_LoopID
		SELECT * FROM x12.SegDTP WHERE DTP_TransactionControlNumber IN ('000000003') ORDER BY DTP_LoopID
		SELECT * FROM x12.SegREF WHERE REF_TransactionControlNumber IN ('000000003') ORDER BY REF_LoopID
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopEntityParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @X12RefEntityLoopID INT
		,@LoopID VARCHAR(50)
	 
	SELECT @X12RefEntityLoopID = MIN(X12RefEntityLoopID) FROM x12.RefEntityLoop;

	WHILE @X12RefEntityLoopID IS NOT NULL
	BEGIN
		SELECT @LoopID = LoopID FROM x12.RefEntityLoop WHERE X12RefEntityLoopID = @X12RefEntityLoopID ;
		
		IF @Debug >= 1 PRINT '-- LoopID: ' + @LoopID;

		INSERT INTO x12.LoopEntity (
			Entity_RowID
			,Entity_RowIDParent
			,Entity_CentauriClientID
			,Entity_FileLogID
			,Entity_TransactionImplementationConventionReference
			,Entity_TransactionControlNumber
			,Entity_LoopID

			,Entity_EntityIdentifierCode_NM101
			,Entity_EntityTypeQualifier_NM102
			,Entity_NameLastOrEntityName_NM103
			,Entity_FirstName_NM104
			,Entity_MiddleName_NM105
			,Entity_NamePrefix_NM106
			,Entity_NameSuffix_NM107
			,Entity_IdentificationCodeQualifier_NM108
			,Entity_IndentificationCode_NM109
			,Entity_EntityRelationshipCode_NM110
			,Entity_EntityIdentifierCode_NM111
			,Entity_NameLastOrOrganizaionName_NM112
			,Entity_AddressInformation_N301
			,Entity_AddressInformation_N302
			,Entity_CityName_N401
			,Entity_StateOrProvinceCode_N402
			,Entity_PostalCode_N403
			,Entity_CountryCode_N404
			,Entity_LocationQualifier_N405
			,Entity_LocationIdentifier_N406
			,Entity_CountrySubdivisionCode_N407
			,Entity_DateTimePeriodFormatQualifier_DMG01
			,Entity_DateTimePeriod_DMG02
			,Entity_GenderCode_DMG03
			,Entity_MaritalStatusCode_DMG04
			,Entity_CompositeRaceOrEthnicityInformation_DMG05
			,Entity_CitizenshipStatusCode_DMG06
			,Entity_CountryCode_DMG07
			,Entity_BasisofVerificationCode_DMG08
			,Entity_Quantity_DMG09
			,Entity_CodeListQualifierCode_DMG10
			,Entity_IndustryCode_DMG11
			,Entity_ProviderCode_PRV01
			,Entity_ReferenceIdentificationQualifier_PRV02
			,Entity_ReferenceIdentification_PRV03
			,Entity_StateOrProvinceCode_PRV04
			,Entity_ProviderSpecialtyInformation_PRV05
			,Entity_ProviderOrganizationCode_PRV06
			)
		SELECT
			x.RowID
			,x.RowIDParent
			,x.CentauriClientID
			,x.FileLogID
			,x.TransactionImplementationConventionReference
			,x.TransactionControlNumber
			,x.LoopID
			-- NM1 - NAME
			,h.b.value('(NM1/NM101/text())[1]', 'varchar(3)') AS 'Entity_EntityIdentifierCode_NM101'
			,h.b.value('(NM1/NM102/text())[1]', 'varchar(1)') AS 'Entity_EntityTypeQualifier_NM102'
			,h.b.value('(NM1/NM103/text())[1]', 'varchar(60)') AS 'Entity_NameLastOrEntityName_NM103'
			,h.b.value('(NM1/NM104/text())[1]', 'varchar(35)') AS 'Entity_FirstName_NM104'
			,h.b.value('(NM1/NM105/text())[1]', 'varchar(25)') AS 'Entity_MiddleName_NM105'
			,h.b.value('(NM1/NM106/text())[1]', 'varchar(10)') AS 'Entity_NamePrefix_NM106'
			,h.b.value('(NM1/NM107/text())[1]', 'varchar(10)') AS 'Entity_NameSuffix_NM107'
			,h.b.value('(NM1/NM108/text())[1]', 'varchar(2)') AS 'Entity_IdentificationCodeQualifier_NM108'
			,h.b.value('(NM1/NM109/text())[1]', 'varchar(80)') AS 'Entity_IndentificationCode_NM109'
			,h.b.value('(NM1/NM110/text())[1]', 'varchar(2)') AS 'Entity_EntityRelationshipCode_NM110'
			,h.b.value('(NM1/NM111/text())[1]', 'varchar(3)') AS 'Entity_EntityIdentifierCode_NM111'
			,h.b.value('(NM1/NM112/text())[1]', 'varchar(60)') AS 'Entity_NameLastOrOrganizaionName_NM112'
			-- N3 - ADDRESS
			,h.b.value('(N3/N301/text())[1]', 'varchar(55)') AS 'Entity_AddressInformation_N301'
			,h.b.value('(N3/N302/text())[1]', 'varchar(55)') AS 'Entity_AddressInformation_N302'
			-- N4 - CITY, STATE, ZIP CODE
			,h.b.value('(N4/N401/text())[1]', 'varchar(30)') AS 'Entity_CityName_N401'
			,h.b.value('(N4/N402/text())[1]', 'varchar(2)') AS 'Entity_StateOrProvinceCode_N402'
			,h.b.value('(N4/N403/text())[1]', 'varchar(15)') AS 'Entity_PostalCode_N403'
			,h.b.value('(N4/N404/text())[1]', 'varchar(3)') AS 'Entity_CountryCode_N404'
			,h.b.value('(N4/N405/text())[1]', 'varchar(2)') AS 'Entity_LocationQualifier_N405'
			,h.b.value('(N4/N406/text())[1]', 'varchar(30)') AS 'Entity_LocationIdentifier_N406'
			,h.b.value('(N4/N407/text())[1]', 'varchar(3)') AS 'Entity_CountrySubdivisionCode_N407'
			-- DMG - DEMOGRAPHIC INFORMATION
			,h.b.value('(DMG/DMG01/text())[1]', 'varchar(3)') AS 'Entity_DateTimePeriodFormatQualifier_DMG01'
			,h.b.value('(DMG/DMG02/text())[1]', 'varchar(35)') AS 'Entity_DateTimePeriod_DMG02'
			,h.b.value('(DMG/DMG03/text())[1]', 'varchar(1)') AS 'Entity_GenderCode_DMG03'
			,h.b.value('(DMG/DMG04/text())[1]', 'varchar(1)') AS 'Entity_MaritalStatusCode_DMG04'
			,h.b.value('(DMG/DMG05/text())[1]', 'varchar(1)') AS 'Entity_CompositeRaceOrEthnicityInformation_DMG05'
			,h.b.value('(DMG/DMG06/text())[1]', 'varchar(2)') AS 'Entity_CitizenshipStatusCode_DMG06'
			,h.b.value('(DMG/DMG07/text())[1]', 'varchar(3)') AS 'Entity_CountryCode_DMG07'
			,h.b.value('(DMG/DMG08/text())[1]', 'varchar(2)') AS 'Entity_BasisofVerificationCode_DMG08'
			,h.b.value('(DMG/DMG09/text())[1]', 'varchar(15)') AS 'Entity_Quantity_DMG09'
			,h.b.value('(DMG/DMG10/text())[1]', 'varchar(3)') AS 'Entity_CodeListQualifierCode_DMG10'
			,h.b.value('(DMG/DMG11/text())[1]', 'varchar(30)') AS 'Entity_IndustryCode_DMG11'
			-- PRV - PROVIDER SPECIALTY INFORMATION
			,h.b.value('(PRV/PRV01/text())[1]', 'varchar(3)') AS 'Entity_ProviderCode_PRV01'
			,h.b.value('(PRV/PRV02/text())[1]', 'varchar(3)') AS 'Entity_ReferenceIdentificationQualifier_PRV02'
			,h.b.value('(PRV/PRV03/text())[1]', 'varchar(50)') AS 'Entity_ReferenceIdentification_PRV03'
			,h.b.value('(PRV/PRV04/text())[1]', 'varchar(2)') AS 'Entity_StateOrProvinceCode_PRV04'
			,h.b.value('(PRV/PRV05/text())[1]', 'varchar(1)') AS 'Entity_ProviderSpecialtyInformation_PRV05'
			,h.b.value('(PRV/PRV06/text())[1]', 'varchar(3)') AS 'Entity_ProviderOrganizationCode_PRV06'
		FROM 
			x12.shred x
		OUTER APPLY 
			x.LoopXML.nodes('Loop') AS h(b)
		WHERE 1=1
			AND x.FileLogID = @FileLogID
			AND x.LoopID = @LoopID
			-- Test Only Below
				AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
				--ORDER BY x.FileLogID, x.TransactionControlNumber

		-- PER

		INSERT INTO x12.SegPER (
			PER_RowID
			,PER_RowIDParent
			,PER_CentauriClientID
			,PER_FileLogID
			,PER_TransactionImplementationConventionReference
			,PER_TransactionControlNumber
			,PER_LoopID
			,PER_ContactFunctionCode_PER01
			,PER_Name_PER02
			,PER_CommunicationNumberQualifier_PER03
			,PER_CommunicationNumber_PER04
			,PER_CommunicationNumberQualifier_PER05
			,PER_CommunicationNumber_PER06
			,PER_CommunicationNumberQualifier_PER07
			,PER_CommunicationNumber_PER08
			,PER_ContactInquiryReference_PER09
			)
		SELECT
			x.RowID
			,x.RowIDParent
			,x.CentauriClientID
			,x.FileLogID
			,x.TransactionImplementationConventionReference
			,x.TransactionControlNumber
			,x.LoopID		
			-- PER - SUBMITTER EDI CONTACT INFORMATION
			,h.b.value('(PER01/text())[1]', 'varchar(2)') AS 'PER_ContactFunctionCode_PER01'
			,h.b.value('(PER02/text())[1]', 'varchar(60)') AS 'PER_Name_PER02'
			,h.b.value('(PER03/text())[1]', 'varchar(2)') AS 'PER_CommunicationNumberQualifier_PER03'
			,h.b.value('(PER04/text())[1]', 'varchar(256)') AS 'PER_CommunicationNumber_PER04'
			,h.b.value('(PER05/text())[1]', 'varchar(2)') AS 'PER_CommunicationNumberQualifier_PER05'
			,h.b.value('(PER06/text())[1]', 'varchar(256)') AS 'PER_CommunicationNumber_PER06'
			,h.b.value('(PER07/text())[1]', 'varchar(2)') AS 'PER_CommunicationNumberQualifier_PER07'
			,h.b.value('(PER08/text())[1]', 'varchar(256)') AS 'PER_CommunicationNumber_PER08'
			,h.b.value('(PER09/text())[1]', 'varchar(20)') AS 'PER_ContactInquiryReference_PER09'
		FROM 
			x12.shred x
		CROSS APPLY 
			x.LoopXML.nodes('Loop/PER') AS h(b)
		WHERE 1=1
			AND x.FileLogID = @FileLogID
			AND x.LoopID = @LoopID
			-- Test Only Below
				AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
				--ORDER BY x.FileLogID, x.TransactionControlNumber

		-- DTP

		INSERT INTO x12.SegDTP (
			DTP_RowID
			,DTP_RowIDParent
			,DTP_CentauriClientID
			,DTP_FileLogID
			,DTP_TransactionImplementationConventionReference
			,DTP_TransactionControlNumber
			,DTP_LoopID

			,DTP_DateTimeQualifier_DTP01
			,DTP_DateTimePeriodFormatQualifier_DTP02
			,DTP_DateTimePeriod_DTP03
			)
		SELECT
			x.RowID
			,x.RowIDParent
			,x.CentauriClientID
			,x.FileLogID
			,x.TransactionImplementationConventionReference
			,x.TransactionControlNumber
			,x.LoopID		

			,h.b.value('(DTP01/text())[1]', 'varchar(50)') AS DTP_DateTimeQualifier_DTP01
			,h.b.value('(DTP02/text())[1]', 'varchar(50)') AS DTP_DateTimePeriodFormatQualifier_DTP02
			,h.b.value('(DTP03/text())[1]', 'varchar(50)') AS DTP_DateTimePeriod_DTP03
		FROM 
			x12.shred x
		CROSS APPLY 
			x.LoopXML.nodes('Loop/DTP') AS h(b)
		WHERE 1=1
			AND x.FileLogID = @FileLogID
			AND x.LoopID = @LoopID
			-- Test Only Below
				AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
				--ORDER BY x.FileLogID, x.TransactionControlNumber

		-- REF

		INSERT INTO x12.SegREF (
			REF_RowID
			,REF_RowIDParent
			,REF_CentauriClientID
			,REF_FileLogID
			,REF_TransactionImplementationConventionReference
			,REF_TransactionControlNumber
			,REF_LoopID

			,REF_ReferenceIdentificationQualifier_REF01
			,REF_ReferenceIdentification_REF02
			,REF_Description_REF03
			,REF_ReferenceIdentifier_REF04
			)
		SELECT
			x.RowID
			,x.RowIDParent
			,x.CentauriClientID
			,x.FileLogID
			,x.TransactionImplementationConventionReference
			,x.TransactionControlNumber
			,x.LoopID		

			,h.b.value('(REF01/text())[1]', 'varchar(3)') AS 'REF_ReferenceIdentificationQualifier_REF01'
			,h.b.value('(REF02/text())[1]', 'varchar(50)') AS 'REF_ReferenceIdentification_REF02'
			,h.b.value('(REF03/text())[1]', 'varchar(80)') AS 'REF_Description_REF03'
			,h.b.value('(REF04/text())[1]', 'varchar(1)') AS 'REF_ReferenceIdentifier_REF04'
		FROM 
			x12.shred x
		CROSS APPLY 
			x.LoopXML.nodes('Loop/REF') AS h(b)
		WHERE 1=1
			AND x.FileLogID = @FileLogID
			AND x.LoopID = @LoopID
			-- Test Only Below
				AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
				--ORDER BY x.FileLogID, x.TransactionControlNumber

		SELECT @X12RefEntityLoopID = MIN(X12RefEntityLoopID) FROM x12.RefEntityLoop WHERE X12RefEntityLoopID > @X12RefEntityLoopID

	END -- Loop from x12.RefEntityLoop

END -- Procedure
GO
