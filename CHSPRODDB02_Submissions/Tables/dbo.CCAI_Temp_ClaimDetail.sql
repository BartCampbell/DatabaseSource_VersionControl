CREATE TABLE [dbo].[CCAI_Temp_ClaimDetail]
(
[ClaimNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimLineNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSTo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlaceOfService] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeOfBill] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RenderingProviderNPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimTypeCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdmissionDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CCAI_Temp_ClaimDetail] ON [dbo].[CCAI_Temp_ClaimDetail] ([ClaimNumber], [ClaimLineNumber]) ON [PRIMARY]
GO
