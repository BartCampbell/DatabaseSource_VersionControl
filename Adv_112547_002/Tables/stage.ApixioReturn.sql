CREATE TABLE [stage].[ApixioReturn]
(
[Suspect_PK] [int] NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_To] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT] [int] NULL,
[Provider_PK] [int] NULL,
[CodedSource_PK] [int] NULL,
[IsICD10] [int] NOT NULL,
[CodedUser_PK] [int] NOT NULL,
[Coded_Date] [smalldatetime] NULL,
[Updated_Date] [datetime2] (3) NOT NULL,
[PAGE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Is_Deleted] [int] NOT NULL,
[ScannedData_PK] [int] NULL,
[CoderLevel] [int] NOT NULL,
[rown] [bigint] NULL,
[CentauriProviderID] [int] NULL,
[PROVIDER_NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_LAST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_FIRST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
