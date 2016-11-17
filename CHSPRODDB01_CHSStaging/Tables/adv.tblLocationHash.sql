CREATE TABLE [adv].[tblLocationHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblLocati__Creat__4B8483FC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblLocationHash] ADD CONSTRAINT [PK_tblLocationHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
