SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load the R_CodedData reference table and pull back the hashCodedDatakey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_CodedData] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_CodedData]
           ([ClientID]
           ,[ClientCodedDataID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[CodedData_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblCodedDataStage a
		LEFT OUTER JOIN CHSDV.dbo.R_CodedData b 
		ON a.CodedData_PK = b.ClientCodedDataID AND b.RecordSource = a.RecordSource
		WHERE a.CCI = @CCI AND b.ClientCodedDataID IS NULL;

UPDATE  CHSStaging.adv.tblCodedDataStage
SET     CodedDataHashKey = b.CodedDataHashKey
FROM    CHSStaging.adv.tblCodedDataStage a
        INNER JOIN CHSDV.dbo.R_CodedData b ON a.CodedData_PK = b.ClientCodedDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;


UPDATE  CHSStaging.adv.tblCodedDataStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblCodedDataStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblCodedDataStage
SET  CDI = b.CentauriCodedDataID
FROM    CHSStaging.adv.tblCodedDataStage a
        INNER JOIN CHSDV.dbo.R_CodedData b ON a.CodedData_PK = b.ClientCodedDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;

INSERT INTO CHSDV.[dbo].[R_CodedData]
           ([ClientID]
           ,[ClientCodedDataID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[CodedData_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblCodedDataQAStage a
		LEFT OUTER JOIN CHSDV.dbo.R_CodedData b 
		ON a.CodedData_PK = b.ClientCodedDataID AND b.RecordSource = a.RecordSource
		WHERE a.CCI = @CCI AND b.ClientCodedDataID IS NULL;

UPDATE  CHSStaging.adv.tblCodedDataQAStage
SET     CodedDataHashKey = b.CodedDataHashKey
FROM    CHSStaging.adv.tblCodedDataQAStage a
        INNER JOIN CHSDV.dbo.R_CodedData b ON a.CodedData_PK = b.ClientCodedDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;


UPDATE  CHSStaging.adv.tblCodedDataStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblCodedDataQAStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID ;


UPDATE  CHSStaging.adv.tblCodedDataQAStage
SET  CDI = b.CentauriCodedDataID
FROM    CHSStaging.adv.tblCodedDataQAStage a
        INNER JOIN CHSDV.dbo.R_CodedData b ON a.CodedData_PK = b.ClientCodedDataID
                                           AND a.CCI = b.ClientID AND b.RecordSource = a.RecordSource;

END

GO
