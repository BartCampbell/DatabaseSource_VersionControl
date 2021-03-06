CREATE TABLE [audit].[etl_profile_hdr]
(
[ProfileID] [int] NOT NULL,
[ProfileCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileSubjectArea] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileTable] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileField] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileSQL] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileDTLSql] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedLowValue] [numeric] (18, 4) NULL,
[ExpectedHighValue] [numeric] (18, 4) NULL,
[ExpectedValueType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileValue1Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileValue2Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PopulateDetailTable] [bit] NULL,
[PopulateDetailWithTopN] [smallint] NULL,
[FromClause] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WhereClause] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsGroupByRequired] [bit] NULL,
[GroupByClause] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HavingClause] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderByClause] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateLastModified] [datetime] NULL,
[LastModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastAction] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuditID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
