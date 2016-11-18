CREATE TABLE [dbo].[local_members]
(
[userid] [numeric] (19, 0) NOT NULL,
[groupid] [numeric] (19, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[local_members] ADD CONSTRAINT [PK__local_me__E47E14A0DC3D0E5E] PRIMARY KEY CLUSTERED  ([groupid], [userid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [c_userid_idx] ON [dbo].[local_members] ([userid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[local_members] ADD CONSTRAINT [FK6B8FB445117D5FDA] FOREIGN KEY ([groupid]) REFERENCES [dbo].[groups] ([id])
GO
ALTER TABLE [dbo].[local_members] ADD CONSTRAINT [FK6B8FB445CE2B3226] FOREIGN KEY ([userid]) REFERENCES [dbo].[users] ([id])
GO
