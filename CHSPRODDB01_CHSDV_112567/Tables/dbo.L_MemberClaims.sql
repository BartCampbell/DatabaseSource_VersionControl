CREATE TABLE [dbo].[L_MemberClaims]
(
[L_MemberClaims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Claims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberClaims] ADD CONSTRAINT [PK_L_MemberClaims] PRIMARY KEY CLUSTERED  ([L_MemberClaims_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberClaims] ADD CONSTRAINT [FK_MemberClaims_H_Claims_RK] FOREIGN KEY ([H_Claims_RK]) REFERENCES [dbo].[H_Claims] ([H_Claims_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_MemberClaims] ADD CONSTRAINT [FK_MemberClaims_H_Member_RK] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
