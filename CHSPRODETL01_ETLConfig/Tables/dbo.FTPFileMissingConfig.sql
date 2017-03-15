CREATE TABLE [dbo].[FTPFileMissingConfig]
(
[FTPFileMissingConfigID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileNameStringFormatCheck] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileExtension] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseFileExtension] [bit] NULL CONSTRAINT [DF_FTPFileIntakeTracker_UseFileExtension] DEFAULT ((0)),
[FrequencyID] [int] NULL,
[NotificationEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL CONSTRAINT [DF_FTPFileIntakeTracker_IsActive] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPFileMissingConfig] ADD CONSTRAINT [PK_FTPFileIntakeTracker] PRIMARY KEY CLUSTERED  ([FTPFileMissingConfigID]) ON [PRIMARY]
GO
