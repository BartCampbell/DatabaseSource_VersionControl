SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Cont Shred from spX12ShredTr: Get all HierarchicalLoops and then begin the recursive looping to grab all child HierarchicalLoops
Use:

	DELETE FROM x12.Shred WHERE NodePath = 'HierarchicalLoop';

	EXEC x12.spShredHL
		@FileLogID = 1 -- INT
		,@LoopSegment = 'TR' -- VARCHAR(50)
		,@NodePathRoot = '.' -- VARCHAR(255)
		,@Debug = 2 -- 0:None 1:Min 2:Verbose

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND TransactionControlNumber IN ('000000001','000002175')
		--AND NodePath = '.' -- 3287 
	ORDER BY TransactionControlNumber, LoopSegment, LoopID, RowID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spShredHL] (
	@FileLogID INT 
	,@LoopSegment VARCHAR(50) --INT
	,@NodePathRoot VARCHAR(255)
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF @Debug >= 1 PRINT '---- Start Proc HierarchicalLoop -- @FileLogID:[' + CAST(@FileLogID AS VARCHAR) + '] -- @LoopSegment:[' + CAST(@LoopSegment AS VARCHAR) + '] -- @NodePathRoot:[' + CAST(@NodePathRoot AS VARCHAR) + ']'

	DECLARE 
		@RowCnt INT = 0
		,@SQLString NVARCHAR(MAX)
		,@NodePath VARCHAR(255)
		,@LoopSegmentNext VARCHAR(50) = @LoopSegment + '|HL'

	SELECT @NodePathRoot = CASE WHEN @LoopSegment = 'TR' THEN 'Transaction' ELSE 'HierarchicalLoop' END

	SET @NodePath = 'HierarchicalLoop'

	IF @Debug >= 1 PRINT '------ Proc HierarchicalLoop -- @NodePathRoot:[' + CAST(@NodePathRoot AS VARCHAR) + '] -- @NodePath:[' + CAST(@NodePath AS VARCHAR) + ']'

	IF OBJECT_ID('tempdb..#X12Shred') IS NOT NULL
			DROP TABLE #X12Shred

	CREATE TABLE #X12Shred(
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

	-- Get HierarchicalLoop

	SET @SQLString = '
	INSERT INTO #X12Shred ( --x12.Shred (
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
		,COALESCE(h.b.value(''(@Name)[1]'', ''varchar(50)''),h.b.value(''(@LoopName)[1]'', ''varchar(50)''))
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

	SET @RowCnt = (SELECT COUNT(*) FROM #X12Shred) -- @@ROWCOUNT
	--

	IF @RowCnt > 0 -- HierarchicalLoop found
	BEGIN
		IF @Debug >= 1 PRINT '-- HierarchicalLoop(s) found:[' + CAST(@RowCnt AS VARCHAR) + ']'

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
		SELECT * FROM #X12Shred

		-- Get Loop(s)

		EXEC x12.spShredL
			@FileLogID = @FileLogID
			,@LoopSegment = @LoopSegmentNext 
			,@NodePathRoot = @NodePathRoot
			,@Debug = @Debug -- 0:None 1:Min 2:Verbose

		-- Get HierarchicalLoop(s)

		EXEC x12.spShredHL
			@FileLogID = @FileLogID
			,@LoopSegment = @LoopSegmentNext
			,@NodePathRoot = @NodePathRoot
			,@Debug = @Debug -- 0:None 1:Min 2:Verbose

	END  -- Transactions found

	--SET NOCOUNT ON;

END -- Procedure


GO
