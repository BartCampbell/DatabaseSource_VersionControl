SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [audit].[spGetLastOECDWLoadTime] @Task VARCHAR(100)
AS
    SET NOCOUNT ON; 
    SET XACT_ABORT ON;  

    SELECT  ISNULL(MAX(EndTime), '1900-01-01') AS EndTime
    FROM    audit.ProcessLog
    WHERE   Process = 'OECDWLoadMaster'
            AND Status = 'Success'
            AND Task = @Task;

GO
