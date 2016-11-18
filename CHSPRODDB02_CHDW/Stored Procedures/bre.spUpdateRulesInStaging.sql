SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	08/04/2016
-- Description:	Updates the rundate of the business rule in staging
-- Usage:			
--		  EXECUTE bre.spUpdateRulesInStaging
-- =============================================
CREATE PROC [bre].[spUpdateRulesInStaging]
AS
    SET NOCOUNT ON;

    BEGIN
    
        UPDATE  stage.BusinessRules
        SET     RunTime = GETDATE();


    END;     





GO
