CREATE TABLE [dbo].[ChartStatusValue]
(
[ChartStatusValueID] [int] NOT NULL,
[ParentID] [int] NULL,
[Title] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartStatusValue] ADD CONSTRAINT [PK__ChartSta__17943B8F7E77B618] PRIMARY KEY CLUSTERED  ([ChartStatusValueID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartStatusValue] ADD CONSTRAINT [FK__ChartStat__Paren__005FFE8A] FOREIGN KEY ([ParentID]) REFERENCES [dbo].[ChartStatusValue] ([ChartStatusValueID])
GO
