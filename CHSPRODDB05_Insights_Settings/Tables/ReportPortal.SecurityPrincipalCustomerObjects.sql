CREATE TABLE [ReportPortal].[SecurityPrincipalCustomerObjects]
(
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_SecurityPrincipalCustomerObjects_IsEnabled] DEFAULT ((0)),
[PrincipalID] [smallint] NOT NULL,
[PrincipalRptCustObjID] [smallint] NOT NULL IDENTITY(1, 1),
[RptCustObjID] [smallint] NOT NULL,
[BitNavigationTypes] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalCustomerObjects] ADD CONSTRAINT [PK_ReportPortal_SecurityPrincipalCustomerObjects] PRIMARY KEY CLUSTERED  ([PrincipalRptCustObjID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipalCustomerObjects] ON [ReportPortal].[SecurityPrincipalCustomerObjects] ([PrincipalID], [RptCustObjID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalCustomerObjects] ADD CONSTRAINT [FK_ReportPortal_SecurityPrincipalCustomerObjects_CustomerObjects] FOREIGN KEY ([RptCustObjID]) REFERENCES [ReportPortal].[CustomerObjects] ([RptCustObjID])
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalCustomerObjects] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_SecurityPrincipalCustomerObjects_SecurityPrincipals] FOREIGN KEY ([PrincipalID]) REFERENCES [ReportPortal].[SecurityPrincipals] ([PrincipalID])
GO
