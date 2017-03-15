CREATE TABLE [adv].[tblUserHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblUserHa__Creat__66F79447] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblUserHash] ADD CONSTRAINT [PK_tblUserHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
