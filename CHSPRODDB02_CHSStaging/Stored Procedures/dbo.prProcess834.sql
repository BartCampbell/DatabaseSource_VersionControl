SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 2/11/2016
-- Description:	Processes XML from 834 converted file
-- =============================================
CREATE PROCEDURE [dbo].[prProcess834]
	-- Add the parameters for the stored procedure here
@XMLData XML,
@TableName varchar(100)
AS
BEGIN


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--    -- Insert statements for procedure here
	DECLARE @xml XML
SET @xml = 
(
  SELECT @XMLData
)

select 
--FILE LEVEL DETAIL
G.X.value('(GS/GS02/text())[1]', 'varchar(50)') as [FileLevelDetail_SenderID_GS02],
G.X.value('(GS/GS03/text())[1]', 'varchar(50)') as [FileLevelDetail_ReceiverID_GS03],
G.X.value('(GS/GS04/text())[1]', 'varchar(50)') as [FileLevelDetail_CreateDate_GS04],
G.X.value('(GS/GS05/text())[1]', 'varchar(50)') as [FileLevelDetail_CreateTime_GS05],
G.X.value('(GS/GS08/text())[1]', 'varchar(50)') as [FileLevelDetail_FileVersion_GS08],

--PLAN LEVEL DETAIL
T.X.value('(Loop/N1/N102/text())[1]', 'varchar(50)') as [PlanLevelDetail_PlanSplonsor_N102],
T.X.value('(Loop/N1/N104/text())[1]', 'varchar(50)') as [PlanLevelDetail_PlanSponsorTIN_N104],
T.X.value('(Loop/N1/N102/text())[2]', 'varchar(50)') as [PlanLevelDetail_Payer_N102],
T.X.value('(Loop/N1/N104/text())[2]', 'varchar(50)') as [PlanLevelDetail_PayerTIN_N104],

--MEMBER LEVEL DETAIL
L.X.value('(INS/INS01/text())[1]', 'varchar(50)') as [MemberLevelDetail_ResponseCode_INS01],
L.X.value('(INS/INS02/text())[1]', 'varchar(50)') as [MemberLevelDetail_IndividualRelationshipCode_INS02],
L.X.value('(INS/INS03/text())[1]', 'varchar(50)') as [MemberLevelDetail_MaintTypeCode_INS03],
L.X.value('(INS/INS04/text())[1]', 'varchar(50)') as [MemberLevelDetail_MaintReasonCode_INS04],
L.X.value('(INS/INS05/text())[1]', 'varchar(50)') as [MemberLevelDetail_BenefitStatusCode_INS05],
L.X.value('(INS/INS06/text())[1]', 'varchar(50)') as [MemberLevelDetail_MedicareStatusCode_INS06],
L.X.value('(INS/INS07/text())[1]', 'varchar(50)') as [MemberLevelDetail_INS07],
L.X.value('(INS/INS08/text())[1]', 'varchar(50)') as [MemberLevelDetail_EmploymentStatusCode_INS07],
L.X.value('(REF/REF01/text())[1]', 'varchar(50)') as [MemberLevelDetail_RefIDQualifier1_REF01],
L.X.value('(REF/REF02/text())[1]', 'varchar(50)') as [MemberLevelDetail_RefID1_REF02],
L.X.value('(REF/REF01/text())[2]', 'varchar(50)') as [MemberLevelDetail_RefIDQualifier2_REF01],
L.X.value('(REF/REF02/text())[2]', 'varchar(50)') as [MemberLevelDetail_RefID2_REF02],
L.X.value('(REF/REF01/text())[3]', 'varchar(50)') as [MemberLevelDetail_RefIDQualifier3_REF01],
L.X.value('(REF/REF02/text())[3]', 'varchar(50)') as [MemberLevelDetail_RefID3_REF02],
L.X.value('(DTP/DTP01/text())[1]', 'varchar(50)') as [MemberLevelDetail_DateTimeQualifier1_DTP01],
L.X.value('(DTP/DTP02/text())[1]', 'varchar(50)') as [MemberLevelDetail_DateTimeFormat1_DTP02],
L.X.value('(DTP/DTP03/text())[1]', 'varchar(50)') as [MemberLevelDetail_DateTimePeriod1_DTP03],
L.X.value('(DTP/DTP01/text())[2]', 'varchar(50)') as [MemberLevelDetail_DateTimeQualifier2_DTP01],
L.X.value('(DTP/DTP02/text())[2]', 'varchar(50)') as [MemberLevelDetail_DateTimeFormat2_DTP02],
L.X.value('(DTP/DTP03/text())[2]', 'varchar(50)') as [MemberLevelDetail_DateTimePeriod2_DTP03],

