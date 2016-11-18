CREATE TABLE [dbo].[externalgadget]
(
[ID] [numeric] (18, 0) NOT NULL,
[GADGET_XML] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[externalgadget] ADD CONSTRAINT [PK_externalgadget] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
