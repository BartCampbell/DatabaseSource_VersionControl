CREATE TABLE [Result].[DataSetPopulationKey]
(
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PopulationID] [int] NOT NULL,
[PopulationNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetPopulationKey] ADD CONSTRAINT [PK_DataSetPopulationKey] PRIMARY KEY CLUSTERED  ([DataRunID], [PopulationID]) ON [PRIMARY]
GO
