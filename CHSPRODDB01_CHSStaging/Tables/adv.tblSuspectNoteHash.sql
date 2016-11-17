CREATE TABLE [adv].[tblSuspectNoteHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__Creat__16DBB193] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectNoteHash] ADD CONSTRAINT [PK_tblSuspectNoteHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
