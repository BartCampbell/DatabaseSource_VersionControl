CREATE TABLE [dbo].[etl_staging_table_stat]
(
[ETLStagingTableStatID] [int] NOT NULL IDENTITY(1, 1),
[RunDate] [datetime] NULL,
[LoadInstanceID] [int] NULL,
[StartTime] [datetime] NULL,
[StopTime] [datetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagingTableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreETLRecordCount] [bigint] NULL,
[PostETLRecordCount] [bigint] NULL
) ON [PRIMARY]
GO
