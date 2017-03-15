SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [audit].[spProcessLogUpdate] 
    @ProcessLogID int,
    @Status varchar(50)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	UPDATE [audit].[ProcessLog]
	SET    [EndTime] = GETDATE(), [Status] = @Status
	WHERE  [ProcessLogID] = @ProcessLogID

GO
