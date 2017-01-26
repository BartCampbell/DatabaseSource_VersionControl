CREATE TABLE [dbo].[Priority58k]
(
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScanned] [bit] NULL,
[IsCoded] [bit] NULL,
[chart text] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartID] ON [dbo].[Priority58k] ([ChaseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChaseID] ON [dbo].[Priority58k] ([ChaseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Status] ON [dbo].[Priority58k] ([Status]) ON [PRIMARY]
GO
