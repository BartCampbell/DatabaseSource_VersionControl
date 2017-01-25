CREATE TABLE [Log].[ProcessEntryXrefs]
(
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntryXrefGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ProcessEntryXrefs_EntryXrefGuid] DEFAULT (newid()),
[EntryXrefID] [smallint] NOT NULL IDENTITY(1, 1),
[SrcObjectGuid] [uniqueidentifier] NOT NULL,
[SrcObjectID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[ProcessEntryXrefs] ADD CONSTRAINT [PK_Log_ProcessEntryXrefs] PRIMARY KEY CLUSTERED  ([EntryXrefID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_ProcessEntryXrefs_EntryXrefGuids] ON [Log].[ProcessEntryXrefs] ([EntryXrefGuid]) ON [PRIMARY]
GO
