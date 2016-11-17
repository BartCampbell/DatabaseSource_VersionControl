CREATE TABLE [dbo].[L_MemberClient]
(
[L_MemberClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberClient] ADD CONSTRAINT [PK_L_MemberClient] PRIMARY KEY CLUSTERED  ([L_MemberClient_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberClient] ADD CONSTRAINT [FK_H_Client_RK] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_MemberClient] ADD CONSTRAINT [FK_H_Member_RK] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
