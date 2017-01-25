CREATE TABLE [dbo].[Appointment]
(
[AppointmentID] [int] NOT NULL IDENTITY(1, 1),
[AppointmentNote] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppointmentDateTime] [datetime] NOT NULL,
[AppointmentDate] AS (dateadd(day,(0),datediff(day,(0),[AppointmentDateTime]))),
[AbstractorID] [int] NOT NULL,
[AppointmentStatusID] [int] NOT NULL CONSTRAINT [DF_Appointment_AppointmentStatusID] DEFAULT ((1)),
[OriginalAppointmentID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_Appointment_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Appointment_CreatedUser] DEFAULT (suser_sname()),
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_Appointment_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Appointment_LastChangedUser] DEFAULT (suser_sname())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appointment] ADD CONSTRAINT [PK_Appointment] PRIMARY KEY CLUSTERED  ([AppointmentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Appointment_AbstractorID] ON [dbo].[Appointment] ([AbstractorID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Appointment_AppointmentStatusID] ON [dbo].[Appointment] ([AppointmentStatusID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Appointment_OriginalAppointmentID] ON [dbo].[Appointment] ([OriginalAppointmentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Appointment] ADD CONSTRAINT [FK_Appointment_Abstractor] FOREIGN KEY ([AbstractorID]) REFERENCES [dbo].[Abstractor] ([AbstractorID])
GO
ALTER TABLE [dbo].[Appointment] ADD CONSTRAINT [FK_Appointment_AppointmentStatus] FOREIGN KEY ([AppointmentStatusID]) REFERENCES [dbo].[AppointmentStatus] ([AppointmentStatusID])
GO
