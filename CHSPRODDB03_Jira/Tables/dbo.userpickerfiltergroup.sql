CREATE TABLE [dbo].[userpickerfiltergroup]
(
[ID] [numeric] (18, 0) NOT NULL,
[USERPICKERFILTER] [numeric] (18, 0) NULL,
[groupname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userpickerfiltergroup] ADD CONSTRAINT [PK_userpickerfiltergroup] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cf_userpickerfiltergroup] ON [dbo].[userpickerfiltergroup] ([USERPICKERFILTER]) ON [PRIMARY]
GO
