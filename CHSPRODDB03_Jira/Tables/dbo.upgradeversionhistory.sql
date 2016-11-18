CREATE TABLE [dbo].[upgradeversionhistory]
(
[ID] [numeric] (18, 0) NULL,
[TIMEPERFORMED] [datetime] NULL,
[TARGETBUILD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[TARGETVERSION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[upgradeversionhistory] ADD CONSTRAINT [PK_upgradeversionhistory] PRIMARY KEY CLUSTERED  ([TARGETBUILD]) ON [PRIMARY]
GO
