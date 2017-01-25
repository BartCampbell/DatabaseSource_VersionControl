CREATE TABLE [dbo].[DropDownValues_IMAEvent]
(
[IMAEventID] [int] NOT NULL IDENTITY(1, 1),
[DisplayText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_IMAEvent] ADD CONSTRAINT [PK_DropDownValues_IMAEvent] PRIMARY KEY CLUSTERED  ([IMAEventID]) ON [PRIMARY]
GO
