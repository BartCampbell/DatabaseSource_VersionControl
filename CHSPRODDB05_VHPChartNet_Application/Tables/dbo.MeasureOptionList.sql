CREATE TABLE [dbo].[MeasureOptionList]
(
[ItemKey] [int] NOT NULL IDENTITY(1, 1),
[MeasureID] [int] NOT NULL,
[ListKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureOptionList] ADD CONSTRAINT [PK_MeasureOptionList] PRIMARY KEY CLUSTERED  ([ItemKey]) ON [PRIMARY]
GO
