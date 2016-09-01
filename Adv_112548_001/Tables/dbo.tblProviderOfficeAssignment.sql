CREATE TABLE [dbo].[tblProviderOfficeAssignment]
(
[ProviderOffice_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeAssignment] ADD CONSTRAINT [PK_tblProviderOfficeAssignment] PRIMARY KEY CLUSTERED  ([ProviderOffice_PK], [User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
