CREATE TABLE [Batch].[DataSetProcedures]
(
[DataSetID] [int] NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_DataSetProcedures_IsEnabled] DEFAULT ((1)),
[ProcID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataSetProcedures] ADD CONSTRAINT [PK_DataSetProcedures] PRIMARY KEY CLUSTERED  ([DataSetID], [ProcID]) ON [PRIMARY]
GO
