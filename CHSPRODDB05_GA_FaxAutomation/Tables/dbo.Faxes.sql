CREATE TABLE [dbo].[Faxes]
(
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_Faxes_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Faxes_CreatedUser] DEFAULT (suser_sname()),
[FaxGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Faxes_FaxGuid] DEFAULT (newid()),
[FaxID] [int] NOT NULL IDENTITY(1, 1),
[FaxNumber] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsSent] [bit] NOT NULL CONSTRAINT [DF_Faxes_IsSent] DEFAULT ((0)),
[LastAttemptDate] [datetime] NULL,
[RecipientName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RetryAttempts] [tinyint] NOT NULL CONSTRAINT [DF_Faxes_RetryAttempts] DEFAULT ((0)),
[SentDate] [datetime] NULL,
[Source] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceRef] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Response] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseRef] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendFaxResponse] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusUpdateResponse] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Faxes] ADD CONSTRAINT [PK_Faxes] PRIMARY KEY CLUSTERED  ([FaxID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Faxes_FaxGuid] ON [dbo].[Faxes] ([FaxGuid]) ON [PRIMARY]
GO
