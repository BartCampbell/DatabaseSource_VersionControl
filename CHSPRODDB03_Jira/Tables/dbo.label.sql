CREATE TABLE [dbo].[label]
(
[ID] [numeric] (18, 0) NOT NULL,
[FIELDID] [numeric] (18, 0) NULL,
[ISSUE] [numeric] (18, 0) NULL,
[LABEL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[label] ADD CONSTRAINT [PK_label] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [label_issue] ON [dbo].[label] ([ISSUE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [label_fieldissue] ON [dbo].[label] ([ISSUE], [FIELDID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [label_fieldissuelabel] ON [dbo].[label] ([ISSUE], [FIELDID], [LABEL]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [label_label] ON [dbo].[label] ([LABEL]) ON [PRIMARY]
GO
