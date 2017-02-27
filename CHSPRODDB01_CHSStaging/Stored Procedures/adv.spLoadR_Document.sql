SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load the R_Document reference table and pull back the hashDocumentkey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_Document] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_DocumentType]
           ([ClientID]
           ,[ClientDocumentTypeID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[DocumentType_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblDocumentTypeStage a
		LEFT OUTER JOIN CHSDV.dbo.R_DocumentType b 
		ON a.DocumentType_PK = b.ClientDocumentTypeID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientDocumentTypeID IS NULL;

UPDATE  CHSStaging.adv.tblDocumentTypeStage
SET     DocumentTypeHashKey = b.DocumentTypeHashKey
FROM    CHSStaging.adv.tblDocumentTypeStage a
        INNER JOIN CHSDV.dbo.R_DocumentType b ON a.DocumentType_PK = b.ClientDocumentTypeID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblDocumentTypeStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblDocumentTypeStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblDocumentTypeStage
SET  CDI = b.CentauriDocumentTypeID
FROM    CHSStaging.adv.tblDocumentTypeStage a
        INNER JOIN CHSDV.dbo.R_DocumentType b ON a.DocumentType_PK = b.ClientDocumentTypeID AND b.RecordSource = a.RecordSource
                                           AND a.CCI = b.ClientID;




END
GO
