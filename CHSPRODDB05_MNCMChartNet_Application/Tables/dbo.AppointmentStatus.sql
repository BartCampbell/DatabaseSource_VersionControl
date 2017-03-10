CREATE TABLE [dbo].[AppointmentStatus]
(
[AppointmentStatusID] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCompleted] [bit] NOT NULL CONSTRAINT [DF_AppointmentStatus_IsCompleted] DEFAULT ((0)),
[IsReschedule] [bit] NOT NULL CONSTRAINT [DF_AppointmentStatus_IsReschedule] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppointmentStatus] ADD CONSTRAINT [PK_AppointmentStatus] PRIMARY KEY CLUSTERED  ([AppointmentStatusID]) ON [PRIMARY]
GO
