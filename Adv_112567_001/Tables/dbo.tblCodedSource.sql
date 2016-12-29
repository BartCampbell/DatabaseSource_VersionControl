CREATE TABLE [dbo].[tblCodedSource]
(
[CodedSource_PK] [smallint] NOT NULL IDENTITY(1, 1),
[CodedSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortOrder] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCodedSource] ADD CONSTRAINT [PK_tblCodedSource] PRIMARY KEY CLUSTERED  ([CodedSource_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
