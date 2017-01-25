CREATE TABLE [dbo].[DropDownValues_ImmunizationStatus]
(
[ImmunizationStatusId] [int] NOT NULL IDENTITY(1, 1),
[DisplayText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_ImmunizationStatus] ADD CONSTRAINT [PK_DropDownValues_ImmunizationStatus] PRIMARY KEY CLUSTERED  ([ImmunizationStatusId]) ON [PRIMARY]
GO
