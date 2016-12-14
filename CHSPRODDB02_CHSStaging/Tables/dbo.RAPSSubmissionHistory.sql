CREATE TABLE [dbo].[RAPSSubmissionHistory]
(
[ResponseFileID] [int] NOT NULL,
[HicNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientControlNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOBErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HicErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThruDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClusterGrouping] [int] NOT NULL,
[CCCSourceRecordID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RAPSSubmissionHistory_16_1458820259__K1_K3_K2_4_5_6_7_8_9_10_11_12_13] ON [dbo].[RAPSSubmissionHistory] ([ResponseFileID], [PatientControlNo], [HicNo]) INCLUDE ([CCCSourceRecordID], [ClusterGrouping], [DOBErrorCode], [DXCode], [ErrorA], [ErrorB], [FromDate], [HicErrorCode], [ProviderType], [ThruDate]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1458820259_3] ON [dbo].[RAPSSubmissionHistory] ([PatientControlNo])
GO
CREATE STATISTICS [_dta_stat_1458820259_2_3_1] ON [dbo].[RAPSSubmissionHistory] ([ResponseFileID], [HicNo], [PatientControlNo])
GO
