CREATE TABLE [adv].[tblContactNoteHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblContac__Creat__3871AF88] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblContactNoteHash] ADD CONSTRAINT [PK_tblContactNoteHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
