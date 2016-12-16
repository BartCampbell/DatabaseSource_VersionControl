CREATE TABLE [dbo].[H_ZipCode]
(
[H_ZipCode_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientZipCodeID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ZipCode] ADD CONSTRAINT [PK_H_ZipCode] PRIMARY KEY CLUSTERED  ([H_ZipCode_RK]) ON [PRIMARY]
GO
