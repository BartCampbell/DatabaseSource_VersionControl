CREATE TABLE [ReportPortal].[NavigationTypes]
(
[AllowCustomer] [bit] NOT NULL CONSTRAINT [DF_NavigationTypes_AllowCustomer] DEFAULT ((0)),
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptNavTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_NavigationTypes_RptNavTypeGuid] DEFAULT (newid()),
[RptNavTypeID] [tinyint] NOT NULL,
[AllowAnonymous] [bit] NOT NULL CONSTRAINT [DF_NavigationTypes_AllowAnonymous] DEFAULT ((0)),
[AllowPrincipal] [bit] NOT NULL CONSTRAINT [DF_NavigationTypes_AllowPrincipal] DEFAULT ((0)),
[BitSeed] [tinyint] NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[NavigationTypes] ADD CONSTRAINT [PK_ReportPortal_NavigationTypes] PRIMARY KEY CLUSTERED  ([RptNavTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_NavigationTypes_RptNavTypeGuid] ON [ReportPortal].[NavigationTypes] ([RptNavTypeGuid]) ON [PRIMARY]
GO
