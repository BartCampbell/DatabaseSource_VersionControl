CREATE TABLE [dbo].[L_SuspectMember]
(
[L_SuspectMember_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectMember] ADD CONSTRAINT [PK_L_SuspectMember] PRIMARY KEY CLUSTERED  ([L_SuspectMember_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectMember] ADD CONSTRAINT [FK_H_Member_RK7] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectMember] ADD CONSTRAINT [FK_H_Suspect_RK3] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
