CREATE TABLE [Measure].[CustomProcesses]
(
[Descr] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasProcGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CustomProcesses_MeasProcGuid] DEFAULT (newid()),
[MeasProcID] [int] NOT NULL IDENTITY(1, 1),
[MeasProcTypeID] [tinyint] NOT NULL,
[MeasureID] [int] NOT NULL,
[ProcName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunOrder] [int] NOT NULL CONSTRAINT [DF_CustomProcesses_SortOrder] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[CustomProcesses] ADD CONSTRAINT [PK_CustomProcesses] PRIMARY KEY CLUSTERED  ([MeasProcID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CustomProcesses_MeasProcGuid] ON [Measure].[CustomProcesses] ([MeasProcGuid]) ON [PRIMARY]
GO
