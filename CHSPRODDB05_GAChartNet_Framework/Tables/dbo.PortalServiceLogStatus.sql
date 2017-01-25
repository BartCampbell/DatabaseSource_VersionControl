CREATE TABLE [dbo].[PortalServiceLogStatus]
(
[PortalServiceLogStatusID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogStatus_PortalServiceLogStatusID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogStatus_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogStatus] ADD CONSTRAINT [PK_PortalServiceLogStatus] PRIMARY KEY CLUSTERED  ([PortalServiceLogStatusID]) ON [PRIMARY]
GO
