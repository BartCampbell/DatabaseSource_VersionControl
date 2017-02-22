CREATE TABLE [dbo].[clusterupgradestate]
(
[ID] [numeric] (18, 0) NOT NULL,
[DATABASE_TIME] [numeric] (18, 0) NULL,
[CLUSTER_BUILD_NUMBER] [numeric] (18, 0) NULL,
[CLUSTER_VERSION] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[STATE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ORDER_NUMBER] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clusterupgradestate] ADD CONSTRAINT [PK_clusterupgradestate] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ordernumber_idx] ON [dbo].[clusterupgradestate] ([ORDER_NUMBER]) ON [PRIMARY]
GO
