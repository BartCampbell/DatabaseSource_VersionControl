CREATE TABLE [CGF].[ClientConfig]
(
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_Server] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_DB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_Staging_Server] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_Staging_DB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMIStaging_Server] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMIStaging_DB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMIStaging_Prod_Server] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMIStaging_PRod_DB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_FullBuildSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QME_OwnerID] [int] NULL,
[QME_MeasureSetID] [int] NULL,
[RollingMonths] [int] NULL,
[RollingMonthsInterval] [int] NULL,
[SeedDateLagMonths] [int] NULL
) ON [PRIMARY]
GO
