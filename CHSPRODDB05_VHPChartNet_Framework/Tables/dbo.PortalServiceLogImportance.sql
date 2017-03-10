CREATE TABLE [dbo].[PortalServiceLogImportance]
(
[PortalServiceLogImportanceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogImportance_PortalServiceLogImportanceID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogImportance_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogImportance_IsDefault] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogImportance] ADD CONSTRAINT [PK_PortalServiceLogImportance] PRIMARY KEY CLUSTERED  ([PortalServiceLogImportanceID]) ON [PRIMARY]
GO