--MEMBERNAME
L.X.value('(Loop/NM1/NM101/text())[1]', 'varchar(50)') as [Member_EntityIdentifierCode_NM101],
L.X.value('(Loop/NM1/NM102/text())[1]', 'varchar(50)') as [Member_EntityTypeQualifier_NM102],
L.X.value('(Loop/NM1/NM103/text())[1]', 'varchar(50)') as [Member_LastName_OrgName_NM103],
L.X.value('(Loop/NM1/NM104/text())[1]', 'varchar(50)') as [Member_FirstName_NM104],
L.X.value('(Loop/NM1/NM105/text())[1]', 'varchar(50)') as [Member_NM105],
L.X.value('(Loop/NM1/NM106/text())[1]', 'varchar(50)') as [Member_NM106],
L.X.value('(Loop/NM1/NM107/text())[1]', 'varchar(50)') as [Member_NM107],
L.X.value('(Loop/NM1/NM108/text())[1]', 'varchar(50)') as [Member_IDCodeQualifier_NM108],
L.X.value('(Loop/NM1/NM109/text())[1]', 'varchar(50)') as [Member_IDCode_NM109],
L.X.value('(Loop/PER/PER01/text())[1]', 'varchar(50)') as [Member_ContactFunctionCode_PER01],
L.X.value('(Loop/PER/PER02/text())[1]', 'varchar(50)') as [Member_PER02],
L.X.value('(Loop/PER/PER03/text())[1]', 'varchar(50)') as [Member_CommunicationNumberQualifier_PER03],
L.X.value('(Loop/PER/PER04/text())[1]', 'varchar(50)') as [Member_CommunicationNumber_PER04],
L.X.value('(Loop/PER/PER05/text())[1]', 'varchar(50)') as [Member_CommunicationNumberQualifier_PER05],
L.X.value('(Loop/PER/PER06/text())[1]', 'varchar(50)') as [Member_CommunicationNumber_PER06],
L.X.value('(Loop/PER/PER07/text())[1]', 'varchar(50)') as [Member_CommunicationNumberQualifier_PER07],
L.X.value('(Loop/PER/PER08/text())[1]', 'varchar(50)') as [Member_CommunicationNumber_PER08],
L.X.value('(Loop/N3/N301/text())[1]', 'varchar(50)') as [Member_Address_N301],
L.X.value('(Loop/N4/N401/text())[1]', 'varchar(50)') as [Member_CityName_N401],
L.X.value('(Loop/N4/N402/text())[1]', 'varchar(50)') as [Member_StateProvinceCode_N402],
L.X.value('(Loop/N4/N403/text())[1]', 'varchar(50)') as [Member_PostalCode_N403],
L.X.value('(Loop/DMG/DMG01/text())[1]', 'varchar(50)') as [Member_DatTimePeriodFormat_DMG01],
L.X.value('(Loop/DMG/DMG02/text())[1]', 'varchar(50)') as [Member_DOB_DMG02],
L.X.value('(Loop/DMG/DMG03/text())[1]', 'varchar(50)') as [Member_Gender_DMG03],


--RESPONSIBLE PERSON
L.X.value('(Loop/NM1/NM101/text())[2]', 'varchar(50)') as [ResponsiblePerson_Code_NM101],
L.X.value('(Loop/NM1/NM102/text())[2]', 'varchar(50)') as [ResponsiblePerson_Type_NM102],


