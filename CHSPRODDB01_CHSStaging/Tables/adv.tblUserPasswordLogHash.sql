CREATE TABLE [adv].[tblUserPasswordLogHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblUserPa__Creat__346C147A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserPasswordLogHash] ADD CONSTRAINT [PK_tblUserPasswordLogHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
