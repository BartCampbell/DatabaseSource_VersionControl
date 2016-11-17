CREATE TABLE [dbo].[S_OECDetail]
(
[S_OECDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_Indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Eff_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exp_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChasePriority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderRelationsRep] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECDetail] ADD CONSTRAINT [PK_S_OECDetail] PRIMARY KEY CLUSTERED  ([S_OECDetail_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OECDetail] ADD CONSTRAINT [FK_S_OECDetail_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
