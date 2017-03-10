CREATE TABLE [dbo].[PortalHelp]
(
[PortalHelpID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalHelp_PortalHelpID2] DEFAULT (newid()),
[PortalHelpKey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalHelpTitle] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Width] [int] NOT NULL CONSTRAINT [DF_PortalHelp_Width] DEFAULT ((0)),
[Height] [int] NOT NULL CONSTRAINT [DF_PortalHelp_Height] DEFAULT ((0)),
[PortalHelpText] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalHelp] ADD CONSTRAINT [PK_PortalHelp] PRIMARY KEY CLUSTERED  ([PortalHelpID]) ON [PRIMARY]
GO
