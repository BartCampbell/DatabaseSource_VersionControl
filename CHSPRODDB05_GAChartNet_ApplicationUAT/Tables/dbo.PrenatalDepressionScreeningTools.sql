CREATE TABLE [dbo].[PrenatalDepressionScreeningTools]
(
[ToolDBID] [int] NOT NULL IDENTITY(1, 1),
[ToolID] [int] NULL,
[ToolDesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToolLongDesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL CONSTRAINT [DF_PrenatalDepressionScreeningTools_IsActive] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PrenatalDepressionScreeningTools] ADD CONSTRAINT [PK_PrenatalDepressionScreeningTools] PRIMARY KEY CLUSTERED  ([ToolDBID]) ON [PRIMARY]
GO
