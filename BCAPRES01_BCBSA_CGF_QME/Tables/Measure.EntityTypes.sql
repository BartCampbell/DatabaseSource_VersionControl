CREATE TABLE [Measure].[EntityTypes]
(
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EntityTypes_EntityTypeGuid] DEFAULT (newid()),
[EntityTypeID] [tinyint] NOT NULL,
[ProcName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EntityTypes] ADD CONSTRAINT [PK_EntityTypes] PRIMARY KEY CLUSTERED  ([EntityTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EntityTypes_EntityTypeGuid] ON [Measure].[EntityTypes] ([EntityTypeGuid]) ON [PRIMARY]
GO
