CREATE TABLE [dbo].[schemeissuesecurities]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[SECURITY] [numeric] (18, 0) NULL,
[sec_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[sec_parameter] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schemeissuesecurities] ADD CONSTRAINT [PK_schemeissuesecurities] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sec_scheme] ON [dbo].[schemeissuesecurities] ([SCHEME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sec_security] ON [dbo].[schemeissuesecurities] ([SECURITY]) ON [PRIMARY]
GO
