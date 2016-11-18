SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	truncates the staging table used for the RAPS Submission History load
-- Usage:			
--		  EXECUTE stage.spClearRAPSSubmissionHistoryTable
-- =============================================
CREATE PROC [stage].[spClearRAPSSubmissionHistoryTable]
AS

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.RAPS_SubmissionHistory

    END;     




GO
