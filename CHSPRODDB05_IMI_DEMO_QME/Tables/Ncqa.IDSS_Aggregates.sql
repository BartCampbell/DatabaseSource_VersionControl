CREATE TABLE [Ncqa].[IDSS_Aggregates]
(
[Abbrev] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AggregateGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IDSS_Aggregates_AggregateGuid] DEFAULT (newid()),
[AggregateID] [tinyint] NOT NULL IDENTITY(1, 1),
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[IDSS_Aggregates] ADD CONSTRAINT [PK_IDSS_Aggregates] PRIMARY KEY CLUSTERED  ([AggregateID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IDSS_Aggregates_Abbrev] ON [Ncqa].[IDSS_Aggregates] ([Abbrev]) ON [PRIMARY]
GO
