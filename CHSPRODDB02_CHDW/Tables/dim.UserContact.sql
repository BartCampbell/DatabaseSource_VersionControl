CREATE TABLE [dim].[UserContact]
(
[UserContactID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_Tel] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_UserContact_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_UserContact_RecordEndUpdate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserContact] ADD CONSTRAINT [PK_UserContact] PRIMARY KEY CLUSTERED  ([UserContactID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserContact] ADD CONSTRAINT [FK_UserContact_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
