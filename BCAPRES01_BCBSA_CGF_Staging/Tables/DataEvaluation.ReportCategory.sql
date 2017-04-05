CREATE TABLE [DataEvaluation].[ReportCategory]
(
[ReportCategoryId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DataEvaluation].[ReportCategory] ADD CONSTRAINT [PK_ReportCategory2] PRIMARY KEY CLUSTERED  ([ReportCategoryId]) ON [PRIMARY]
GO
