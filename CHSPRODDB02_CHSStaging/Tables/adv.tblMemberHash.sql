CREATE TABLE [adv].[tblMemberHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblMember__Creat__237692A2] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblMemberHash] ADD CONSTRAINT [PK_tblMemberHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
