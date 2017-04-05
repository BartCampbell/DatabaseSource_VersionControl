CREATE TABLE [DataEvaluation].[Report]
(
[ReportId] [int] NOT NULL,
[ReportCategoryId] [int] NOT NULL,
[LevelId] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DataEvaluation].[Report] ADD CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED  ([ReportId]) ON [PRIMARY]
GO
ALTER TABLE [DataEvaluation].[Report] ADD CONSTRAINT [FK_Report_LevelId] FOREIGN KEY ([LevelId]) REFERENCES [DataEvaluation].[Level] ([LevelId])
GO
ALTER TABLE [DataEvaluation].[Report] ADD CONSTRAINT [FK_Report_ReportCategoryId] FOREIGN KEY ([ReportCategoryId]) REFERENCES [DataEvaluation].[ReportCategory] ([ReportCategoryId])
GO
