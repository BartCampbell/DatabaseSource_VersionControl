CREATE TABLE [ReportPortal].[Customers]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptCustGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Customers_RptCustGuid] DEFAULT (newid()),
[RptCustID] [smallint] NOT NULL IDENTITY(1, 1),
[UrlSeg] AS (CONVERT([varchar](512),'/'+lower(replace(replace(replace([Abbrev],'&','and'),' - ','-'),' ','-')),(0))) PERSISTED
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Customers] ADD CONSTRAINT [PK_ReportPortal_Customers] PRIMARY KEY CLUSTERED  ([RptCustID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Customers_Abbrev] ON [ReportPortal].[Customers] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Customers_UrlSeg] ON [ReportPortal].[Customers] ([UrlSeg]) ON [PRIMARY]
GO
