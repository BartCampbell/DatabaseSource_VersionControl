CREATE TABLE [x12].[RefParseTableList]
(
[ListID] [int] NOT NULL IDENTITY(1, 1),
[X12Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TablePrefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [x12].[RefParseTableList] ADD CONSTRAINT [PK_RefParseTableList] PRIMARY KEY CLUSTERED  ([ListID]) ON [PRIMARY]
GO
