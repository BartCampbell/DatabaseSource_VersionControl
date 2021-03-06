CREATE TABLE [Ncqa].[RRU_ADSCCodes]
(
[ADSCID] [smallint] NOT NULL,
[ADSCCodeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_ADSCCodes_ADSCCodeGuid] DEFAULT (newid()),
[ADSCCodeID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_ADSCCodes] ADD CONSTRAINT [PK_Ncqa_RRU_ADSCCodes] PRIMARY KEY CLUSTERED  ([ADSCCodeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSCCodes_ADSCCodeGuid] ON [Ncqa].[RRU_ADSCCodes] ([ADSCCodeGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSCCodes_Code] ON [Ncqa].[RRU_ADSCCodes] ([MeasureSetID], [ADSCCodeID], [Code], [CodeTypeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_RRU_ADSCCodes_CodeID] ON [Ncqa].[RRU_ADSCCodes] ([MeasureSetID], [CodeID]) INCLUDE ([ADSCCodeID], [ADSCID]) WHERE ([CodeID] IS NOT NULL) ON [PRIMARY]
GO
