CREATE TABLE [dbo].[S_Provider160807Details]
(
[S_Provider160807Details_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2001-PROVIDER-ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2003-PROV-NAME] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-PROV-LAST-NAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-PROV-FIRST-NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2712-PROV-SPECIALTY] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2615-PROV-TYPE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2001-PROV-ID-QUAL] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-2001-PROV-NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Provider160807Details] ADD CONSTRAINT [PK_S_Provider160807Details] PRIMARY KEY CLUSTERED  ([S_Provider160807Details_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Provider160807Details] ADD CONSTRAINT [FK_S_Provider160807Details_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
