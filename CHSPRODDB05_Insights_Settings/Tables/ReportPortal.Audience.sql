CREATE TABLE [ReportPortal].[Audience]
(
[BitSeed] [tinyint] NOT NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptAudienceID] [tinyint] NOT NULL,
[SortOrder] [tinyint] NOT NULL CONSTRAINT [DF_Audience_SortOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Audience] ADD CONSTRAINT [PK_ReportPortal_Audience] PRIMARY KEY CLUSTERED  ([RptAudienceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Audience_BitValue] ON [ReportPortal].[Audience] ([BitValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_Audience_Descr] ON [ReportPortal].[Audience] ([Descr]) ON [PRIMARY]
GO
