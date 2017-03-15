SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		TP
-- Create date:	07/14/2016
-- Description:	Processes XML from 834 converted file
-- =============================================
CREATE PROCEDURE [dbo].[prProcess834_100002]
	-- Add the parameters for the stored procedure here
@XMLData XML,
@TableName VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @xml XML
SET @xml = 
(
  SELECT @XMLData
)




SELECT 
--MEMBER LEVEL DETAIL
T.X.value('(INS/INS01/text())[1]', 'varchar(50)') AS [MemberLevelDetail_ResponseCode_INS01],
T.X.value('(INS/INS02/text())[1]', 'varchar(50)') AS [MemberLevelDetail_IndividualRelationshipCode_INS02],
T.X.value('(INS/INS03/text())[1]', 'varchar(50)') AS [MemberLevelDetail_MaintTypeCode_INS03],
T.X.value('(INS/INS04/text())[1]', 'varchar(50)') AS [MemberLevelDetail_MaintReasonCode_INS04],
T.X.value('(INS/INS05/text())[1]', 'varchar(50)') AS [MemberLevelDetail_BenefitStatusCode_INS05],
T.X.value('(INS/INS06/text())[1]', 'varchar(50)') AS [MemberLevelDetail_MedicareStatusCode_INS06],
T.X.value('(INS/INS07/text())[1]', 'varchar(50)') AS [MemberLevelDetail_INS07],
T.X.value('(INS/INS08/text())[1]', 'varchar(50)') AS [MemberLevelDetail_EmploymentStatusCode_INS07],
T.X.value('(REF/REF01/text())[1]', 'varchar(50)') AS [MemberLevelDetail_RefIDQualifier1_REF01],
T.X.value('(REF/REF02/text())[1]', 'varchar(50)') AS [MemberLevelDetail_RefID1_REF02],
T.X.value('(REF/REF01/text())[2]', 'varchar(50)') AS [MemberLevelDetail_RefIDQualifier2_REF01],
T.X.value('(REF/REF02/text())[2]', 'varchar(50)') AS [MemberLevelDetail_RefID2_REF02],
T.X.value('(REF/REF01/text())[3]', 'varchar(50)') AS [MemberLevelDetail_RefIDQualifier3_REF01],
T.X.value('(REF/REF02/text())[3]', 'varchar(50)') AS [MemberLevelDetail_RefID3_REF02],
T.X.value('(DTP/DTP01/text())[1]', 'varchar(50)') AS [MemberLevelDetail_DateTimeQualifier1_DTP01],
T.X.value('(DTP/DTP02/text())[1]', 'varchar(50)') AS [MemberLevelDetail_DateTimeFormat1_DTP02],
T.X.value('(DTP/DTP03/text())[1]', 'varchar(50)') AS [MemberLevelDetail_DateTimePeriod1_DTP03],
T.X.value('(DTP/DTP01/text())[2]', 'varchar(50)') AS [MemberLevelDetail_DateTimeQualifier2_DTP01],
T.X.value('(DTP/DTP02/text())[2]', 'varchar(50)') AS [MemberLevelDetail_DateTimeFormat2_DTP02],
T.X.value('(DTP/DTP03/text())[2]', 'varchar(50)') AS [MemberLevelDetail_DateTimePeriod2_DTP03],

--MEMBERNAME
T.X.value('(Loop/NM1/NM101/text())[1]', 'varchar(50)') AS [Member_EntityIdentifierCode_NM101],
T.X.value('(Loop/NM1/NM102/text())[1]', 'varchar(50)') AS [Member_EntityTypeQualifier_NM102],
T.X.value('(Loop/NM1/NM103/text())[1]', 'varchar(50)') AS [Member_LastName_OrgName_NM103],
T.X.value('(Loop/NM1/NM104/text())[1]', 'varchar(50)') AS [Member_FirstName_NM104],
T.X.value('(Loop/NM1/NM105/text())[1]', 'varchar(50)') AS [Member_NM105],
T.X.value('(Loop/NM1/NM106/text())[1]', 'varchar(50)') AS [Member_NM106],
T.X.value('(Loop/NM1/NM107/text())[1]', 'varchar(50)') AS [Member_NM107],
T.X.value('(Loop/NM1/NM108/text())[1]', 'varchar(50)') AS [Member_IDCodeQualifier_NM108],
T.X.value('(Loop/NM1/NM109/text())[1]', 'varchar(50)') AS [Member_IDCode_NM109],
T.X.value('(Loop/PER/PER01/text())[1]', 'varchar(50)') AS [Member_ContactFunctionCode_PER01],
T.X.value('(Loop/PER/PER02/text())[1]', 'varchar(50)') AS [Member_PER02],
T.X.value('(Loop/PER/PER03/text())[1]', 'varchar(50)') AS [Member_CommunicationNumberQualifier_PER03],
T.X.value('(Loop/PER/PER04/text())[1]', 'varchar(50)') AS [Member_CommunicationNumber_PER04],
T.X.value('(Loop/N3/N301/text())[1]', 'varchar(50)') AS [Member_Address_N301],
T.X.value('(Loop/N4/N401/text())[1]', 'varchar(50)') AS [Member_CityName_N401],
T.X.value('(Loop/N4/N402/text())[1]', 'varchar(50)') AS [Member_StateProvinceCode_N402],
T.X.value('(Loop/N4/N403/text())[1]', 'varchar(50)') AS [Member_PostalCode_N403],
T.X.value('(Loop/DMG/DMG01/text())[1]', 'varchar(50)') AS [Member_DatTimePeriodFormat_DMG01],
T.X.value('(Loop/DMG/DMG02/text())[1]', 'varchar(50)') AS [Member_DOB_DMG02],
T.X.value('(Loop/DMG/DMG03/text())[1]', 'varchar(50)') AS [Member_Gender_DMG03],


