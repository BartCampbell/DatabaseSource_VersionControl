CREATE TABLE [Batch].[DataSetSources]
(
[CountRecords] [bigint] NOT NULL CONSTRAINT [DF_DataSetSources_CountRecords] DEFAULT ((0)),
[CountSupplemental] [bigint] NOT NULL CONSTRAINT [DF_DataSetSources_CountSupplemental] DEFAULT ((0)),
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DataSetSources_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DataSetSources_CreatedDate] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_DataSetSources_CreatedSpId] DEFAULT (@@spid),
[DataSetID] [int] NOT NULL,
[DataSource] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSourceGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataSetSources_DataSourceGuid] DEFAULT (newid()),
[DataSourceID] [int] NOT NULL IDENTITY(1, 1),
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSupplemental] [bit] NOT NULL CONSTRAINT [DF_DataSetSources_IsSupplemental] DEFAULT ((0)),
[SourceSchema] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceTable] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataSetSources] ADD CONSTRAINT [PK_Batch_DataSetSources] PRIMARY KEY CLUSTERED  ([DataSourceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batch_DataSetSources] ON [Batch].[DataSetSources] ([DataSetID], [DataSource], [IsSupplemental], [SourceSchema], [SourceTable]) INCLUDE ([DataSourceGuid], [DataSourceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batch_DataSetSources_DataSourceGuid] ON [Batch].[DataSetSources] ([DataSourceGuid]) INCLUDE ([DataSetID], [DataSourceID]) ON [PRIMARY]
GO
