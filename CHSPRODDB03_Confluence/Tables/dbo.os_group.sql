CREATE TABLE [dbo].[os_group]
(
[id] [numeric] (19, 0) NOT NULL,
[groupname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_group] ADD CONSTRAINT [PK__os_group__3213E83F24471635] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_group] ADD CONSTRAINT [UQ__os_group__ED1647CCA586BAE0] UNIQUE NONCLUSTERED  ([groupname]) ON [PRIMARY]
GO
