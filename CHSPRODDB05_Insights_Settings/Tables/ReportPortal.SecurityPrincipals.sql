CREATE TABLE [ReportPortal].[SecurityPrincipals]
(
[ADDomainName] AS ([ReportPortal].[GetADInfoDomain]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADEmail] AS ([ReportPortal].[GetADInfoEmail]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADGuid] AS ([ReportPortal].[GetADInfoGuid]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADInfo] [xml] NULL,
[ADName] AS ([ReportPortal].[GetADInfoName]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADPhone] AS ([ReportPortal].[GetADInfoPhone]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADSamAccountName] AS ([ReportPortal].[GetADInfoSamAccountName]([ADInfo],[PrincipalTypeID])) PERSISTED,
[ADUserPrincipalName] AS ([ReportPortal].[GetADInfoUserPrincipalName]([ADInfo],[PrincipalTypeID])) PERSISTED,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_SecurityPrincipals_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SecurityPrincipals_CreatedUser] DEFAULT (suser_sname()),
[DomainName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_SecurityPrincipals_IsEnabled] DEFAULT ((0)),
[IsSysAdmin] [bit] NOT NULL CONSTRAINT [DF_SecurityPrincipals_IsSysAdmin] DEFAULT ((0)),
[LastPortalLogon] [datetime] NULL,
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF_SecurityPrincipals_LastUpdatedDate] DEFAULT (getdate()),
[LastUpdatedUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SecurityPrincipals_LastUpdatedUser] DEFAULT (suser_sname()),
[PortalLogonCount] [int] NOT NULL CONSTRAINT [DF_SecurityPrincipals_PortalLogonCount] DEFAULT ((0)),
[PrincipalGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Table_1_UserGuid] DEFAULT (newid()),
[PrincipalName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrincipalID] [smallint] NOT NULL IDENTITY(1, 1),
[PrincipalTypeID] [tinyint] NOT NULL,
[BitNavigationTypes] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipals] ADD CONSTRAINT [PK_ReportPortal_SecurityPrincipals] PRIMARY KEY CLUSTERED  ([PrincipalID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipals_ADName] ON [ReportPortal].[SecurityPrincipals] ([ADName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipals_ADUserPrincipalName] ON [ReportPortal].[SecurityPrincipals] ([ADUserPrincipalName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipals_PrincipalGuid] ON [ReportPortal].[SecurityPrincipals] ([PrincipalGuid], [DomainName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipals_PrincipalName] ON [ReportPortal].[SecurityPrincipals] ([PrincipalName], [DomainName]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipals] ADD CONSTRAINT [FK_ReportPortal_SecurityPrincipals_SecurityPrincipalTypes] FOREIGN KEY ([PrincipalTypeID]) REFERENCES [ReportPortal].[SecurityPrincipalTypes] ([PrincipalTypeID])
GO
