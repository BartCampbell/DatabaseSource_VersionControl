CREATE TABLE [dbo].[S_Contact]
(
[S_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CellNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact] ADD CONSTRAINT [PK_S_Contact] PRIMARY KEY CLUSTERED  ([S_Contact_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCL_S_Contact_HashDiff] ON [dbo].[S_Contact] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact] ADD CONSTRAINT [FK_H_Contact_RK1] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
