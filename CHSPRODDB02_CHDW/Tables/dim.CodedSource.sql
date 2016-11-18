CREATE TABLE [dim].[CodedSource]
(
[CodedSourceID] [int] NOT NULL IDENTITY(1, 1),
[CentauriCodedSourceID] [int] NULL,
[CodedSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortOrder] [smallint] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_CodedSource_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_CodedSource_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[CodedSource] ADD CONSTRAINT [PK_CodedSource] PRIMARY KEY CLUSTERED  ([CodedSourceID]) ON [PRIMARY]
GO
