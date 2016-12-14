CREATE TABLE [dbo].[viva_folders]
(
[FolderPath] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedPhrase] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_viva_folders_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_viva_folders] ON [dbo].[viva_folders] ([FolderPath]) ON [PRIMARY]
GO
