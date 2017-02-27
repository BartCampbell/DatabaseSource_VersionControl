SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/15/2016
-- Description:	Load the R_ExtractionQueue reference table and pull back the hashExtractionQueuekey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_ExtractionQueue] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_ExtractionQueue]
           ([ClientID]
           ,[ClientExtractionQueueID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ExtractionQueue_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblExtractionQueueStage a
		LEFT OUTER JOIN CHSDV.dbo.R_ExtractionQueue b 
		ON a.ExtractionQueue_PK = b.ClientExtractionQueueID AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource
		WHERE a.CCI = @CCI AND b.ClientExtractionQueueID IS NULL;

UPDATE  CHSStaging.adv.tblExtractionQueueStage
SET     ExtractionQueueHashKey = b.ExtractionQueueHashKey, CEI = b.CentauriExtractionQueueID
FROM    CHSStaging.adv.tblExtractionQueueStage a
        INNER JOIN CHSDV.dbo.R_ExtractionQueue b ON a.ExtractionQueue_PK = b.ClientExtractionQueueID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblExtractionQueueStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblExtractionQueueStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblExtractionQueueStage
SET  CEI = b.CentauriExtractionQueueID
FROM    CHSStaging.adv.tblExtractionQueueStage a
        INNER JOIN CHSDV.dbo.R_ExtractionQueue b ON a.ExtractionQueue_PK = b.ClientExtractionQueueID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;




END
GO
