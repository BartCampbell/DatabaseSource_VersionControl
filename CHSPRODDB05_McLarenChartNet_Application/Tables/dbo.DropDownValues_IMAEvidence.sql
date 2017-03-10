CREATE TABLE [dbo].[DropDownValues_IMAEvidence]
(
[IMAEvidenceID] [int] NOT NULL IDENTITY(1, 1),
[DisplayText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IMAEventID] [int] NOT NULL,
[MeasureComponentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_IMAEvidence] ADD CONSTRAINT [PK_DropDownValues_IMAEvidence] PRIMARY KEY CLUSTERED  ([IMAEvidenceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_IMAEvidence] ADD CONSTRAINT [FK_DropDownValues_IMAEvidence_DropDownValues_IMAEvent] FOREIGN KEY ([IMAEventID]) REFERENCES [dbo].[DropDownValues_IMAEvent] ([IMAEventID])
GO
