CREATE TABLE [Random].[LastNames]
(
[ID] [smallint] NOT NULL,
[LastName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Random].[LastNames] ADD CONSTRAINT [PK_Random_LastNames] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [Random].[LastNames] ADD CONSTRAINT [IX_Random_LastNames] UNIQUE NONCLUSTERED  ([LastName]) ON [PRIMARY]
GO
