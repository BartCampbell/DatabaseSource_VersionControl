CREATE TABLE [adv].[tblUserSessionHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblUserSe__Creat__56C12C7E] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserSessionHash] ADD CONSTRAINT [PK_tblUserSessionHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
