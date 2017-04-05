CREATE TABLE [DataEvaluation].[Level]
(
[LevelId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DataEvaluation].[Level] ADD CONSTRAINT [PK_Level] PRIMARY KEY CLUSTERED  ([LevelId]) ON [PRIMARY]
GO
