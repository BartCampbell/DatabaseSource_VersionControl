CREATE TABLE [dbo].[PortalTemplate]
(
[PortalTemplateID] [uniqueidentifier] NOT NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalTemplate_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEnabled] [bit] NULL CONSTRAINT [DF_PortalTemplate_IsEnabled] DEFAULT ((0)),
[PortalTemplateText] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalTemplate] ADD CONSTRAINT [PK_PortalTemplate] PRIMARY KEY CLUSTERED  ([PortalTemplateID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PortalTemplate_Name] ON [dbo].[PortalTemplate] ([Name], [PortalSiteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalTemplate] ADD CONSTRAINT [FK_PortalTemplate_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
