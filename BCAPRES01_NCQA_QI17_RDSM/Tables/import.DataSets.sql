CREATE TABLE [import].[DataSets]
(
[datasetid] [int] NOT NULL IDENTITY(1, 1),
[datasetkey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dirdate] [datetime] NULL,
[importdate] [datetime] NULL,
[setpath] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [import].[DataSets] ADD CONSTRAINT [PK_DataSets] PRIMARY KEY CLUSTERED  ([datasetid]) ON [PRIMARY]
GO
