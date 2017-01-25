CREATE TABLE [CGF].[AgeBands]
(
[AgeBandID] [int] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBandGuid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AgeBands] ON [CGF].[AgeBands] ([AgeBandGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_AgeBands] ON [CGF].[AgeBands] ([AgeBandGuid])
GO
