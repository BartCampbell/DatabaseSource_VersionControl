CREATE TABLE [dbo].[tblSuspectAssignment]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectAssignment] ADD CONSTRAINT [PK_tblSuspectAssignment] PRIMARY KEY CLUSTERED  ([Suspect_PK], [User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
