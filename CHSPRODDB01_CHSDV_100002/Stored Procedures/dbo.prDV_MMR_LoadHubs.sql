SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date:	1/14/2016
-- Description:	LOAD HUBS ASSOCIATED WITH THE MMR
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MMR_LoadHubs]
-- Add the parameters for the stored procedure here
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

	   --LOAD MMR HUB
        INSERT  INTO dbo.H_MMR
                ( H_MMR_RK ,
                  MMR_BK ,
			   Sequence ,
                  LoadDate ,
                  RecordSource
	           )
                SELECT  H_MMR_RK ,
                        MMR_BK ,
				    [dbo].[ufn_parsefind](MMR_BK,':',6) AS Sequence,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mmr.MMR_Stage
                WHERE   H_MMR_RK NOT IN ( SELECT    H_MMR_RK
                                          FROM      dbo.H_MMR );
	   --LOAD MEMBER HUB
        INSERT  INTO dbo.H_Member
                ( H_Member_RK ,
                  Member_BK ,
                  ClientMemberID ,
                  LoadDate ,
                  RecordSource
	           )
                SELECT DISTINCT
                        H_Member_RK ,
                        CentauriMemberID ,
                        ClientMemberID ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mmr.MMR_Stage
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK
                                             FROM   dbo.H_Member ); 


    END;
GO