--RESPONSIBLE PERSON
T.X.value('(Loop/NM1/NM101/text())[2]', 'varchar(50)') AS [ResponsiblePerson_Code_NM101],
T.X.value('(Loop/NM1/NM102/text())[2]', 'varchar(50)') AS [ResponsiblePerson_Type_NM102],


--HEALTH COVERAGE--
T.X.value('(Loop/HD/HD01/text())[1]', 'varchar(50)') AS [HealthCoverage_MaintTypeCode_HD01],
T.X.value('(Loop/HD/HD02/text())[1]', 'varchar(50)') AS [HealthCoverage_ResponsiblePersonType_HD02],
T.X.value('(Loop/HD/HD03/text())[1]', 'varchar(50)') AS [HealthCoverage_InsuranceLineCode_HD03],
T.X.value('(Loop/HD/HD04/text())[1]', 'varchar(50)') AS [HealthCoverage_ResponsiblePersonType_HD04],
T.X.value('(Loop/DTP/DTP01/text())[1]', 'varchar(50)') AS [HealthCoverage_DateTimeQualifier1_DTP01],
T.X.value('(Loop/DTP/DTP02/text())[1]', 'varchar(50)') AS [HealthCoverage_DateTimeFormat1_DTP02],
T.X.value('(Loop/DTP/DTP03/text())[1]', 'varchar(50)') AS [HealthCoverage_DateTimePeriod1_DTP03],

--PROVIDER INFORMATION
T.X.value('(Loop/Loop/LX/LX01/text())[1]', 'varchar(50)') AS [ProviderInfo_AssignedNumber_LX01],
T.X.value('(Loop/Loop/NM1/NM101/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityIdentifierCode_NM101],
T.X.value('(Loop/Loop/NM1/NM102/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityType_NM102],
T.X.value('(Loop/Loop/NM1/NM103/text())[1]', 'varchar(50)') AS [ProviderInfo_LastName_OrgName_NM103],
T.X.value('(Loop/Loop/NM1/NM104/text())[1]', 'varchar(50)') AS [ProviderInfo_FirstName_NM104],
T.X.value('(Loop/Loop/NM1/NM105/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityIdentifierCode_NM105],
T.X.value('(Loop/Loop/NM1/NM106/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityIdentifierCode_NM106],
T.X.value('(Loop/Loop/NM1/NM107/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityIdentifierCode_NM107],
T.X.value('(Loop/Loop/NM1/NM108/text())[1]', 'varchar(50)') AS [ProviderInfo_IdentificationCodeQualifier_NM108],
T.X.value('(Loop/Loop/NM1/NM109/text())[1]', 'varchar(50)') AS [ProviderInfo_IdentificationCode_NM109],
T.X.value('(Loop/Loop/NM1/NM110/text())[1]', 'varchar(50)') AS [ProviderInfo_EntityRelationshipCode_NM110]
INTO #834Temp
FROM @xml.nodes('Interchange/FunctionGroup/Transaction/Loop') AS t(x)
WHERE T.X.value('(REF/REF02/text())[3]', 'varchar(50)') IS NOT NULL
ORDER BY T.X.value('(REF/REF02/text())[1]', 'varchar(50)')

DECLARE @SqlSelect NVARCHAR(500)

SET @SqlSelect = 'IF OBJECT_ID(''dbo.'+ @TableName+''', ''U'') IS NOT NULL DROP TABLE dbo.'+ @TableName+';'

EXECUTE sp_executesql @SqlSelect

SET @SqlSelect = 'SELECT * INTO dbo.'+ @TableName+' FROM #834Temp'

EXECUTE sp_executesql @SqlSelect
END

GO
