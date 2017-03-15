SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Cont Shred from spX12ShredTr/HL: Get all Loops and then begin the recursive looping to grab all child Loops
Use:

	DELETE FROM x12.Shred WHERE NodePath = 'HierarchicalLoop';

	EXEC x12.spShredL
		@FileLogID = 1 -- INT
		,@LoopSegment = 'TR' -- VARCHAR(50)
		,@NodePathRoot = '.' -- VARCHAR(255)
		,@Debug = 2 -- 0:None 1:Min 2:Verbose

	SELECT * FROM x12.Shred
	WHERE 1=1 
		--AND TransactionControlNumber IN ('000000001','000002175')
		--AND NodePath = '.' -- 3287 
	ORDER BY TransactionControlNumber, LoopSegment, LoopID, RowID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spShredL] (
	@FileLogID INT 
	,@LoopSegment VARCHAR(50)
	,@NodePathRoot VARCHAR(255)
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF @Debug >= 1 PRINT '---- Start Proc Loop -- @FileLogID:[' + CAST(@FileLogID AS VARCHAR) + '] -- @LoopSegment:[' + CAST(@LoopSegment AS VARCHAR) + '] -- @NodePathRoot:[' + CAST(@NodePathRoot AS VARCHAR) + ']'

	DECLARE 
		@RowCnt INT = 0
		,@SQLString NVARCHAR(MAX)
		,@NodePath VARCHAR(255)
		,@LoopSegmentNext VARCHAR(50) = @LoopSegment + '|L'

	SELECT @NodePathRoot = CASE 
							WHEN @NodePathRoot = '.' THEN 'Transaction' 
							WHEN @NodePathRoot = 'Transaction' THEN 'HierarchicalLoop' 
							ELSE @NodePathRoot 
							END

	SET @NodePath = 'Loop'

	IF @Debug >= 1 PRINT '------ Proc Loop -- @NodePathRoot:[' + CAST(@NodePathRoot AS VARCHAR) + '] -- @NodePath:[' + CAST(@NodePath AS VARCHAR) + ']'


	IF OBJECT_ID('tempdb..#X12ShredL') IS NOT NULL
			DROP TABLE #X12ShredL

	CREATE TABLE #X12ShredL(
		RowIDParent INT NULL,
		CentauriClientID INT NULL,
		FileLogID INT NULL,
		TransactionImplementationConventionReference VARCHAR(50) NULL,
		TransactionControlNumber VARCHAR(50) NULL,
		LoopSegment VARCHAR(50) NULL,
		LoopID VARCHAR(50) NULL,
		LoopName VARCHAR(50) NULL,
		LoopXML XML NULL,
		NodePathRoot VARCHAR(255) NULL
		)

	-- Get Loop

	SET @SQLString = '
	INSERT INTO #X12ShredL ( -- x12.Shred (
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
		x.RowID
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,''' + @LoopSegmentNext + '''
		,h.b.value(''(@LoopId)[1]'', ''varchar(50)'')
		,h.b.value(''(@Name)[1]'', ''varchar(50)'')
		,h.b.query(''.'')
		,''' + @NodePathRoot + '''
	FROM x12.Shred x
	OUTER APPLY x.LoopXML.nodes(''' + @NodePathRoot + ''') AS tr ( a )
	OUTER APPLY tr.a.nodes(''' + @NodePath + ''') AS h ( b ) 
	WHERE 1=1
		AND x.FileLogID = ' + CAST(@FileLogID AS VARCHAR) + '
		AND x.LoopSegment = '''  + @LoopSegment  + '''
		AND h.b.value(''(@LoopId)[1]'', ''varchar(50)'') IS NOT NULL
	';

	IF @Debug >= 2 PRINT @SQLString;

	-- SET NOCOUNT OFF;

	IF 1=1 EXECUTE sp_executesql @SQLString;

	SET @RowCnt = (SELECT COUNT(*) FROM #X12ShredL) -- @@ROWCOUNT
	--

	IF @RowCnt > 0 -- Loop found
	BEGIN
		IF @Debug >= 1 PRINT '-- Loop(s) found:[' + CAST(@RowCnt AS VARCHAR) + ']'

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
		SELECT * FROM #X12ShredL

		-- Get Loop(s)

		EXEC x12.spShredL
			@FileLogID = @FileLogID 
			,@LoopSegment = @LoopSegmentNext
			,@NodePathRoot = 'Loop'
			,@Debug = @Debug -- 0:None 1:Min 2:Verbose

	END  -- Transactions found

	-- SET NOCOUNT ON;

END -- Procedure


GO
