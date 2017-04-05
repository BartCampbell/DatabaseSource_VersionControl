CREATE TABLE [imiETL].[RDSMStagingQME_DiffReport]
(
[RowID] [int] NOT NULL,
[Valtype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMSchema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMTab] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMRejDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMRejSchema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMRejTab] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagSchema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagTab] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StagDataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMEStagDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMEStagSchema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMEStagTab] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMESqlServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMEDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QMEDataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDSMCNT] [int] NULL,
[StagingCnt] [int] NULL,
[StagingQMECnt] [int] NULL,
[QMECnt] [int] NULL
) ON [PRIMARY]
GO
