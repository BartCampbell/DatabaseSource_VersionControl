CREATE TABLE [Measure].[MappingTypes]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCounter] [bit] NOT NULL CONSTRAINT [DF_MappingTypes_IsCounter] DEFAULT ((0)),
[MapTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MappingTypes_MapTypeGuid] DEFAULT (newid()),
[MapTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MappingTypes] ADD CONSTRAINT [PK_MappingTypes] PRIMARY KEY CLUSTERED  ([MapTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MappingTypes_Descr] ON [Measure].[MappingTypes] ([Descr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MappingTypes_MapTypeGuid] ON [Measure].[MappingTypes] ([MapTypeGuid]) ON [PRIMARY]
GO
