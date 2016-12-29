CREATE TABLE [dbo].[tblProviderOfficeAssignment_ClearLog]
(
[ProviderOffice_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[removed_by_user_pk] [smallint] NOT NULL,
[removed_date] [smalldatetime] NULL
) ON [PRIMARY]
GO
