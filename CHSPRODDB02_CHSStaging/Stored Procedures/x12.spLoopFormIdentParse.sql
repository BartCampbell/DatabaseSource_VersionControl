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
		AND TransactionControlNumber IN ('000000013') -- '000000001'
		AND LoopID = '2410'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopFormIdent
	TRUNCATE TABLE x12.SegFRM

	EXEC x12.spLoopFormIdentParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE LoopID = '2440'
	SELECT * FROM x12.LoopFormIdent WHERE FormIdent_TransactionControlNumber IN ('000000013') -- ORDER BY FormIdent_LoopID
	SELECT * FROM x12.SegFRM WHERE FRM_TransactionControlNumber IN ('000000013') -- ORDER BY FRM_LoopID
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopFormIdentParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO x12.LoopFormIdent (
		FormIdent_RowID
		,FormIdent_RowIDParent
		,FormIdent_CentauriClientID
		,FormIdent_FileLogID
		,FormIdent_TransactionImplementationConventionReference
		,FormIdent_TransactionControlNumber
		,FormIdent_LoopID

		,FormIdent_CodeListQualifierCode_LQ01
		,FormIdent_IndustryCode_LQ02
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID

		,h.b.value('(LQ/LQ01/text())[1]', 'varchar(3)') AS 'FormIdent_CodeListQualifierCode_LQ01'
		,h.b.value('(LQ/LQ02/text())[1]', 'varchar(30)') AS 'FormIdent_IndustryCode_LQ02'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2440'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- FRM

	INSERT INTO x12.SegFRM (
		FRM_RowID
		,FRM_RowIDParent
		,FRM_CentauriClientID
		,FRM_FileLogID
		,FRM_TransactionImplementationConventionReference
		,FRM_TransactionControlNumber
		,FRM_LoopID

		,FRM_AssignedIdentification_FRM01
		,FRM_YesNoConditionOrResponseCode_FRM02
		,FRM_ReferenceIdentification_FRM03
		,FRM_Date_FRM04
		,FRM_PercentDecimalFormat_FRM05
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(FRM01/text())[1]', 'varchar(20)') AS 'FRM_AssignedIdentification_FRM01'
		,h.b.value('(FRM02/text())[1]', 'varchar(1)') AS 'FRM_YesNoConditionOrResponseCode_FRM02'
		,h.b.value('(FRM03/text())[1]', 'varchar(50)') AS 'FRM_ReferenceIdentification_FRM03'
		,h.b.value('(FRM04/text())[1]', 'varchar(8)') AS 'FRM_Date_FRM04'
		,h.b.value('(FRM05/text())[1]', 'varchar(6)') AS 'FRM_PercentDecimalFormat_FRM05'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/FRM') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2440'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
