SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
-- ============================================= 
-- Author:	     Travis Parker 
-- Create date:	02/23/2017 
-- Description:	Load TRR link data to the DV from Staging  
-- ============================================= 
CREATE PROCEDURE [dbo].[spDV_TRR_LoadLinks] 
	-- Add the parameters for the stored procedure here 
AS 
    BEGIN 
 
    DECLARE @CurrentDate DATETIME = GETDATE()  
 
        SET NOCOUNT ON; 
 
	   -- LOAD MemberTRR TABLE 
        INSERT  INTO dbo.L_MemberTRR 
                ( L_MemberTRR_RK , 
                  H_Member_RK , 
                  H_TRR_RK , 
                  LoadDate , 
                  RecordSource 
                ) 
                SELECT DISTINCT 
                        L_MemberTRR_RK , 
                        H_Member_RK , 
                        H_TRR_RK , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRStaging 
                WHERE   L_MemberTRR_RK NOT IN ( SELECT  L_MemberTRR_RK 
                                                FROM    dbo.L_MemberTRR ) 
                        AND H_Member_RK IS NOT NULL; 
	    
	   -- LOAD MemberTRRVerbatim TABLE 
        INSERT  INTO dbo.L_MemberTRRVerbatim 
                ( L_MemberTRRVerbatim_RK , 
                  H_Member_RK , 
                  H_TRRVerbatim_RK , 
                  LoadDate , 
                  RecordSource 
                ) 
                SELECT DISTINCT 
                        L_MemberTRRVerbatim_RK , 
                        H_Member_RK , 
                        H_TRRVerbatim_RK , 
                        @CurrentDate , 
                        FileName 
                FROM    CHSStaging.dbo.TRRVerbatimStaging 
                WHERE   L_MemberTRRVerbatim_RK NOT IN ( SELECT  L_MemberTRRVerbatim_RK 
                                                        FROM    dbo.L_MemberTRRVerbatim ) 
                        AND H_Member_RK IS NOT NULL; 
	    
	   	 
    END; 
 
 
 
GO
