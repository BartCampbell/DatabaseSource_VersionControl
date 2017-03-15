CREATE TABLE [dbo].[Test_CCAIMembershipReport]
(
[RecordID] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligBeginDate] [int] NULL,
[EligEndDate] [int] NULL,
[MemberType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Test_CCAIMembershipReport] ADD CONSTRAINT [UQ__Test_CCA__FBDF78C85ABB2E91] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
