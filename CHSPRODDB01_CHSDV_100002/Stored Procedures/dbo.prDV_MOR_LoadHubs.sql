SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Load MOR hub data to the DV from Staging 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MOR_LoadHubs]
	-- Add the parameters for the stored procedure here
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

	   -- LOAD MOR HEADER TABLE
        INSERT  INTO dbo.H_MOR_Header
                ( H_MOR_Header_RK ,
                  RecordTypeCode ,
                  ContractNumber ,
                  RunDate ,
                  PaymentYearandMonth ,
                  LoadDate ,
                  RecordSource
	           )
                SELECT DISTINCT
                        H_MOR_Header_RK ,
                        RecordTypeCode ,
                        ContractNumber ,
                        RunDate ,
                        PaymentYearandMonth ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_Header_Stage
                WHERE   H_MOR_Header_RK NOT IN ( SELECT H_MOR_Header_RK
                                                 FROM   dbo.H_MOR_Header );

	   
	   ---- LOAD NEW MEMBERS
        INSERT  INTO dbo.H_Member
                ( H_Member_RK ,
                  Member_BK ,
                  ClientMemberID ,
                  LoadDate ,
                  RecordSource
                )
                SELECT  DISTINCT
                        H_Member_RK ,
                        CentauriMemberID ,
                        ClientMemberID ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_ARecord_Stage
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK
                                             FROM   dbo.H_Member );
	   
	   ---- LOAD NEW MEMBERS
        INSERT  INTO dbo.H_Member
                ( H_Member_RK ,
                  Member_BK ,
                  ClientMemberID ,
                  LoadDate ,
                  RecordSource
                )
                SELECT  DISTINCT
                        H_Member_RK ,
                        CentauriMemberID ,
                        ClientMemberID ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_BRecord_Stage
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK
                                             FROM   dbo.H_Member );
	   
	   ---- LOAD NEW MEMBERS
        INSERT  INTO dbo.H_Member
                ( H_Member_RK ,
                  Member_BK ,
                  ClientMemberID ,
                  LoadDate ,
                  RecordSource
                )
                SELECT  DISTINCT
                        H_Member_RK ,
                        CentauriMemberID ,
                        ClientMemberID ,
                        LoadDate ,
                        RecordSource
                FROM    CHSStaging.mor.MOR_CRecord_Stage
                WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK
                                             FROM   dbo.H_Member );

	
    END;

GO
