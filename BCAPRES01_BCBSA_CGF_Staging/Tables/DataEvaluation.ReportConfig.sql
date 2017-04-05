CREATE TABLE [DataEvaluation].[ReportConfig]
(
[ReportConfigID] [int] NOT NULL IDENTITY(1, 1),
[ReportCategoryId] [int] NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceDataFile] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RDSMDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RDSMSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RDSMTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RDSMGranularity] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagingTarget] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilterGroupBYForStaging] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterWhere] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagingRejectedTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
