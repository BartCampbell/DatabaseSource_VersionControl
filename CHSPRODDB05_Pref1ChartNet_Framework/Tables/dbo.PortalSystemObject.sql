CREATE TABLE [dbo].[PortalSystemObject]
(
[ObjectID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSystemObject] ADD CONSTRAINT [PK_PortalSystemObject] PRIMARY KEY CLUSTERED  ([ObjectID]) ON [PRIMARY]
GO
