CREATE TABLE [ReportPortal].[Settings]
(
[RptSettingsID] [tinyint] NOT NULL CONSTRAINT [DF_Settings_RptSettingsID] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Settings] ADD CONSTRAINT [CK_ReportPortal_Settings] CHECK (([RptSettingsID]=(1)))
GO
