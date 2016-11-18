CREATE TABLE [dbo].[RAPSMemberHCCBySubmission]
(
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSTo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientControlNo] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmissionSource] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSProviderType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDVersion] [int] NULL,
[PaymentYear] [int] NULL,
[HCCVersion] [int] NULL,
[HCCVersionYear] [int] NULL,
[CC] [int] NULL,
[CommunityFactor] [float] NULL,
[ResponseCCCID] [int] NULL,
[ResponseFileID] [int] NULL,
[RAPSMemberHCCBySubmissionID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSMemberHCCBySubmission] ADD CONSTRAINT [PK_RAPSMemberHCCBySubmission] PRIMARY KEY CLUSTERED  ([RAPSMemberHCCBySubmissionID]) ON [PRIMARY]
GO
