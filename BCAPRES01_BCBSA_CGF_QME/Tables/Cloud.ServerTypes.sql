CREATE TABLE [Cloud].[ServerTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServerTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ServerTypes_ServerTypeGuid] DEFAULT (newid()),
[ServerTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[ServerTypes] ADD CONSTRAINT [PK_ServerTypes] PRIMARY KEY CLUSTERED  ([ServerTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServerTypes_Abbrev] ON [Cloud].[ServerTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ServerTypes_Descr] ON [Cloud].[ServerTypes] ([Descr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ServerTypes_ServerTypeGuid] ON [Cloud].[ServerTypes] ([ServerTypeGuid]) ON [PRIMARY]
GO
