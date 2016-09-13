CREATE TABLE [dbo].[tblSuspectDOS]
(
[SuspectDOS_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NOT NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_To] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectDOS] ADD CONSTRAINT [PK_tblSuspectDOS] PRIMARY KEY CLUSTERED  ([SuspectDOS_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectDOS] ON [dbo].[tblSuspectDOS] ([Suspect_PK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectDOS] ADD CONSTRAINT [FK_tblSuspectDOS_tblSuspect] FOREIGN KEY ([Suspect_PK]) REFERENCES [dbo].[tblSuspect] ([Suspect_PK])
GO
