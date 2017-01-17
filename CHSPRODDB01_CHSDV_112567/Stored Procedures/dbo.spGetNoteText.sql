SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/014/2016 Replacing RecordEndDate on lInk with Link Satellite PJ
-- Description:	Gets NoteText details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetNoteText]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20),
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.NoteText_BK AS CentauriNoteTextID ,
                s.[NoteText] ,
	s.[IsDiagnosisNote] ,
	s.[IsChartNote] ,
	s.[Client_PK] ,
	o.ClientNoteTypeID AS NoteType_PK,
	d.NoteType
        FROM    [dbo].[H_NoteText] h
                INNER JOIN [dbo].[S_NoteTextDetail] s ON s.H_NoteText_RK = h.H_NoteText_RK AND s.RecordEndDate IS NULL
				LEFT OUTER JOIN (SELECT lt.H_NoteText_RK,lt.H_NoteType_RK,tl.LoadDate FROM dbo.L_NoteTextType lt 
				INNER JOIN dbo.LS_NoteTextType tl ON tl.L_NoteTextType_RK = lt.L_NoteTextType_RK AND tl.RecordEndDate IS NULL) t
				ON t.H_NoteText_RK = h.H_NoteText_RK 
				LEFT OUTER JOIN dbo.H_NoteType o ON o.H_NoteType_RK = t.H_NoteType_RK
				LEFT OUTER JOIN dbo.S_NoteTypeDetail d ON d.H_NoteType_RK = o.H_NoteType_RK AND d.RecordEndDate IS NULL

        WHERE   s.LoadDate > @LoadDate OR t.LoadDate>@LoadDate OR d.LoadDate>@LoadDate;

    END;



GO
