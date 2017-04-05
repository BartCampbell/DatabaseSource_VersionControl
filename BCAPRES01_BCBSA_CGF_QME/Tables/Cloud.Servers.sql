CREATE TABLE [Cloud].[Servers]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL,
[Location] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServerGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Servers_ServerGuid] DEFAULT (newid()),
[ServerID] [smallint] NOT NULL IDENTITY(1, 1),
[ServerTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[Servers] ADD CONSTRAINT [PK_Servers] PRIMARY KEY CLUSTERED  ([ServerID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Servers_ServerGuid] ON [Cloud].[Servers] ([ServerGuid]) ON [PRIMARY]
GO
