CREATE TABLE [dbo].[DropDownValues_HPVEvidence]
(
[HPVEvidenceID] [int] NOT NULL IDENTITY(1, 1),
[DisplayText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HPVEventID] [int] NOT NULL,
[MeasureComponentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_HPVEvidence] ADD CONSTRAINT [PK_DropDownValues_HPVEvidence] PRIMARY KEY CLUSTERED  ([HPVEvidenceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_HPVEvidence] ADD CONSTRAINT [FK_DropDownValues_HPVEvidence_DropDownValues_HPVEvent] FOREIGN KEY ([HPVEventID]) REFERENCES [dbo].[DropDownValues_HPVEvent] ([HPVEventID])
GO
