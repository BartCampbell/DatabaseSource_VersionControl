CREATE TABLE [adv].[tblProviderOfficeStatusHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblProvid__Creat__66387A38] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeStatusHash] ADD CONSTRAINT [PK_tblProviderOfficeStatusHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
