CREATE TABLE [dbo].[tblHccCategory]
(
[HccCategory_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Disease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHccCategory] ADD CONSTRAINT [PK_tblHccCategory] PRIMARY KEY CLUSTERED  ([HccCategory_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ALL] ON [dbo].[tblHccCategory] ([HccCategory_PK]) INCLUDE ([Disease]) ON [PRIMARY]
GO
