CREATE TABLE [dbo].[tblContactNotesProvider]
(
[ContactNotesProvider_PK] [int] NOT NULL IDENTITY(1, 1),
[ProviderMaster_PK] [bigint] NULL,
[ContactNote_PK] [smallint] NULL,
[ContactNoteText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblContactNotesProvider] ADD CONSTRAINT [PK_tblContactNotesProvider] PRIMARY KEY CLUSTERED  ([ContactNotesProvider_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
