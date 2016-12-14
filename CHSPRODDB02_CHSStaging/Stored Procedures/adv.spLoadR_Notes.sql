SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
-- Description:	Load the R_Notes reference table and pull back the hashNoteskey
-- =============================================

CREATE PROCEDURE [adv].[spLoadR_Notes] 
	-- Add the parameters for the stored procedure here
@CCI VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO CHSDV.[dbo].[R_NoteText]
           ([ClientID]
           ,[ClientNoteTextID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[NoteText_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblNoteTextStage a
		LEFT OUTER JOIN CHSDV.dbo.R_NoteText b 
		ON a.NoteText_PK = b.ClientNoteTextID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientNoteTextID IS NULL;

UPDATE  CHSStaging.adv.tblNoteTextStage
SET     NoteTextHashKey = b.NoteTextHashKey
FROM    CHSStaging.adv.tblNoteTextStage a
        INNER JOIN CHSDV.dbo.R_NoteText b ON a.NoteText_PK = b.ClientNoteTextID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblNoteTextStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblNoteTextStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblNoteTextStage
SET  CNI = b.CentauriNoteTextID
FROM    CHSStaging.adv.tblNoteTextStage a
        INNER JOIN CHSDV.dbo.R_NoteText b ON a.NoteText_PK = b.ClientNoteTextID
                                           AND a.CCI = b.ClientID;


INSERT INTO CHSDV.[dbo].[R_NoteType]
           ([ClientID]
           ,[ClientNoteTypeID]
           ,[LoadDate]
           ,[RecordSource])
     SELECT  DISTINCT  a.[CCI] ,
                 a.[NoteType_PK],
                a.[LoadDate] ,
                a.[RecordSource]
        FROM    CHSStaging.adv.tblNoteTypeStage a
		LEFT OUTER JOIN CHSDV.dbo.R_NoteType b 
		ON a.NoteType_PK = b.ClientNoteTypeID AND a.CCI = b.ClientID
		WHERE a.CCI = @CCI AND b.ClientNoteTypeID IS NULL;

UPDATE  CHSStaging.adv.tblNoteTypeStage
SET     NoteTypeHashKey = b.NoteTypeHashKey
FROM    CHSStaging.adv.tblNoteTypeStage a
        INNER JOIN CHSDV.dbo.R_NoteType b ON a.NoteType_PK = b.ClientNoteTypeID
                                           AND a.CCI = b.ClientID;


UPDATE  CHSStaging.adv.tblNoteTypeStage
SET     ClientHashKey = b.[ClientHashKey]
FROM    CHSStaging.adv.tblNoteTypeStage a
        INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;


UPDATE  CHSStaging.adv.tblNoteTypeStage
SET  CTI = b.CentauriNoteTypeID
FROM    CHSStaging.adv.tblNoteTypeStage a
        INNER JOIN CHSDV.dbo.R_NoteType b ON a.NoteType_PK = b.ClientNoteTypeID
                                           AND a.CCI = b.ClientID;




END
GO
