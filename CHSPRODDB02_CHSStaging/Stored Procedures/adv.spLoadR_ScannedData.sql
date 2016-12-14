SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load the R_ScannedData reference table and pull back the hashScannedDatakey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_ScannedData] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_ScannedData]
           ([ClientID]
           ,[ClientScannedDataID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ScannedData_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblScannedDataStage a
		LEFT OUTER JOIN CHSDV.dbo.R_ScannedData b 
		ON a.ScannedData_PK = b.ClientScannedDataID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientScannedDataID IS NULL;

UPDATE  CHSStaging.adv.tblScannedDataStage
SET     ScannedDataHashKey = b.ScannedDataHashKey
FROM    CHSStaging.adv.tblScannedDataStage a
        INNER JOIN CHSDV.dbo.R_ScannedData b ON a.ScannedData_PK = b.ClientScannedDataID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblScannedDataStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblScannedDataStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblScannedDataStage
SET  CSI = b.CentauriScannedDataID
FROM    CHSStaging.adv.tblScannedDataStage a
        INNER JOIN CHSDV.dbo.R_ScannedData b ON a.ScannedData_PK = b.ClientScannedDataID
                                           AND a.CCI = b.ClientID;




END
GO
