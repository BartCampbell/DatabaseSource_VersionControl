SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Load MOR link data to the DV from Staging 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MOR_LoadLinks]
	-- Add the parameters for the stored procedure here
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

	   -- LOAD Member_MOR A TABLE
        INSERT  INTO dbo.L_Member_MOR
                ( L_Member_MOR_RK ,
                  H_Member_RK ,
                  H_MOR_Header_RK ,
                  LoadDate ,
                  RecordSource
                )
                SELECT DISTINCT
                        L_Member_MOR_RK ,
                        H_Member_RK ,
                        H_MOR_Header_RK ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_ARecord_Stage
                WHERE   L_Member_MOR_RK NOT IN ( SELECT L_Member_MOR_RK
                                                 FROM   dbo.L_Member_MOR );
	   
	   -- LOAD Member_MOR B TABLE
        INSERT  INTO dbo.L_Member_MOR
                ( L_Member_MOR_RK ,
                  H_Member_RK ,
                  H_MOR_Header_RK ,
                  LoadDate ,
                  RecordSource
                )
                SELECT DISTINCT
                        L_Member_MOR_RK ,
                        H_Member_RK ,
                        H_MOR_Header_RK ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_BRecord_Stage
                WHERE   L_Member_MOR_RK NOT IN ( SELECT L_Member_MOR_RK
                                                 FROM   dbo.L_Member_MOR );
	   
	   -- LOAD Member_MOR C TABLE
        INSERT  INTO dbo.L_Member_MOR
                ( L_Member_MOR_RK ,
                  H_Member_RK ,
                  H_MOR_Header_RK ,
                  LoadDate ,
                  RecordSource
                )
                SELECT DISTINCT
                        L_Member_MOR_RK ,
                        H_Member_RK ,
                        H_MOR_Header_RK ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_CRecord_Stage
                WHERE   L_Member_MOR_RK NOT IN ( SELECT L_Member_MOR_RK
                                                 FROM   dbo.L_Member_MOR );

	
    END;

GO
