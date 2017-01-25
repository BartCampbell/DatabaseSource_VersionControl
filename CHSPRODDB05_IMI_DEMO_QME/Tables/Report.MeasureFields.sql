CREATE TABLE [Report].[MeasureFields]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldID] [tinyint] NOT NULL,
[MeasureID] [int] NOT NULL,
[SortOrder] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Report].[MeasureFields] ADD CONSTRAINT [PK_MeasureFields] PRIMARY KEY CLUSTERED  ([FieldID], [MeasureID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureFields] ON [Report].[MeasureFields] ([MeasureID], [SortOrder]) ON [PRIMARY]
GO
