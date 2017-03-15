CREATE TABLE [adv].[tblUserSessionLogHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblUserSe__Creat__5A91BD62] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserSessionLogHash] ADD CONSTRAINT [PK_tblUserSessionLogHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
