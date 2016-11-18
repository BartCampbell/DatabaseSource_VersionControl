CREATE TABLE [dbo].[BODYCONTENT]
(
[BODYCONTENTID] [numeric] (19, 0) NOT NULL,
[BODY] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CONTENTID] [numeric] (19, 0) NULL,
[BODYTYPEID] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BODYCONTENT] ADD CONSTRAINT [PK__BODYCONT__D49B3392242ED79D] PRIMARY KEY CLUSTERED  ([BODYCONTENTID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [body_content_idx] ON [dbo].[BODYCONTENT] ([CONTENTID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BODYCONTENT] ADD CONSTRAINT [FKA898D4778DD41734] FOREIGN KEY ([CONTENTID]) REFERENCES [dbo].[CONTENT] ([CONTENTID])
GO