--HEALTH COVERAGE--
L.X.value('(Loop/HD/HD01/text())[1]', 'varchar(50)') as [HealthCoverage_MaintTypeCode_HD01],
L.X.value('(Loop/HD/HD02/text())[1]', 'varchar(50)') as [HealthCoverage_ResponsiblePersonType_HD02],
L.X.value('(Loop/HD/HD03/text())[1]', 'varchar(50)') as [HealthCoverage_InsuranceLineCode_HD03],
L.X.value('(Loop/HD/HD04/text())[1]', 'varchar(50)') as [HealthCoverage_ResponsiblePersonType_HD04],
L.X.value('(Loop/DTP/DTP01/text())[1]', 'varchar(50)') as [HealthCoverage_DateTimeQualifier1_DTP01],
L.X.value('(Loop/DTP/DTP02/text())[1]', 'varchar(50)') as [HealthCoverage_DateTimeFormat1_DTP02],
L.X.value('(Loop/DTP/DTP03/text())[1]', 'varchar(50)') as [HealthCoverage_DateTimePeriod1_DTP03],

--PROVIDER INFORMATION
L.X.value('(Loop/Loop/LX/LX01/text())[1]', 'varchar(50)') as [ProviderInfo_AssignedNumber_LX01],
L.X.value('(Loop/Loop/NM1/NM101/text())[1]', 'varchar(50)') as [ProviderInfo_EntityIdentifierCode_NM101],
L.X.value('(Loop/Loop/NM1/NM102/text())[1]', 'varchar(50)') as [ProviderInfo_EntityType_NM102],
L.X.value('(Loop/Loop/NM1/NM103/text())[1]', 'varchar(50)') as [ProviderInfo_LastName_OrgName_NM103],
L.X.value('(Loop/Loop/NM1/NM104/text())[1]', 'varchar(50)') as [ProviderInfo_FirstName_NM104],
L.X.value('(Loop/Loop/NM1/NM105/text())[1]', 'varchar(50)') as [ProviderInfo_EntityIdentifierCode_NM105],
L.X.value('(Loop/Loop/NM1/NM106/text())[1]', 'varchar(50)') as [ProviderInfo_EntityIdentifierCode_NM106],
L.X.value('(Loop/Loop/NM1/NM107/text())[1]', 'varchar(50)') as [ProviderInfo_EntityIdentifierCode_NM107],
L.X.value('(Loop/Loop/NM1/NM108/text())[1]', 'varchar(50)') as [ProviderInfo_IdentificationCodeQualifier_NM108],
L.X.value('(Loop/Loop/NM1/NM109/text())[1]', 'varchar(50)') as [ProviderInfo_IdentificationCode_NM109],
L.X.value('(Loop/Loop/NM1/NM110/text())[1]', 'varchar(50)') as [ProviderInfo_EntityRelationshipCode_NM110]
INTO #834Temp
--from @xml.nodes('Interchange/FunctionGroup/Transaction/Loop') as t(x)
from 
    @xml.nodes('Interchange/FunctionGroup') as g(x)
    CROSS APPLY g.x.nodes('Transaction') as t(x)
    CROSS APPLY t.x.nodes('Loop') as l(x)
where L.X.value('(REF/REF02/text())[3]', 'varchar(50)') is not Null
order by L.X.value('(REF/REF02/text())[1]', 'varchar(50)')

DECLARE @SqlSelect NVARCHAR(500)

SET @SqlSelect = 'IF OBJECT_ID(''dbo.'+ @TableName+''', ''U'') IS NOT NULL DROP TABLE dbo.'+ @TableName+';'

EXECUTE sp_executesql @SqlSelect

SET @SqlSelect = 'SELECT * INTO dbo.'+ @TableName+' FROM #834Temp'

EXECUTE sp_executesql @SqlSelect
END

GO
