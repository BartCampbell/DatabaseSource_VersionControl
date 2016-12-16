CREATE TABLE [dbo].[S_ZipCodeDetail]
(
[S_ZipCodeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ZipCode_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ZipCodeDetail] ADD CONSTRAINT [PK_S_ZipCodeDetail] PRIMARY KEY CLUSTERED  ([S_ZipCodeDetail_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-082016] ON [dbo].[S_ZipCodeDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ZipCodeDetail] ADD CONSTRAINT [FK_H_ZipCode_RK1] FOREIGN KEY ([H_ZipCode_RK]) REFERENCES [dbo].[H_ZipCode] ([H_ZipCode_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
