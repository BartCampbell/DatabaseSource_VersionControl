CREATE TABLE [Ncqa].[RRU_ADSC]
(
[Abbrev] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ADSCGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_ADSC_ADSCGuid] DEFAULT (newid()),
[ADSCID] [smallint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_ADSC] ADD CONSTRAINT [PK_Ncqa_RRU_ADSC] PRIMARY KEY CLUSTERED  ([ADSCID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSC_Abbrev] ON [Ncqa].[RRU_ADSC] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSC_ADSCGuid] ON [Ncqa].[RRU_ADSC] ([ADSCGuid]) ON [PRIMARY]
GO
