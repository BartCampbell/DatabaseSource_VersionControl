CREATE TABLE [dbo].[jiradraftworkflows]
(
[ID] [numeric] (18, 0) NOT NULL,
[PARENTNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTOR] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiradraftworkflows] ADD CONSTRAINT [PK_jiradraftworkflows] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
