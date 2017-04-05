SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	prCreateInstanceAndLoadData
Author:		Lance Dowling
Copyright:	© 2007
Date:		2007.10.22
Purpose:	Create a new load instance for a customer and then load their data
Parameters:	@vcClient	varchar( 255 )......Customer to load
		@cDateEnd	char( 8 )...........YYYYMMDD
Depends On:	IMIAdmin..Client
		IMIAdmin..ClientProcess
		IMIAdmin..ClientProcessInstance
		IMIAdmin..StatusType
Calls:		prBuildMPIXref_NQCA
			prStainSourceMPI_NCQA
Called By:	Lance
Returns:	0 = success
Notes:		None
Process:	1.	Declare/initialize variables
		2.	Create new load instance
		3.	Start load process
Test Script:	EXECUTE prCreateInstanceAndLoadData 'NCQA2008', '20071231'
ToDo:		
*************************************************************************************/
CREATE PROCEDURE [dbo].[prCreateInstanceAndLoadData]
	@vcClient	varchar( 255 ),		-- Customer to load
	@cDateEnd	char( 8 )		-- YYYYMMDD
AS
BEGIN TRY
	SET NOCOUNT ON

	/*************************************************************************************
		1.	Declare/initialize variables
	*************************************************************************************/
	DECLARE	@guiStatus		uniqueidentifier,
		@iLoadInstanceID	int

	SELECT @guiStatus = StatusTypeID FROM IMIAdmin..StatusType WHERE Description = 'Started'
	
	-- convert @cDateEnd to datetime to verify the data
	SELECT CONVERT( datetime, @cDateEnd, 112 )

	/*************************************************************************************
		2.	Create new load instance
	*************************************************************************************/
	INSERT INTO IMIAdmin..ClientProcessInstance( ClientProcessID, InstanceBegin, InstanceEnd, 
		JobID, LastStatus )
	SELECT	cp.ClientProcessID, GETDATE(), NULL, NULL, @guiStatus
	FROM	IMIAdmin..Client c
		JOIN IMIAdmin..ClientProcess cp ON c.ClientID = cp.ClientID
	WHERE	c.ClientName = @vcClient

	SET @iLoadInstanceID = SCOPE_IDENTITY()

	-- I know it's a bit late to be logging the start, but we couldn't log anything until
	-- we had a LoadInstanceID.
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prCreateInstanceAndLoadData', 'Started'

	/*************************************************************************************
		3.	Start load process
	*************************************************************************************/
	EXECUTE dbo.[prBuildMPIXref_NCQA]  @iLoadInstanceID

	EXECUTE dbo.[prStainSourceMPI_NCQA]  @iLoadInstanceID

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prCreateInstanceAndLoadData', 'Completed'
END TRY

BEGIN CATCH
	DECLARE	@iErrorLine		int, 
		@iErrorNumber		int,
		@iErrorSeverity		int,
		@iErrorState		int,
		@nvcErrorMessage	nvarchar( 4000 ), 
		@nvcErrorProcedure	nvarchar( 126 )

	-- capture error info so we can fail it up the line
	SELECT	@iErrorLine = ERROR_LINE(),
		@iErrorNumber = ERROR_NUMBER(),
		@iErrorSeverity = ERROR_SEVERITY(),
		@iErrorState = ERROR_STATE(),
		@nvcErrorMessage = ERROR_MESSAGE(),
		@nvcErrorProcedure = ERROR_PROCEDURE()
		
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, InstanceID, UserName )
	SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
		@iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
	FROM	IMIAdmin..ClientProcessInstance
	WHERE	LoadInstanceID = @iLoadInstanceID
	
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prCreateInstanceAndLoadData', 'Failed'
	
	RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH
GO
