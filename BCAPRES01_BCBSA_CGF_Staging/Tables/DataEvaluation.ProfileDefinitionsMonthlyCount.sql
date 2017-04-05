CREATE TABLE [DataEvaluation].[ProfileDefinitionsMonthlyCount]
(
[ProfileID] [int] NOT NULL IDENTITY(1000, 1),
[ProfileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetStagingTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportCategoryId] [int] NULL,
[LevelId] [int] NULL,
[ReportId] [int] NULL,
[Order_no] [int] NULL,
[SELECTSQL] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FROMSQL] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WHERESQL] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailSELECTSQL] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailFROMSQL] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailWHERESQL] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bActive] [bit] NULL,
[bDetailReport] [bit] NULL,
[SourceSystem] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bStandardDefinition] [bit] NULL,
[NonStandardSQL] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
