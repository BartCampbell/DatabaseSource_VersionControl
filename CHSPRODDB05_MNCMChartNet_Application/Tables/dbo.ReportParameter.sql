CREATE TABLE [dbo].[ReportParameter]
(
[ReportParameterID] [int] NOT NULL IDENTITY(1, 1),
[ReportID] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParameterTypeID] [int] NOT NULL,
[DefaultValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [PK_ReportParameter] PRIMARY KEY CLUSTERED  ([ReportParameterID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] WITH NOCHECK ADD CONSTRAINT [FK_ReportParameter_Report] FOREIGN KEY ([ReportID]) REFERENCES [dbo].[Report] ([ReportID])
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [FK_ReportParameter_ReportParameterType] FOREIGN KEY ([ParameterTypeID]) REFERENCES [dbo].[ReportParameterType] ([ParameterTypeID])
GO
