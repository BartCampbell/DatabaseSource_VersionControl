CREATE TABLE [adv].[tblProviderMasterHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblProvid__Creat__5AC6C78C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderMasterHash] ADD CONSTRAINT [PK_tblProviderMasterHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
