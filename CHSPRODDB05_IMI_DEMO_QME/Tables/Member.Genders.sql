CREATE TABLE [Member].[Genders]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[Genders] ADD CONSTRAINT [PK_Genders] PRIMARY KEY CLUSTERED  ([Gender]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Genders_Abbrev] ON [Member].[Genders] ([Abbrev]) ON [PRIMARY]
GO
