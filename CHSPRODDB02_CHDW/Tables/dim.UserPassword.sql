CREATE TABLE [dim].[UserPassword]
(
[UserPasswordID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtPassword] [date] NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_UserPassword_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_UserPassword_RecordEndUpdate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserPassword] ADD CONSTRAINT [PK_UserPassword] PRIMARY KEY CLUSTERED  ([UserPasswordID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserPassword] ADD CONSTRAINT [FK_UserPassword_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
