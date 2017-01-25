CREATE TABLE [Ncqa].[RRU_ValueTypes]
(
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnNameCapped] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsParent] AS ([Ncqa].[IsParentRRUValueType]([RRUValTypeID])),
[ParentID] [tinyint] NULL,
[RRUValTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_ValueTypes_RRUValTypeGuid] DEFAULT (newid()),
[RRUValTypeID] [tinyint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_ValueTypes] ADD CONSTRAINT [PK_Ncqa_RRU_ValueTypes] PRIMARY KEY CLUSTERED  ([RRUValTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ValueTypes_ColumnName] ON [Ncqa].[RRU_ValueTypes] ([ColumnName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_ValueTypes_RRUValTypeGuid] ON [Ncqa].[RRU_ValueTypes] ([RRUValTypeGuid]) ON [PRIMARY]
GO
