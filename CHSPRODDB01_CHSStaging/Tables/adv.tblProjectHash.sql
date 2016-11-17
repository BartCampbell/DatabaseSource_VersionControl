CREATE TABLE [adv].[tblProjectHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblProjec__Creat__56F636A8] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProjectHash] ADD CONSTRAINT [PK_tblProjectHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
