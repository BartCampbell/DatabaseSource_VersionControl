SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
-- ============================================= 
-- Author:		Travis Parker 
-- Create date:	02/23/2017 
-- Description:	LOAD HUBS ASSOCIATED WITH THE TRR 
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_TRR_LoadHubs] 
-- Add the parameters for the stored procedure here 
AS 
    BEGIN 
 
	DECLARE @CurrentDate DATETIME = GETDATE()  
 
        SET NOCOUNT ON; 
 
	   --LOAD TRR HUB 
        INSERT  INTO dbo.H_TRR 
                ( H_TRR_RK , 
                  TRR_BK , 
                  LoadDate , 
                  RecordSource 
                ) 
                SELECT DISTINCT 
                        H_TRR_RK , 
                        TRR_BK , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRStaging 
                WHERE   H_TRR_RK NOT IN ( SELECT    H_TRR_RK 
                                          FROM      dbo.H_TRR ); 
 
	   --LOAD TRRVerbatim HUB 
        INSERT  INTO dbo.H_TRRVerbatim 
                ( H_TRRVerbatim_RK , 
                  TRRVerbatim_BK , 
                  LoadDate , 
                  RecordSource 
                ) 
                SELECT DISTINCT 
                        H_TRRVerbatim_RK , 
                        TRRVerbatim_BK , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging 
                WHERE   H_TRRVerbatim_RK NOT IN ( SELECT    H_TRRVerbatim_RK 
                                                  FROM      dbo.H_TRRVerbatim ); 
 
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
                        ISNULL(ClientMemberID, '') , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRStaging 
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK 
                                             FROM   dbo.H_Member ) 
                        AND H_Member_RK IS NOT NULL; 
	    
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
                        ISNULL(ClientMemberID, '') , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging 
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK 
                                             FROM   dbo.H_Member ) 
                        AND H_Member_RK IS NOT NULL; 
 
 
    END; 
 
GO
