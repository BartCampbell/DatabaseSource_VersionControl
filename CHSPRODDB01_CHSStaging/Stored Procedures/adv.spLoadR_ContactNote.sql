SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
-- Description:	Load the R_AdvanceContactNote reference table and pull back the hashContactNotekey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_ContactNote] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_AdvanceContactNote]
           ([ClientID]
           ,[ClientContactNoteID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ContactNote_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblContactNoteStage a
		LEFT OUTER JOIN CHSDV.dbo.R_AdvanceContactNote b 
		ON a.ContactNote_PK = b.ClientContactNoteID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientContactNoteID IS NULL;

UPDATE  CHSStaging.adv.tblContactNoteStage
SET     ContactNoteHashKey = b.ContactNoteHashKey
FROM    CHSStaging.adv.tblContactNoteStage a
        INNER JOIN CHSDV.dbo.R_AdvanceContactNote b ON a.ContactNote_PK = b.ClientContactNoteID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblContactNoteStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblContactNoteStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblContactNoteStage
SET  CNI = b.CentauriContactNoteID
FROM    CHSStaging.adv.tblContactNoteStage a
        INNER JOIN CHSDV.dbo.R_AdvanceContactNote b ON a.ContactNote_PK = b.ClientContactNoteID
                                           AND a.CCI = b.ClientID;

INSERT INTO CHSDV.[dbo].[R_AdvanceContactNotesOffice]
           ([ClientID]
           ,[ClientContactNotesOfficeID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[ContactNotesOffice_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblContactNotesOfficeStage a
		LEFT OUTER JOIN CHSDV.dbo.R_AdvanceContactNotesOffice b 
		ON a.ContactNotesOffice_PK = b.ClientContactNotesOfficeID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientContactNotesOfficeID IS NULL;

UPDATE  CHSStaging.adv.tblContactNotesOfficeStage
SET     ContactNotesOfficeHashKey = b.ContactNotesOfficeHashKey
FROM    CHSStaging.adv.tblContactNotesOfficeStage a
        INNER JOIN CHSDV.dbo.R_AdvanceContactNotesOffice b ON a.ContactNotesOffice_PK = b.ClientContactNotesOfficeID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblContactNotesOfficeStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblContactNotesOfficeStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblContactNotesOfficeStage
SET  CNI = b.CentauriContactNotesOfficeID
FROM    CHSStaging.adv.tblContactNotesOfficeStage a
        INNER JOIN CHSDV.dbo.R_AdvanceContactNotesOffice b ON a.ContactNotesOffice_PK = b.ClientContactNotesOfficeID
                                           AND a.CCI = b.ClientID;

END


GO
