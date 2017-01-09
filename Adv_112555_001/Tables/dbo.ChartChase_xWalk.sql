CREATE TABLE [dbo].[ChartChase_xWalk]
(
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChartName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartChase_xWalk] ADD CONSTRAINT [PK_ChartChase_xWalk] PRIMARY KEY CLUSTERED  ([ChaseID]) ON [PRIMARY]
GO
