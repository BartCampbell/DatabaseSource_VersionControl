CREATE TABLE [Batch].[BatchMeasures]
(
[BatchID] [int] NOT NULL,
[MeasureID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[BatchMeasures] ADD CONSTRAINT [PK_BatchMeasures] PRIMARY KEY CLUSTERED  ([BatchID], [MeasureID]) ON [PRIMARY]
GO
