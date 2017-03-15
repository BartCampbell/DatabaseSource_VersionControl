CREATE TABLE [adv].[tblUserProjectHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblUserPr__Creat__477EE8EE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserProjectHash] ADD CONSTRAINT [PK_tblUserProjectHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
