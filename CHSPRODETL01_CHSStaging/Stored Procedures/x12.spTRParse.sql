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
		--AND LoopID = '2010BA'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.TR

	EXEC x12.spTRParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000000003') AND LoopID IS NULL
	SELECT * FROM x12.TR WHERE TR_TransactionControlNumber IN ('000000003') -- ORDER BY TR_LoopID
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spTRParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO X12.TR (
		TR_RowID
		,TR_RowIDParent
		,TR_CentauriClientID
		,TR_FileLogID
		,TR_TransactionImplementationConventionReference
		,TR_TransactionControlNumber
		,TR_LoopID

		,TR_TransactionSetIdentifierCode_ST01
		,TR_TransactionSetControlNumber_ST02
		,TR_ImplementationConventionReference_ST03

		,TR_HierarchicalStructureCode_BHT01
		,TR_TransactionSetPurposeCode_BHT02
		,TR_ReferenceIdentification_BHT03
		,TR_Date_BHT04
		,TR_Time_BHT05
		,TR_TransactionTypeCode_BHT06

		,SE_NumberofIncludedSegments_SE01
		,SE_TransactionSetControlNumber_SE02
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- TR - ST - Transaction Set Header
		,h.b.value('(ST/ST01/text())[1]', 'varchar(50)') AS 'TR_TransactionSetIdentifierCode_ST01'
		,h.b.value('(ST/ST02/text())[1]', 'varchar(50)') AS 'TR_TransactionSetControlNumber_ST02'
		,h.b.value('(ST/ST03/text())[1]', 'varchar(50)') AS 'TR_ImplementationConventionReference_ST03'
		-- TR - BHT - Beginning of Hierarchical Transaction
		,h.b.value('(BHT/BHT01/text())[1]', 'varchar(50)') AS 'TR_HierarchicalStructureCode_BHT01'
		,h.b.value('(BHT/BHT02/text())[1]', 'varchar(50)') AS 'TR_TransactionSetPurposeCode_BHT02'
		,h.b.value('(BHT/BHT03/text())[1]', 'varchar(50)') AS 'TR_ReferenceIdentification_BHT03'
		,h.b.value('(BHT/BHT04/text())[1]', 'varchar(50)') AS 'TR_Date_BHT04'
		,h.b.value('(BHT/BHT05/text())[1]', 'varchar(50)') AS 'TR_Time_BHT05'
		,h.b.value('(BHT/BHT06/text())[1]', 'varchar(50)') AS 'TR_TransactionTypeCode_BHT06'

		-- TR - SE - TRANSACTION SET TRAILER
		,h.b.value('(SE/SE01/text())[1]', 'varchar(50)') AS 'SE_NumberofIncludedSegments_SE01'
		,h.b.value('(SE/SE02/text())[1]', 'varchar(50)') AS 'SE_TransactionSetControlNumber_SE02'

	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Transaction') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID IS NULL
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
