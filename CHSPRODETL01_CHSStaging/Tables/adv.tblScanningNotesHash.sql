CREATE TABLE [adv].[tblScanningNotesHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblScanni__Creat__729E511D] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblScanningNotesHash] ADD CONSTRAINT [PK_tblScanningNotesHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
