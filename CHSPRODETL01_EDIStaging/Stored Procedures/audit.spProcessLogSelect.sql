SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [audit].[spProcessLogSelect] 
    @ProcessLogID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ProcessLogID], [Process], [FileName], [Task], [StartTime], [EndTime], [Status] 
	FROM   [audit].[ProcessLog] 
	WHERE  ([ProcessLogID] = @ProcessLogID OR @ProcessLogID IS NULL) 

	COMMIT

GO
