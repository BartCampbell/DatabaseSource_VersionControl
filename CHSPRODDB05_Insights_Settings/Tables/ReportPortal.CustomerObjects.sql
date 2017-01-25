CREATE TABLE [ReportPortal].[CustomerObjects]
(
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_CustomerObjects_IsEnabled] DEFAULT ((1)),
[IsInherited] [bit] NOT NULL CONSTRAINT [DF_CustomerObjects_IsInherited] DEFAULT ((0)),
[RptCustID] [smallint] NOT NULL,
[RptCustObjID] [smallint] NOT NULL IDENTITY(1, 1),
[RptObjID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[CustomerObjects] ADD CONSTRAINT [PK_ReportPortal_CustomerObjects] PRIMARY KEY CLUSTERED  ([RptCustObjID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_CustomerObjects] ON [ReportPortal].[CustomerObjects] ([RptCustID], [RptObjID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[CustomerObjects] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_CustomerObjects_Customers] FOREIGN KEY ([RptCustID]) REFERENCES [ReportPortal].[Customers] ([RptCustID])
GO
ALTER TABLE [ReportPortal].[CustomerObjects] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_CustomerObjects_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
