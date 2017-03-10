CREATE TABLE [dbo].[DropDownValues_AspirinUseStatus]
(
[AspirinUseStatusId] [int] NOT NULL IDENTITY(1, 1),
[DisplayText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_AspirinUseStatus] ADD CONSTRAINT [PK_DropDownValues_AspirinUseStatus] PRIMARY KEY CLUSTERED  ([AspirinUseStatusId]) ON [PRIMARY]
GO
