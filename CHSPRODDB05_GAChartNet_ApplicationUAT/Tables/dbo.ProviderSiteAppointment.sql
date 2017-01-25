CREATE TABLE [dbo].[ProviderSiteAppointment]
(
[ProviderSiteID] [int] NOT NULL,
[AppointmentID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderSiteAppointment] ADD CONSTRAINT [PK_ProviderSiteAppointment] PRIMARY KEY CLUSTERED  ([ProviderSiteID], [AppointmentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderSiteAppointment] ADD CONSTRAINT [FK_ProviderSiteAppointment_Appointment] FOREIGN KEY ([AppointmentID]) REFERENCES [dbo].[Appointment] ([AppointmentID])
GO
ALTER TABLE [dbo].[ProviderSiteAppointment] ADD CONSTRAINT [FK_ProviderSiteAppointment_ProviderSite] FOREIGN KEY ([ProviderSiteID]) REFERENCES [dbo].[ProviderSite] ([ProviderSiteID])
GO
