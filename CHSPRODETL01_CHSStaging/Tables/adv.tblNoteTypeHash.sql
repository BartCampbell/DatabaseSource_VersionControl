CREATE TABLE [adv].[tblNoteTypeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblNoteTy__Creat__5325A5C4] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblNoteTypeHash] ADD CONSTRAINT [PK_tblNoteTypeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
