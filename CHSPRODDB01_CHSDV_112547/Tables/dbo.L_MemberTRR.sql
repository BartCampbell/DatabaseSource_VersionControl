CREATE TABLE [dbo].[L_MemberTRR]
(
[L_MemberTRR_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_TRR_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberTRR] ADD CONSTRAINT [PK_L_MemberTRR] PRIMARY KEY CLUSTERED  ([L_MemberTRR_RK]) ON [PRIMARY]
GO
