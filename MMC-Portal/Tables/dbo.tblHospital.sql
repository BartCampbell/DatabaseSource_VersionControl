CREATE TABLE [dbo].[tblHospital]
(
[id] [smallint] NOT NULL IDENTITY(1, 1),
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isActive] [bit] NULL CONSTRAINT [DF_Hospital_isActive] DEFAULT ((1)),
[isAdmit_date] [bit] NULL CONSTRAINT [DF_tblHospital_isAdmit_date] DEFAULT ((0))
) ON [PRIMARY]
GO
