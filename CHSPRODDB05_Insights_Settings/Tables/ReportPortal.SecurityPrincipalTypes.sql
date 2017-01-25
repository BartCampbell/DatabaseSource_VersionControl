CREATE TABLE [ReportPortal].[SecurityPrincipalTypes]
(
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrincipalTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SecurityPrincipalTypes_PrincipalTypeGuid] DEFAULT (newid()),
[PrincipalTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalTypes] ADD CONSTRAINT [PK_ReportPortal_SecurityPrincipalTypes] PRIMARY KEY CLUSTERED  ([PrincipalTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipalTypes_Descr] ON [ReportPortal].[SecurityPrincipalTypes] ([Descr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipalTypes_PrinciaplTypeGuid] ON [ReportPortal].[SecurityPrincipalTypes] ([PrincipalTypeGuid]) ON [PRIMARY]
GO
