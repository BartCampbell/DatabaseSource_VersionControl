CREATE TABLE [dbo].[gadgetuserpreference]
(
[ID] [numeric] (18, 0) NOT NULL,
[PORTLETCONFIGURATION] [numeric] (18, 0) NULL,
[USERPREFKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[USERPREFVALUE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[gadgetuserpreference] ADD CONSTRAINT [PK_gadgetuserpreference] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [userpref_portletconfiguration] ON [dbo].[gadgetuserpreference] ([PORTLETCONFIGURATION]) ON [PRIMARY]
GO
