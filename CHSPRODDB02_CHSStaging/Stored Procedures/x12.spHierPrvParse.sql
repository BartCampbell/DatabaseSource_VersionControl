SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2000A - BILLING PROVIDER HIERARCHICAL LEVEL
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000013') -- '000000001'
		AND LoopID = '2000A'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.HierPrv

	EXEC x12.spHierPrvParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE LoopID = '2000A' AND TransactionControlNumber IN ('0003') 
	SELECT * FROM x12.HierPrv WHERE HierPrv_TransactionControlNumber IN ('0003') 
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spHierPrvParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO x12.HierPrv (
		HierPrv_RowID
		,HierPrv_RowIDParent
		,HierPrv_CentauriClientID
		,HierPrv_FileLogID
		,HierPrv_TransactionImplementationConventionReference
		,HierPrv_TransactionControlNumber
		,HierPrv_LoopID

		,HierPrv_HierarchicalIDNumber_HL01
		,HierPrv_HierarchicalParentIDNumber_HL02
		,HierPrv_HierarchicalLevelCode_HL03
		,HierPrv_HierarchicalChildCode_HL04

		,HierPrv_ProviderCode_PRV01
		,HierPrv_ReferenceIdentificationQualifier_PRV02
		,HierPrv_ReferenceIdentification_PRV03
		,HierPrv_StateOrProvinceCode_PRV04
		,HierPrv_ProviderSpecialtyInformation_PRV05
		,HierPrv_ProviderOrganizationCode_PRV06

		,HierPrv_EntityIdentifierCode_CUR01
		,HierPrv_CurrencyCode_CUR02
		,HierPrv_ExchangeRate_CUR03
		,HierPrv_EntityIdentifierCode_CUR04
		,HierPrv_CurrencyCode_CUR05
		,HierPrv_CurrencyMarketExchangeCode_CUR06
		,HierPrv_DateTimeQualifier_CUR07
		,HierPrv_Date_CUR08
		,HierPrv_Time_CUR09
		,HierPrv_DateTimeQualifier_CUR10
		,HierPrv_Date_CUR11
		,HierPrv_Time_CUR12
		,HierPrv_DateTimeQualifier_CUR13
		,HierPrv_Date_CUR14
		,HierPrv_Time_CUR15
		,HierPrv_DateTimeQualifier_CUR16
		,HierPrv_Date_CUR17
		,HierPrv_Time_CUR18
		,HierPrv_DateTimeQualifier_CUR19
		,HierPrv_Date_CUR20
		,HierPrv_Time_CUR21
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- 2000A - HL - BILLING PROVIDER HIERARCHICAL LEVEL
		,h.b.value('(HL/HL01/text())[1]', 'varchar(12)') AS 'HierPrv_HierarchicalIDNumber_HL01'
		,h.b.value('(HL/HL02/text())[1]', 'varchar(12)') AS 'HierPrv_HierarchicalParentIDNumber_HL02'
		,h.b.value('(HL/HL03/text())[1]', 'varchar(2)') AS 'HierPrv_HierarchicalLevelCode_HL03'
		,h.b.value('(HL/HL04/text())[1]', 'varchar(1)') AS 'HierPrv_HierarchicalChildCode_HL04'
		-- 2000A - PRV - BILLING PROVIDER SPECIALTY INFORMATION
		,h.b.value('(PRV/PRV01/text())[1]', 'varchar(3)') AS 'HierPrv_ProviderCode_PRV01'
		,h.b.value('(PRV/PRV02/text())[1]', 'varchar(3)') AS 'HierPrv_ReferenceIdentificationQualifier_PRV02'
		,h.b.value('(PRV/PRV03/text())[1]', 'varchar(50)') AS 'HierPrv_ReferenceIdentification_PRV03'
		,h.b.value('(PRV/PRV04/text())[1]', 'varchar(1)') AS 'HierPrv_StateOrProvinceCode_PRV04'
		,h.b.value('(PRV/PRV05/text())[1]', 'varchar(2)') AS 'HierPrv_ProviderSpecialtyInformation_PRV05'
		,h.b.value('(PRV/PRV06/text())[1]', 'varchar(3)') AS 'HierPrv_ProviderOrganizationCode_PRV06'
		-- 2000A - CUR - FOREIGN CURRENCY INFORMATION
		,h.b.value('(CUR/CUR01/text())[1]', 'varchar(3)') AS 'HierPrv_EntityIdentifierCode_CUR01'
		,h.b.value('(CUR/CUR02/text())[1]', 'varchar(3)') AS 'HierPrv_CurrencyCode_CUR02'
		,h.b.value('(CUR/CUR03/text())[1]', 'varchar(10)') AS 'HierPrv_ExchangeRate_CUR03'
		,h.b.value('(CUR/CUR04/text())[1]', 'varchar(3)') AS 'HierPrv_EntityIdentifierCode_CUR04'
		,h.b.value('(CUR/CUR05/text())[1]', 'varchar(3)') AS 'HierPrv_CurrencyCode_CUR05'
		,h.b.value('(CUR/CUR06/text())[1]', 'varchar(3)') AS 'HierPrv_CurrencyMarketExchangeCode_CUR06'
		,h.b.value('(CUR/CUR07/text())[1]', 'varchar(3)') AS 'HierPrv_DateTimeQualifier_CUR07'
		,h.b.value('(CUR/CUR08/text())[1]', 'varchar(8)') AS 'HierPrv_Date_CUR08'
		,h.b.value('(CUR/CUR09/text())[1]', 'varchar(8)') AS 'HierPrv_Time_CUR09'
		,h.b.value('(CUR/CUR10/text())[1]', 'varchar(3)') AS 'HierPrv_DateTimeQualifier_CUR10'
		,h.b.value('(CUR/CUR11/text())[1]', 'varchar(8)') AS 'HierPrv_Date_CUR11'
		,h.b.value('(CUR/CUR12/text())[1]', 'varchar(8)') AS 'HierPrv_Time_CUR12'
		,h.b.value('(CUR/CUR13/text())[1]', 'varchar(3)') AS 'HierPrv_DateTimeQualifier_CUR13'
		,h.b.value('(CUR/CUR14/text())[1]', 'varchar(8)') AS 'HierPrv_Date_CUR14'
		,h.b.value('(CUR/CUR15/text())[1]', 'varchar(8)') AS 'HierPrv_Time_CUR15'
		,h.b.value('(CUR/CUR16/text())[1]', 'varchar(3)') AS 'HierPrv_DateTimeQualifier_CUR16'
		,h.b.value('(CUR/CUR17/text())[1]', 'varchar(8)') AS 'HierPrv_Date_CUR17'
		,h.b.value('(CUR/CUR18/text())[1]', 'varchar(8)') AS 'HierPrv_Time_CUR18'
		,h.b.value('(CUR/CUR19/text())[1]', 'varchar(3)') AS 'HierPrv_DateTimeQualifier_CUR19'
		,h.b.value('(CUR/CUR20/text())[1]', 'varchar(8)') AS 'HierPrv_Date_CUR20'
		,h.b.value('(CUR/CUR21/text())[1]', 'varchar(8)') AS 'HierPrv_Time_CUR21'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('HierarchicalLoop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2000A'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
