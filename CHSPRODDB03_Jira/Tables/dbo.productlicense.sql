CREATE TABLE [dbo].[productlicense]
(
[ID] [numeric] (18, 0) NOT NULL,
[LICENSE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[productlicense] ADD CONSTRAINT [PK_productlicense] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
