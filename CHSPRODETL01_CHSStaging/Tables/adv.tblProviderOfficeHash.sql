CREATE TABLE [adv].[tblProviderOfficeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblProvid__Creat__6267E954] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeHash] ADD CONSTRAINT [PK_tblProviderOfficeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
