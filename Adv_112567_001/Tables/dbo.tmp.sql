CREATE TABLE [dbo].[tmp]
(
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider] [varchar] (125) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member] [varchar] (200) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DOB] [date] NULL,
[DOSs] [varchar] (max) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Inovice_Rec] [smalldatetime] NULL,
[RecFaxIn] [smalldatetime] NULL,
[RecMailIn] [smalldatetime] NULL,
[Extracted] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
