CREATE TABLE [CGF].[ProductLines]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitSeed] [tinyint] NULL,
[BitValue] [bigint] NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLineGuid] [uniqueidentifier] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ProductLine] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductLines_ProductLine] ON [CGF].[ProductLines] ([ProductLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductLines] ON [CGF].[ProductLines] ([ProductLineGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_ProductLines_ProductLine] ON [CGF].[ProductLines] ([ProductLine])
GO
CREATE STATISTICS [spIX_ProductLines] ON [CGF].[ProductLines] ([ProductLineGuid])
GO
