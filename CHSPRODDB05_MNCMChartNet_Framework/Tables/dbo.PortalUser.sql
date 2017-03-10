CREATE TABLE [dbo].[PortalUser]
(
[PortalUserID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalUser_PortalUserID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalUser_SiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PasswordHash] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Salt] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PasswordExpirationDate] [datetime] NULL,
[LastLoginDate] [datetime] NOT NULL CONSTRAINT [DF_PortalUser_LastLoginDate] DEFAULT (getdate()),
[LoginAttempt] [smallint] NOT NULL CONSTRAINT [DF_PortalUser_LoginAttempt] DEFAULT ((0)),
[Enabled] [bit] NOT NULL CONSTRAINT [DF_PortalUser_Enabled] DEFAULT ((0)),
[OneTimePassword] [bit] NOT NULL CONSTRAINT [DF_PortalUser_OneTimePassword] DEFAULT ((0)),
[PassPhrase] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassPhraseResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfirmationSent] [bit] NOT NULL CONSTRAINT [DF_PortalUser_ConfirmationSent] DEFAULT ((0)),
[ConfirmationID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalUser_ConfirmationID] DEFAULT (newid()),
[IsSubscribed] [bit] NULL,
[IsHtml] [bit] NULL,
[IsWindowsAuthenticated] [bit] NULL,
[DomainName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsGlobalUser] [bit] NOT NULL CONSTRAINT [DF_PortalUser_IsGlobalUser] DEFAULT ((0)),
[Signature] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUser] ADD CONSTRAINT [PK_PortalUser] PRIMARY KEY CLUSTERED  ([PortalUserID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ndx_unq_PortalSite_EmailAddress] ON [dbo].[PortalUser] ([PortalSiteID], [EmailAddress]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ndx_unq_PortalSite_UserName] ON [dbo].[PortalUser] ([PortalSiteID], [UserName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUser] ADD CONSTRAINT [FK_PortalUser_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
