CREATE TABLE [dbo].[AetnaHCCMaster]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSYr] [int] NULL,
[MinDOSDate] [date] NULL,
[HCC] [int] NULL,
[HCC_Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DQFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__AetnaHCCM__DQFla__7484378A] DEFAULT ('N'),
[DQReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__AetnaHCCM__DQRea__75785BC3] DEFAULT (NULL),
[PartialHCC] [int] NULL,
[PartialHCCDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AetnaHCCMaster] ADD CONSTRAINT [UQ__AetnaHCC__FBDF78C839995F77] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
