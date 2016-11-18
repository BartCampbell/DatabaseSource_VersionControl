CREATE TABLE [dbo].[boardproject]
(
[BOARD_ID] [numeric] (18, 0) NOT NULL,
[PROJECT_ID] [numeric] (18, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[boardproject] ADD CONSTRAINT [PK_boardproject] PRIMARY KEY CLUSTERED  ([BOARD_ID], [PROJECT_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_board_board_ids] ON [dbo].[boardproject] ([BOARD_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_board_project_ids] ON [dbo].[boardproject] ([PROJECT_ID]) ON [PRIMARY]
GO
