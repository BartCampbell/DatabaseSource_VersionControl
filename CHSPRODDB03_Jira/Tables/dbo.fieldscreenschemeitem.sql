CREATE TABLE [dbo].[fieldscreenschemeitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[OPERATION] [numeric] (18, 0) NULL,
[FIELDSCREEN] [numeric] (18, 0) NULL,
[FIELDSCREENSCHEME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldscreenschemeitem] ADD CONSTRAINT [PK_fieldscreenschemeitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [screenitem_scheme] ON [dbo].[fieldscreenschemeitem] ([FIELDSCREENSCHEME]) ON [PRIMARY]
GO
