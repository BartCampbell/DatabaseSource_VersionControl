SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Load the R_IssueResponse reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_IssueResponse] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceIssueResponse]
                ( [ClientID] ,
                  [ClientIssueResponseID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[IssueResponse_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblIssueResponseStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceIssueResponse] b ON a.IssueResponse_PK = b.ClientIssueResponseID
                                                              AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientIssueResponseID IS NULL;

        UPDATE  CHSStaging.adv.tblIssueResponseStage
        SET     IssueResponseHashKey = b.IssueResponseHashKey
        FROM    CHSStaging.adv.tblIssueResponseStage a
                INNER JOIN CHSDV.dbo.R_AdvanceIssueResponse b ON a.IssueResponse_PK = b.ClientIssueResponseID
                                                              AND a.CCI = b.ClientID;


     


        UPDATE  CHSStaging.adv.tblIssueResponseStage
        SET     CRI = b.CentauriIssueResponseID
        FROM    CHSStaging.adv.tblIssueResponseStage a
                INNER JOIN CHSDV.dbo.R_AdvanceIssueResponse b ON a.IssueResponse_PK = b.ClientIssueResponseID
                                                              AND a.CCI = b.ClientID;


										   


    END;
GO
