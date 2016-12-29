CREATE TABLE [dbo].[tblIncompleteNote]
(
[IncompleteNote_PK] [tinyint] NOT NULL,
[IncompleteNote] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScanTechNote] [bit] NULL,
[IsSchedulerNote] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIncompleteNote] ADD CONSTRAINT [PK_tblIncompleteNote] PRIMARY KEY CLUSTERED  ([IncompleteNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
