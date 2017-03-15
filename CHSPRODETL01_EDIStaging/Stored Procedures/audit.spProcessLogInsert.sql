SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [audit].[spProcessLogInsert] 
    @Process varchar(50),
    @FileName varchar(100),
    @Task varchar(100),
    @ProcessLogID int OUTPUT
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	INSERT INTO [audit].[ProcessLog] ([Process], [FileName], [Task], [StartTime], [EndTime], [Status])
	SELECT @Process, @FileName, @Task, GETDATE(), NULL, 'Started'

	SELECT @ProcessLogID = SCOPE_IDENTITY()

GO
