CREATE TABLE [dbo].[tblDepartment]
(
[department_pk] [smallint] NOT NULL IDENTITY(1, 1),
[department] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDepartment] ADD CONSTRAINT [PK_tblDepartment] PRIMARY KEY CLUSTERED  ([department_pk]) ON [PRIMARY]
GO
