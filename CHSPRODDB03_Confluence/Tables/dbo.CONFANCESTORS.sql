CREATE TABLE [dbo].[CONFANCESTORS]
(
[DESCENDENTID] [numeric] (19, 0) NOT NULL,
[ANCESTORID] [numeric] (19, 0) NOT NULL,
[ANCESTORPOSITION] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFANCESTORS] ADD CONSTRAINT [PK__CONFANCE__B11FEE40F6E8B35A] PRIMARY KEY CLUSTERED  ([DESCENDENTID], [ANCESTORPOSITION]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [c_ancestorid_idx] ON [dbo].[CONFANCESTORS] ([ANCESTORID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONFANCESTORS] ADD CONSTRAINT [FK9494E23C37E35A2E] FOREIGN KEY ([ANCESTORID]) REFERENCES [dbo].[CONTENT] ([CONTENTID])
GO
ALTER TABLE [dbo].[CONFANCESTORS] ADD CONSTRAINT [FK9494E23CC45E94DC] FOREIGN KEY ([DESCENDENTID]) REFERENCES [dbo].[CONTENT] ([CONTENTID])
GO
