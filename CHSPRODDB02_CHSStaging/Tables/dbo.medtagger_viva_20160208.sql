CREATE TABLE [dbo].[medtagger_viva_20160208]
(
[Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medphrase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Processed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberID] ON [dbo].[medtagger_viva_20160208] ([MemberId]) INCLUDE ([RecordID]) ON [PRIMARY]
GO
