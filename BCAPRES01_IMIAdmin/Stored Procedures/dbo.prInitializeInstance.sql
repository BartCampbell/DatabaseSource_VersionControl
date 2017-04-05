SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	prInitializeInstance
Author:		Dennis Deming
Copyright:	© 2007
Date:		2007.10.02
Purpose:	To initialize a new instance so we can process inbound data
Parameters:	@vcClient		varchar( 100 ).........Client.ClientName
		@vcLoadType		varchar( 100 ).........Process.Description
		@bitIsIncremental	bit....................1 = load is incremental
		@cDateBegin		CHAR( 8 )..............ClientProcessInstance.InstanceBegin
		@cDateEnd		CHAR( 8 )..............ClientProcessInstance.InstanceEnd
		@iLoadInstanceID	int..............OUT...ClientProcessInstance.LoadInstanceID
Depends On:	dbo.Client
		dbo.ClientProcess
		dbo.Process
		dbo.ProcessType
Calls:		None
Called By:	This procedure is used to manually run the load process.
Returns:	None
Notes:		None
Process:	1.	Declare/initialize variables
		2.	Insert data into ClientProcessInstance
Test Script:	DECLARE @iLoadInstanceID int
		EXECUTE dbo.prInitializeInstance 'Ingram', 'Member Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT
		SELECT * FROM ClientProcessInstance WHERE LoadInstanceID = @iLoadInstanceID
ToDo:		
*************************************************************************************/
CREATE PROCEDURE [dbo].[prInitializeInstance]
	@vcClient		varchar( 100 ),	-- Client.ClientName
	@vcLoadType		varchar( 100 ),	-- Process.Description
	@bitIsIncremental	bit,		-- 1 = load is incremental
	@cDateBegin		char( 8 ),	-- ClientProcessInstance.InstanceBegin
	@cDateEnd		char( 8 ),	-- ClientProcessInstance.InstanceEnd
	@iLoadInstanceID	int OUTPUT	-- ClientProcessInstance.LoadInstanceID
AS

BEGIN TRY
	/*************************************************************************************
		1.	Declare/initialize variables
	*************************************************************************************/
	DECLARE	@cLastDayOfMonth	char( 8 ),
		@dtLastDayOfMonth	datetime
		
	SELECT
		@cDateBegin = NULLIF( @cDateBegin, '' ),
		@cDateEnd = NULLIF( @cDateEnd, '' )
	
	SET @dtLastDayOfMonth = DATEADD( mm, 1, GETDATE())
	SET @dtLastDayOfMonth = DATEADD( dd, -1 * DATEPART( dd, @dtLastDayOfMonth ), @dtLastDayOfMonth )
	
	SET @cLastDayOfMonth = ISNULL( @cDateEnd, CONVERT( CHAR( 8 ), @dtLastDayOfMonth, 112 ))

	IF NOT EXISTS( SELECT * FROM Client WHERE ClientName = @vcClient )
	BEGIN
		PRINT 'Client ' + @vcClient + ' does not exist in Client.ClientName.  Aborting.'
		RETURN
	END

	IF NOT EXISTS( SELECT * FROM Process WHERE Description = @vcLoadType )
	BEGIN
		PRINT 'Load type ' + @vcLoadType + ' does not exist in Process.Description.  Aborting.'
		RETURN
	END

	IF NOT EXISTS(	SELECT	cp.* 
			FROM	ClientProcess cp
				JOIN Client c ON cp.ClientID = c.ClientID
				JOIN Process p ON cp.ProcessID = p.ProcessID
			WHERE	p.Description = @vcLoadType 
				AND c.ClientName = @vcClient )
	BEGIN
		PRINT 'Client ' + @vcClient + ' has no load type of ' + @vcLoadType + ' mapped in ClientProcess.  Aborting.'
		RETURN
	END

	/*************************************************************************************
		2.	Insert data into ClientProcessInstance
	*************************************************************************************/
	SET NOCOUNT ON


	INSERT INTO dbo.ClientProcessInstance( ClientProcessID, DateBeginLoadDataStore, DateEndLoadDataStore,
		DateBeginLoadRDSM, DateEndLoadRDSM, DateBeginLoadWarehouse, DateEndLoadWarehouse,
		DateBeginProcessDataStore, DateEndProcessDataStore, InstanceBegin, 
		InstanceEnd, JobID, LastStatus ) 
	SELECT	ClientProcessID, NULL, NULL,
		GETDATE(), NULL, NULL, NULL,
		NULL, NULL, ISNULL( @cDateBegin, '20000101' ), 
		@cLastDayOfMonth, NULL, NULL
	FROM	dbo.ClientProcess AS cp
		JOIN dbo.Process AS p ON cp.ProcessID = p.ProcessID
		JOIN dbo.Client AS c ON cp.ClientID = c.ClientID
		JOIN dbo.ProcessType AS pt ON p.ProcessTypeID = pt.ProcessTypeID
	WHERE	c.ClientName = @vcClient
		AND p.Description = @vcLoadType
		AND pt.Description = CASE WHEN @bitIsIncremental = 1 THEN 'Incremental' ELSE 'Full' END
		
	SET @iLoadInstanceID = SCOPE_IDENTITY()
END TRY

BEGIN CATCH
	-- We're not logging to IMIAdmin..StatusLog because until the very last step, we have no LoadInstanceID.
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, LoadInstanceID, UserName )
	SELECT	ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_SEVERITY(),
		ERROR_STATE(), GETDATE(), 0, SUSER_SNAME()
END CATCH

GO
