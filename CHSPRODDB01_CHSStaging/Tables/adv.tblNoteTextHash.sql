CREATE TABLE [adv].[tblNoteTextHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblNoteTe__Creat__4F5514E0] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblNoteTextHash] ADD CONSTRAINT [PK_tblNoteTextHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
