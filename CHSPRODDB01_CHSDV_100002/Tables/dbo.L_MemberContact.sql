CREATE TABLE [dbo].[L_MemberContact]
(
[L_MemberContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberContact] ADD CONSTRAINT [PK_L_MemberContact] PRIMARY KEY CLUSTERED  ([L_MemberContact_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberContact] ADD CONSTRAINT [FK_L_MemberContact_H_Contact] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK])
GO
ALTER TABLE [dbo].[L_MemberContact] ADD CONSTRAINT [FK_L_MemberContact_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
