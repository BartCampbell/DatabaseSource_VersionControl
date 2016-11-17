SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Load MMR link data to the DV from Staging 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MMR_LoadLinks]
	-- Add the parameters for the stored procedure here
AS
    BEGIN

        SET NOCOUNT ON;

	   -- LOAD Member_MMR TABLE
        INSERT  INTO dbo.L_Member_MMR
                ( L_Member_MMR_RK ,
                  H_Member_RK ,
                  H_MMR_RK ,
                  LoadDate ,
                  RecordSource
                )
                SELECT DISTINCT
                        L_Member_MMR_RK ,
                        H_Member_RK ,
                        H_MMR_RK ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mmr.MMR_Stage
                WHERE   L_Member_MMR_RK NOT IN ( SELECT L_Member_MMR_RK
                                                 FROM   dbo.L_Member_MMR );
	   
	   	
    END;


GO
