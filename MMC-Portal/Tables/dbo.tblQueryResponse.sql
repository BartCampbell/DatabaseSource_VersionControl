CREATE TABLE [dbo].[tblQueryResponse]
(
[QueryResponse_pk] [tinyint] NOT NULL,
[QueryResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQueryResponse] ADD CONSTRAINT [PK_tblQueryResponse] PRIMARY KEY CLUSTERED  ([QueryResponse_pk]) ON [PRIMARY]
GO
