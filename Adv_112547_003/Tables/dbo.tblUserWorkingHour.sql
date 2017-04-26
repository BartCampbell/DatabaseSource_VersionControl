CREATE TABLE [dbo].[tblUserWorkingHour]
(
[User_PK] [int] NOT NULL,
[Day_PK] [tinyint] NOT NULL,
[FromHour] [tinyint] NULL,
[FromMin] [tinyint] NULL,
[ToHour] [tinyint] NULL,
[ToMin] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserWorkingHour] ADD CONSTRAINT [PK_tblUserWorkingHour] PRIMARY KEY CLUSTERED  ([User_PK], [Day_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
