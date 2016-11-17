CREATE TABLE [dbo].[CCAI_MemberMORHCCMaster]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[SubscriberNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [int] NULL,
[HCCDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommWt] [decimal] (9, 3) NULL,
[HighHCCCapturedFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CCAI_Memb__HighH__005FFE8A] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_MemberMORHCCMaster] ADD CONSTRAINT [UQ__CCAI_Mem__FBDF78C8D68B8C7B] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
