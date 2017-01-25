CREATE TABLE [dbo].[PPCEnrollmentCategory]
(
[PPCEnrollmentCategoryID] [int] NOT NULL,
[PPCEnrollmentCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PPCEnrollmentCategory] ADD CONSTRAINT [PK_PPCEnrollmentCategory] PRIMARY KEY CLUSTERED  ([PPCEnrollmentCategoryID]) ON [PRIMARY]
GO
