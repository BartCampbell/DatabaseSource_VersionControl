SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load the R_CodedSource reference table and pull back the hashCodedSourcekey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_CodedSource] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_CodedSource]
           ([ClientID]
           ,[ClientCodedSourceID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[CodedSource_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblCodedSourceStage a
		LEFT OUTER JOIN CHSDV.dbo.R_CodedSource b 
		ON a.CodedSource_PK = b.ClientCodedSourceID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientCodedSourceID IS NULL;

UPDATE  CHSStaging.adv.tblCodedSourceStage
SET     CodedSourceHashKey = b.CodedSourceHashKey
FROM    CHSStaging.adv.tblCodedSourceStage a
        INNER JOIN CHSDV.dbo.R_CodedSource b ON a.CodedSource_PK = b.ClientCodedSourceID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblCodedSourceStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblCodedSourceStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblCodedSourceStage
SET  CSI = b.CentauriCodedSourceID
FROM    CHSStaging.adv.tblCodedSourceStage a
        INNER JOIN CHSDV.dbo.R_CodedSource b ON a.CodedSource_PK = b.ClientCodedSourceID
                                           AND a.CCI = b.ClientID;




END
GO
