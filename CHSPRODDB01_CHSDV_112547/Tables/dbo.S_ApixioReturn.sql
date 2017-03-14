CREATE TABLE [dbo].[S_ApixioReturn]
(
[S_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferenceNbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLast] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirst] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfService] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLast] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirst] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientUUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocumentUUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoderHistory] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoderAnnotationHistory] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodingDate] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivered] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhaseComplete] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ApixioReturn] ADD CONSTRAINT [PK_S_ApixioReturn] PRIMARY KEY CLUSTERED  ([S_ApixioReturn_RK]) ON [PRIMARY]
GO
