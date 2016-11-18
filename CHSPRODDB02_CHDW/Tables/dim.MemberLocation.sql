CREATE TABLE [dim].[MemberLocation]
(
[MemberLocationID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL,
[LocationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberLocation] ADD CONSTRAINT [PK_MemberLocation] PRIMARY KEY CLUSTERED  ([MemberLocationID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberLocation] ADD CONSTRAINT [FK_MemberLocation_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
