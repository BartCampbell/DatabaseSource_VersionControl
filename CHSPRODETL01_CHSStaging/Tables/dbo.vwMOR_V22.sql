CREATE TABLE [dbo].[vwMOR_V22]
(
[recordsource] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contractnumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordtypecode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HICN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mi] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dob] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ssn] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentYearandMonth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
