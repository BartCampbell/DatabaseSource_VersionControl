SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/07/2016
-- Description:	merges the stage to dim for NoteText for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeNoteText
-- =============================================
CREATE PROC [dbo].[spAdvMergeNoteText]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.NoteText AS t
        USING
            (SELECT [CentauriNoteTextid]
					,[NoteText]
				  ,[IsDiagnosisNote]
				  ,[IsChartNote]
				  ,[Client_PK]
				  ,[NoteType]
				  ,[NoteType_PK]				
			  FROM  stage.NoteText_ADV
            ) AS s
        ON t.CentauriNoteTextID = s.CentauriNoteTextID
        WHEN MATCHED AND ( ISNULL(t.[NoteText],'') <> ISNULL(s.[NoteText],'')
                           OR ISNULL(t.[IsDiagnosisNote],0) <> ISNULL(s.[IsDiagnosisNote],0)
                           OR ISNULL(t.[IsChartNote],0) <> ISNULL(s.[IsChartNote],0)
                           OR ISNULL(t.[Client_PK],0) <> ISNULL(s.[Client_PK],0)
						   OR ISNULL(t.[NoteType],'') <> ISNULL(s.[NoteType],'')
						   OR ISNULL(t.[NoteType_PK],0) <> ISNULL(s.[NoteType_PK],0)
                         ) THEN
            UPDATE SET
                    t.NoteText = s.NoteText ,
                    t.IsDiagnosisNote = s.IsDiagnosisNote ,
                    t.IsChartNote = s.IsChartNote ,
                    t.Client_PK = s.Client_PK ,
					t.NoteType = s.NoteType ,
					t.NoteType_PK = s.NoteType_PK ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriNoteTextID ,
                     NoteText ,
                     IsDiagnosisNote ,
                     IsChartNote ,
                     Client_PK,
					 NoteType,					
					 NoteType_PK
                   )
            VALUES ( CentauriNoteTextID ,
                     NoteText ,
                     IsDiagnosisNote ,
                     IsChartNote ,
                     Client_PK,
					 NoteType,					
					 NoteType_PK
                   );

    END;     


GO
