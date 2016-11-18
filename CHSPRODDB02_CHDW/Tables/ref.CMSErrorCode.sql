CREATE TABLE [ref].[CMSErrorCode]
(
[ErrorCode] [int] NOT NULL,
[ErrorDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CMSErrorCode] ADD CONSTRAINT [PK_CMSErrorCode] PRIMARY KEY CLUSTERED  ([ErrorCode]) ON [PRIMARY]
GO
