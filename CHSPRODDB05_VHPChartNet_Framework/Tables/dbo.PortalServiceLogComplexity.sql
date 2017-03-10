CREATE TABLE [dbo].[PortalServiceLogComplexity]
(
[PortalServiceLogComplexityID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogComplexity_PortalServiceLogComplexityID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogComplexity_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogComplexity_IsDefault] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogComplexity] ADD CONSTRAINT [PK_PortalServiceLogComplexity] PRIMARY KEY CLUSTERED  ([PortalServiceLogComplexityID]) ON [PRIMARY]
GO
