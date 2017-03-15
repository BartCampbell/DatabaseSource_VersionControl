SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [audit].[spProcessLogUpdateTask] 
    @ProcessLogID int,
    @Task varchar(100) ,
    @Status varchar(50)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	UPDATE [audit].[ProcessLog]
	SET    [EndTime] = GETDATE(), [Status] = @Status
	WHERE  [ProcessLogID] = @ProcessLogID AND Task = @Task AND EndTime IS NULL
GO
