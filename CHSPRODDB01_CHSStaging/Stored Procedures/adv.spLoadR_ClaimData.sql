SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load the R_ClaimData reference table and pull back the hashClaimDatakey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_ClaimData] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_ClaimData]
           ([ClientID]
           ,[ClientClaimDataID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ClaimData_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblClaimDataStage a
		LEFT OUTER JOIN CHSDV.dbo.R_ClaimData b 
		ON a.ClaimData_PK = b.ClientClaimDataID AND b.RecordSource = a.RecordSource
		WHERE a.CCI = @CCI AND b.ClientClaimDataID IS NULL ;

UPDATE  CHSStaging.adv.tblClaimDataStage
SET     ClaimDataHashKey = b.ClaimDataHashKey
FROM    CHSStaging.adv.tblClaimDataStage a
        INNER JOIN CHSDV.dbo.R_ClaimData b ON a.ClaimData_PK = b.ClientClaimDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;


UPDATE  CHSStaging.adv.tblClaimDataStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblClaimDataStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID ;


UPDATE  CHSStaging.adv.tblClaimDataStage
SET  CDI = b.CentauriClaimDataID
FROM    CHSStaging.adv.tblClaimDataStage a
        INNER JOIN CHSDV.dbo.R_ClaimData b ON a.ClaimData_PK = b.ClientClaimDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;




END
GO
