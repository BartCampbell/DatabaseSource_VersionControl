CREATE TABLE [dbo].[PortalResource]
(
[PortalResourceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalResource_PortalResourceID] DEFAULT (newid()),
[ResourceType] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CultureCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResourceKey] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResourceValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalResource] ADD CONSTRAINT [PK_PortalResource] PRIMARY KEY CLUSTERED  ([PortalResourceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_PortalResource] ON [dbo].[PortalResource] ([ResourceType], [CultureCode], [ResourceKey]) ON [PRIMARY]
GO
