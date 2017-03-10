CREATE TABLE [dbo].[MedicalRecordBCS]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[EvidenceType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MammogramFlag] [bit] NULL,
[BilateralMastectomyFlag] [bit] NULL,
[DualSeperateUnilateralMastectomiesFlag] [bit] NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedUser] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/12/2011
-- Description:	This is a temporary trigger that forces the scoring of BCS on record changes.  
--				There is an intermittent issue as of 12/12/2011 where the application does not call ScoreBCS correctly.
--				(FYI:  This trigger should not hurt if it is left in place after the application issue is resolved).
-- =============================================
CREATE TRIGGER [dbo].[MedicalRecordBCS_RunScoreBCS]
   ON  [dbo].[MedicalRecordBCS]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @CmdText nvarchar(MAX);

    WITH ScoreMembers AS 
    (
		SELECT DISTINCT
				P.MemberID 
		FROM	INSERTED AS t
				INNER JOIN dbo.Pursuit AS P
						ON t.PursuitID = P.PursuitID
		UNION 
		SELECT DISTINCT
				P.MemberID 
		FROM	DELETED AS t
				INNER JOIN dbo.Pursuit AS P
						ON t.PursuitID = P.PursuitID
	)
	SELECT	@CmdText = ISNULL(@CmdText + CHAR(13) + CHAR(10), '') + 
			'EXEC [dbo].[ScoreBCS] @MemberID = ' + CAST(t.MemberID AS nvarchar(MAX)) + ';'
	FROM	ScoreMembers AS t;
	
    EXEC (@CmdText);
    
END
GO
ALTER TABLE [dbo].[MedicalRecordBCS] ADD CONSTRAINT [PK__MedicalRecordBCS__7306036C] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordBCS_PursuitEventID] ON [dbo].[MedicalRecordBCS] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordBCS] ON [dbo].[MedicalRecordBCS] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordBCS] ADD CONSTRAINT [MedicalRecordBCS_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordBCS] ADD CONSTRAINT [MedicalRecordBCS_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
