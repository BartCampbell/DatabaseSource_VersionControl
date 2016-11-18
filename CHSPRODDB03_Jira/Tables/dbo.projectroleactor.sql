CREATE TABLE [dbo].[projectroleactor]
(
[ID] [numeric] (18, 0) NOT NULL,
[PID] [numeric] (18, 0) NULL,
[PROJECTROLEID] [numeric] (18, 0) NULL,
[ROLETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ROLETYPEPARAMETER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[projectroleactor] ADD CONSTRAINT [PK_projectroleactor] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [role_pid_idx] ON [dbo].[projectroleactor] ([PID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [role_player_idx] ON [dbo].[projectroleactor] ([PROJECTROLEID], [PID]) ON [PRIMARY]
GO
