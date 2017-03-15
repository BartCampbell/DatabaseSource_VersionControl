CREATE TABLE [dbo].[testRTFImport]
(
[PatientName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[filetext] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileHash] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileHash] ON [dbo].[testRTFImport] ([FileHash]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_testRTFImport] ON [dbo].[testRTFImport] ([FileID]) ON [PRIMARY]
GO
