CREATE TABLE [CGF].[ResultTypes]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResultTypeGuid] [uniqueidentifier] NOT NULL,
[ResultTypeID] [tinyint] NOT NULL,
[ResultType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ResultTypes] ON [CGF].[ResultTypes] ([ResultTypeGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_ResultTypes] ON [CGF].[ResultTypes] ([ResultTypeGuid])
GO
