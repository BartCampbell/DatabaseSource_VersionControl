CREATE TABLE [dbo].[X12CodeList]
(
[ElementId] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Definition] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[X12CodeList] ADD CONSTRAINT [PK_X12CodeList] PRIMARY KEY CLUSTERED  ([ElementId], [Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_X12CodeList_5_704721563__K3] ON [dbo].[X12CodeList] ([Definition]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_X12CodeList_5_704721563__K1] ON [dbo].[X12CodeList] ([ElementId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_704721563_2_3] ON [dbo].[X12CodeList] ([Code], [Definition])
GO
CREATE STATISTICS [stat_704721563_3_1] ON [dbo].[X12CodeList] ([Definition], [ElementId])
GO
CREATE STATISTICS [stat_704721563_1_2_3] ON [dbo].[X12CodeList] ([ElementId], [Code], [Definition])
GO
