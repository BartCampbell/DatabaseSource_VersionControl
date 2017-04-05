SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	fxSetMetrics
Author:		Dennis Deming
Copyright:	© 2007
Date:		2007.11.01
Purpose:	To set metrics values for automated processes
Parameters:	@iLoadInstanceID	int..............ClientProcessInstanceMetrics.LoadInstanceID
		@vcMetricName		varchar( 100 )...ClientProcessInstanceMetrics.MetricName
		@vcMetricValue		varchar( 100 )...ClientProcessInstanceMetrics.MetricValue
		@sysProcedure		sysname..........ClientProcessInstanceMetrics.ProcedureName
		@sysTable		sysname...OPT....ClientProcessInstanceMetrics.TableName
Depends On:	dbo.ClientProcessInstanceMetrics
Calls:		None
Called By:	This procedure should be called as part of warehouse automation
Returns:	None
Notes:		
Process:	1.	Insert into StatusLog
Test Script:	EXECUTE dbo.fxSetMetrics 1, 'Test of fxSetMetrics', '100', 'PrTestProc', 'TestTable'
ToDo:		
*************************************************************************************/
CREATE PROCEDURE [dbo].[fxSetMetrics]
	@iLoadInstanceID	int,		-- ClientProcessInstanceMetrics.LoadInstanceID
	@vcMetricName		varchar( 100 ),	-- ClientProcessInstanceMetrics.MetricName
	@vcMetricValue		varchar( 100 ),	-- ClientProcessInstanceMetrics.MetricValue
	@sysProcedure		sysname,	-- ClientProcessInstanceMetrics.ProcedureName
	@sysTable		sysname = NULL,	-- ClientProcessInstanceMetrics.TableName
	@cExpectedMetricValue VARCHAR(100) = nULL
AS
BEGIN TRY
	INSERT INTO dbo.ClientProcessInstanceMetrics( DateCreated, LoadInstanceID, MetricName,
		MetricValue, ProcedureName, TableName, ExpectedMetricValue )
	SELECT	GETDATE(), @iLoadInstanceID, @vcMetricName, @vcMetricValue, @sysProcedure, @sysTable, @cExpectedMetricValue 
END TRY

BEGIN CATCH
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, InstanceID, UserName )
	SELECT	ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_SEVERITY(),
		ERROR_STATE(), GETDATE(), InstanceID, SUSER_SNAME()
	FROM	IMIAdmin..ClientProcessInstance
	WHERE	LoadInstanceID = @iLoadInstanceID
END CATCH


GO
