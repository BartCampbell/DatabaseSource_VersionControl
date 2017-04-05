CREATE TABLE [Measure].[EntityProductLines]
(
[EntityID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EntityProductLines] ADD CONSTRAINT [PK_EntityProductLines] PRIMARY KEY CLUSTERED  ([EntityID], [ProductLineID]) ON [PRIMARY]
GO
