SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Description:	Load the R_Project reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_Project] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceProject]
                ( [ClientID] ,
                  [ClientProjectID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[Project_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblProjectStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceProject] b ON a.Project_PK = b.ClientProjectID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientProjectID IS NULL;

        UPDATE  CHSStaging.adv.tblProjectStage
        SET     ProjectHashKey = b.ProjectHashKey
        FROM    CHSStaging.adv.tblProjectStage a
                INNER JOIN CHSDV.dbo.R_AdvanceProject b ON a.Project_PK = b.ClientProjectID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblProjectStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblProjectStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;





        UPDATE  CHSStaging.adv.tblProjectStage
        SET     CPI = b.CentauriProjectID
        FROM    CHSStaging.adv.tblProjectStage a
                INNER JOIN CHSDV.dbo.R_AdvanceProject b ON a.Project_PK = b.ClientProjectID
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
