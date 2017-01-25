CREATE TABLE [dbo].[PortalServiceLogResolutionType]
(
[PortalServiceLogResolutionTypeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogResolutionType_PortalServiceLogResolutionTypeID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogResolutionType_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogResolutionType_IsDefault] DEFAULT ((0)),
[IsOther] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogResolutionType_IsOther] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogResolutionType] ADD CONSTRAINT [PK_PortalServiceLogResolutionType] PRIMARY KEY CLUSTERED  ([PortalServiceLogResolutionTypeID]) ON [PRIMARY]
GO
