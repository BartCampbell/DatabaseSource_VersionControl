CREATE TABLE [Random].[FirstNames]
(
[FirstName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gender] [tinyint] NOT NULL,
[ID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Random].[FirstNames] ADD CONSTRAINT [PK_Random_FirstNames] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [Random].[FirstNames] ADD CONSTRAINT [IX_Random_FirstNames_FirstName] UNIQUE NONCLUSTERED  ([FirstName], [Gender]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Random_FirstNames_Gender] ON [Random].[FirstNames] ([Gender], [ID], [FirstName]) ON [PRIMARY]
GO
