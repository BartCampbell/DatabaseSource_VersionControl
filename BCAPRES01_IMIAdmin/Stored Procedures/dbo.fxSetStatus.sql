SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*************************************************************************************
Procedure:	fxSetStatus
Author:		Dennis Deming
Copyright:	© 2007
Date:		2007.07.13 (Friday)
Purpose:	To set status of automated processes
Parameters:	@iLoadInstanceID	int...................StatusLog.LoadInstanceID
		@sysProcedure		sysname...............StatusLog.ProcedureName
		@vcStatus		varchar( 20 ).........StatusLog.StatusType
		@vcMessage		varchar( 255)...OPT...StatusLog.StatusMessage
		@iStatusLogID		int.............OUT...StatusLog.StatusLogID
Depends On:	dbo.StatusLog
Calls:		None
Called By:	This procedure should be called as part of warehouse automation
Returns:	None
Notes:		@iStatusLogID is used for situations where the LoadInstanceID is not
		known.  It can be used to capture the first call by a process to
		this procedure so that, once the LoadInstanceID is created by the
		calling process, fxUpdateStatusLoadInstanceID can be called to 
		retroactively update the value.  This is accomplished by capturing
		the initial StatusLogID created by the process and then capturing the 
		StatusLogID of the step that created the LoadInstanceID.  Those two
		IDs are then passed to fxUpdateStatusLoadInstanceID along with the
		newly created LoadInstanceID.
Process:	1.	Insert into StatusLog
Test Script:	DECLARE @iLoadInstanceID int
		SELECT @iLoadInstanceID = MAX( LoadInstanceID ) FROM dbo.ClientProcessInstance
		EXECUTE dbo.fxSetStatus @iLoadInstanceID, 'prBuildMPIXref', 'Started', 'Processing 178213 rows'
ToDo:		
*************************************************************************************/
CREATE PROCEDURE [dbo].[fxSetStatus]
	@iLoadInstanceID	int,			-- StatusLog.LoadInstanceID
	@sysProcedure		sysname,		-- StatusLog.ProcedureName
	@vcStatus		varchar( 20 ),		-- StatusLog.StatusType
	@vcMessage		varchar( 255) = NULL,	-- StatusLog.StatusMessage
	@iStatusLogID		int = NULL OUTPUT	-- StatusLog.StatusLogID
AS
BEGIN TRY
	-- use dbo.StatusType to enforce standardization of StatusType
	INSERT INTO dbo.StatusLog( LoadInstanceID, ProcedureName, StatusType, StatusTime, StatusMessage )
		SELECT	@iLoadInstanceID, @sysProcedure, @vcStatus, GETDATE(), @vcMessage
		FROM	dbo.StatusType
		WHERE	Description = @vcStatus
		
	SET @iStatusLogID = SCOPE_IDENTITY()
END TRY

BEGIN CATCH
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, LoadInstanceID, UserName )
	SELECT	ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_SEVERITY(),
		ERROR_STATE(), GETDATE(), @iLoadInstanceID, SUSER_SNAME()
END CATCH

GO
