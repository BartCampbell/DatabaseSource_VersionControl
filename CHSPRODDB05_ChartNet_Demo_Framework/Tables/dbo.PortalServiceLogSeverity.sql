CREATE TABLE [dbo].[PortalServiceLogSeverity]
(
[PortalServiceLogSeverityID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogSeverity_PortalServiceLogSeverityID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogSeverity_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogSeverity_IsDefault] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogSeverity] ADD CONSTRAINT [PK_PortalServiceLogSeverity] PRIMARY KEY CLUSTERED  ([PortalServiceLogSeverityID]) ON [PRIMARY]
GO
