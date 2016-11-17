CREATE TABLE [dbo].[L_100003_MemberClaim]
(
[L_MemberClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Claim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberClaim] ADD CONSTRAINT [PK_L_100003_MemberClaim] PRIMARY KEY CLUSTERED  ([L_MemberClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_100003_MemberClaim] ADD CONSTRAINT [FK_L_100003_MemberClaim_H_100003_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_100003_Member] ([H_Member_RK])
GO
