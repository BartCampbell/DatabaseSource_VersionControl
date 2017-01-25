CREATE TABLE [dbo].[PortalDocumentStatus]
(
[PortalDocumentStatusID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description ] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalDocumentStatus_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalDocumentStatus_IsDefault] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentStatus] ADD CONSTRAINT [PortalDocumentStatus_PK] PRIMARY KEY CLUSTERED  ([PortalDocumentStatusID]) ON [PRIMARY]
GO
