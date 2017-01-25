CREATE TABLE [dbo].[PortalUserRole]
(
[PortalUserID] [uniqueidentifier] NOT NULL,
[PortalRoleID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserRole] ADD CONSTRAINT [PK_PortalUserRole] PRIMARY KEY CLUSTERED  ([PortalRoleID], [PortalUserID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserRole] WITH NOCHECK ADD CONSTRAINT [FK_PortalUserRole_PortalRole] FOREIGN KEY ([PortalRoleID]) REFERENCES [dbo].[PortalRole] ([PortalRoleID])
GO
ALTER TABLE [dbo].[PortalUserRole] WITH NOCHECK ADD CONSTRAINT [FK_PortalUserRole_PortalUser] FOREIGN KEY ([PortalUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
