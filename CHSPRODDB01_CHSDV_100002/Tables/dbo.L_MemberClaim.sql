CREATE TABLE [dbo].[L_MemberClaim]
(
[L_MemberClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Claim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberClaim] ADD CONSTRAINT [FK_L_MemberClaim_H_Claim] FOREIGN KEY ([H_Claim_RK]) REFERENCES [dbo].[H_Claim] ([H_Claim_RK])
GO
ALTER TABLE [dbo].[L_MemberClaim] ADD CONSTRAINT [FK_L_MemberClaim_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
