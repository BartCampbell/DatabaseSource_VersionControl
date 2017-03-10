CREATE TABLE [dbo].[PortalEmailTemplate]
(
[PortalEmailTemplateID] [uniqueidentifier] NOT NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalEmailTemplate_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectTemplate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HtmlMessageTemplate] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TextMessageTemplate] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalEmailTemplate] ADD CONSTRAINT [PK_PortalEmailTemplate] PRIMARY KEY CLUSTERED  ([PortalEmailTemplateID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalEmailTemplate] ADD CONSTRAINT [IX_PortalEmailTemplate_Name] UNIQUE NONCLUSTERED  ([Name], [PortalSiteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalEmailTemplate] ADD CONSTRAINT [FK_PortalEmailTemplate_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
