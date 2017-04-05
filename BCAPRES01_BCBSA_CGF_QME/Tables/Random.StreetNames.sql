CREATE TABLE [Random].[StreetNames]
(
[ID] [smallint] NOT NULL,
[StreetName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Random].[StreetNames] ADD CONSTRAINT [PK_Random_StreetNames] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [Random].[StreetNames] ADD CONSTRAINT [IX_Random_StreetNames] UNIQUE NONCLUSTERED  ([StreetName]) ON [PRIMARY]
GO
