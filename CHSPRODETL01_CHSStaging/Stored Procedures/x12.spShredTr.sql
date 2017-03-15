SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Begining of Shred: Get all Transaction and then begin the recursive looping to grab all child HierarchicalLoop / Loop records
Use:

	SELECT * FROM x12.StageXML

	TRUNCATE TABLE x12.Shred

	EXEC x12.spShredTr
		,@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose 3:Restricted

	SELECT TOP 100 * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000001','000000003','000002175') -- '000000001','000000003','000002175'
		--AND NodePath = '.' -- 3287 
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spShredTr] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose 3:Restricted
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CentauriClientID INT;
	SELECT @CentauriClientID = CentauriClientID FROM ETLConfig.dbo.FileLog WHERE FileLogID = @FileLogID

	DECLARE @RowCnt INT = 0

	IF @Debug >= 1 PRINT '----- Start Proc Tr: @FileLogID:[' + CAST(@FileLogID AS VARCHAR) + ']'

	-- Get Transactions

	DECLARE @LoopXML XML;
	SET @LoopXML = (	SELECT XMLData -- SELECT *
						FROM x12.StageXML
						WHERE FileLogID = @FileLogID
						)
	
	SET NOCOUNT OFF;

	INSERT INTO x12.Shred (
		RowIDParent
		,CentauriClientID
		,FileLogID
		,TransactionImplementationConventionReference
		,TransactionControlNumber
		,LoopSegment
		,LoopID
		,LoopName
		,LoopXML
		,NodePathRoot
		)
	SELECT
		NULL
		,@CentauriClientID
		,@FileLogID
		,tr.a.value('(ST/ST03/text())[1]', 'varchar(50)')
		,tr.a.value('(ST/ST02/text())[1]', 'varchar(50)')
		,'TR'
		,h.b.value('(@LoopId)[1]', 'varchar(50)')
		,COALESCE(h.b.value('(@Name)[1]', 'varchar(50)'),h.b.value('(@LoopName)[1]', 'varchar(50)'))
		,h.b.query('.')
		,'.'
	FROM @LoopXML.nodes('Interchange/FunctionGroup/Transaction') AS tr ( a )
	OUTER APPLY tr.a.nodes('.') AS h ( b ) 
	WHERE 1=1
		AND ( '.' = '.' 
				OR h.b.value('(@LoopId)[1]', 'varchar(50)') IS NOT NULL
				)
		-- Test Only
		AND (@Debug < 3 OR (@Debug >= 3 AND tr.a.value('(ST/ST02/text())[1]', 'varchar(50)') IN ('000000001','000000003')))

	SET @RowCnt = @@ROWCOUNT
	
	--

	IF @RowCnt > 0 -- Transactions found
	BEGIN
		IF @Debug >= 1 PRINT '-- Transactions found:[' + CAST(@RowCnt AS VARCHAR) + ']'

		-- Get Loop(s)

		EXEC x12.spShredL
			@FileLogID = @FileLogID -- INT
			,@LoopSegment = 'TR' -- INT
			,@NodePathRoot = '.' -- VARCHAR(255)
			,@Debug = @Debug -- 0:None 1:Min 2:Verbose

		-- Get HierarchicalLoop(s)

		EXEC x12.spShredHL
			@FileLogID = @FileLogID -- INT
			,@LoopSegment = 'TR' -- INT
			,@NodePathRoot = '.' -- VARCHAR(255)
			,@Debug = @Debug -- 0:None 1:Min 2:Verbose

	END  -- Transactions found

	-- Finally, Reorganize indexes to prepare for the next step
	--ALTER INDEX ALL ON x12.Shred  
	--	REORGANIZE; 

	SET NOCOUNT ON;

END -- Procedure


GO
