CREATE TABLE [adv].[tblScannedDataHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblScanne__Creat__6ECDC039] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScannedDataHash] ADD CONSTRAINT [PK_tblScannedDataHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
