CREATE TABLE [dbo].[viva_highlights]
(
[RecordID] [int] NOT NULL,
[fileid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedPhrase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FolderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_viva_highlights] ON [dbo].[viva_highlights] ([MemberID]) ON [PRIMARY]
GO
