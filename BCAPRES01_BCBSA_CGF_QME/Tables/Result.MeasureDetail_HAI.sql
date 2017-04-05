CREATE TABLE [Result].[MeasureDetail_HAI]
(
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DischargeCount] [int] NOT NULL,
[DischargeWeight] [decimal] (24, 12) NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[HAI1_SIRClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAI1_SIRScore] [decimal] (12, 6) NULL,
[HAI1_SIRWeight] [decimal] (24, 12) NOT NULL,
[HAI2_SIRClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAI2_SIRScore] [decimal] (12, 6) NULL,
[HAI2_SIRWeight] [decimal] (24, 12) NOT NULL,
[HAI5_SIRClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAI5_SIRScore] [decimal] (12, 6) NULL,
[HAI5_SIRWeight] [decimal] (24, 12) NOT NULL,
[HAI6_SIRClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HAI6_SIRScore] [decimal] (12, 6) NULL,
[HAI6_SIRWeight] [decimal] (24, 12) NOT NULL,
[HospID] [int] NOT NULL,
[HospitalID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IhdsProviderID] [int] NOT NULL,
[NcqaPayer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ProductTypeID] [smallint] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_HAI_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_HAI] ADD CONSTRAINT [PK_Result_MeasureDetail_HAI] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_HAI] ON [Result].[MeasureDetail_HAI] ([ResultRowGuid]) ON [PRIMARY]
GO
