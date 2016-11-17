CREATE TABLE [dbo].[CCAI_MemberEligibility]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[SubscriberNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligBeginDate] [int] NULL,
[EligEndDate] [int] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveFlag] [int] NULL CONSTRAINT [DF__CCAI_Memb__Activ__75E27017] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_MemberEligibility] ADD CONSTRAINT [UQ__CCAI_Mem__FBDF78C80130B704] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
