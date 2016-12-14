CREATE TABLE [dbo].[VivaIncrementalHCCMaster]
(
[ProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [date] NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCodeDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartC_HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartC_HCCDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartC_HCCRecaptured2016] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartD_HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartD_HCCDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartD_HCCRecaptured2016] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
