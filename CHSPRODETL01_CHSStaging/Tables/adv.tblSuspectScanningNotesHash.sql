CREATE TABLE [adv].[tblSuspectScanningNotesHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__Creat__1AAC4277] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectScanningNotesHash] ADD CONSTRAINT [PK_tblSuspectScanningNotesHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
