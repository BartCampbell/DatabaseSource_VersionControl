CREATE TABLE [dbo].[viva_final]
(
[recordid] [int] NOT NULL,
[fileid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[memberid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[membername] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[medphrase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[folderpath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_viva_final] ON [dbo].[viva_final] ([fileid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_viva_final_1] ON [dbo].[viva_final] ([medphrase]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberName] ON [dbo].[viva_final] ([membername]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RecordID] ON [dbo].[viva_final] ([recordid]) INCLUDE ([fileid], [folderpath], [medphrase], [memberid], [membername]) ON [PRIMARY]
GO
