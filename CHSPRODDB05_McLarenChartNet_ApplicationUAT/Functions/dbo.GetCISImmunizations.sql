SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetCISImmunizations]
(
	@MemberID int
)
RETURNS 
@Results TABLE 
(
	[MemberID] [int] NOT NULL,
	[ServiceDate] [datetime] NULL,
	[HEDISSubMetricCode] [varchar](50) NOT NULL,
	[HEDISSubMetricComponentCode] [varchar](50) NOT NULL,
	[SourceType] [varchar](50) NOT NULL,
	[QuantityNeeded] int NOT NULL,
	[dtap_svc_adm] [int] NOT NULL,
	[diptheria_svc_adm] [int] NOT NULL,
	[tetanus_svc_adm] [int] NOT NULL,
	[pertussis_svc_adm] [int] NOT NULL,
	[total_dtap_adm] [int] NOT NULL,
	[dtap_svc_mr] [int] NOT NULL,
	[diptheria_svc_mr] [int] NOT NULL,
	[tetanus_svc_mr] [int] NOT NULL,
	[pertussis_svc_mr] [int] NOT NULL,
	[total_dtap_mr] [int] NOT NULL,
	[dtap_svc_hyb] [int] NOT NULL,
	[diptheria_svc_hyb] [int] NOT NULL,
	[tetanus_svc_hyb] [int] NOT NULL,
	[pertussis_svc_hyb] [int] NOT NULL,
	[total_dtap_hyb] [int] NOT NULL,
	[hepb_count_adm] [int] NOT NULL,
	[hepb_evidence_adm] [int] NOT NULL,
	[hepb_count_mr] [int] NOT NULL,
	[hepb_evidence_mr] [int] NOT NULL,
	[hepb_count_hyb] [int] NOT NULL,
	[hepb_evidence_hyb] [int] NOT NULL,
	[vzv_count_adm] [int] NOT NULL,
	[vzv_evidence_adm] [int] NOT NULL,
	[vzv_count_mr] [int] NOT NULL,
	[vzv_evidence_mr] [int] NOT NULL,
	[vzv_count_hyb] [int] NOT NULL,
	[vzv_evidence_hyb] [int] NOT NULL,
	[pneu_count_adm] [int] NOT NULL,
	[pneu_count_mr] [int] NOT NULL,
	[pneu_count_hyb] [int] NOT NULL,
	[ipv_count_adm] [int] NOT NULL,
	[ipv_count_mr] [int] NOT NULL,
	[ipv_count_hyb] [int] NOT NULL,
	[hib_count_adm] [int] NOT NULL,
	[hib_count_mr] [int] NOT NULL,
	[hib_count_hyb] [int] NOT NULL,
	[mmr_count_adm] [int] NOT NULL,
	[meas_count_adm] [int] NOT NULL,
	[mumps_count_adm] [int] NOT NULL,
	[rub_count_adm] [int] NOT NULL,
	[meas_evidence_adm] [int] NOT NULL,
	[mumps_evidence_adm] [int] NOT NULL,
	[rub_evidence_adm] [int] NOT NULL,
	[mmr_count_mr] [int] NOT NULL,
	[meas_count_mr] [int] NOT NULL,
	[mumps_count_mr] [int] NOT NULL,
	[rub_count_mr] [int] NOT NULL,
	[meas_evidence_mr] [int] NOT NULL,
	[mumps_evidence_mr] [int] NOT NULL,
	[rub_evidence_mr] [int] NOT NULL,
	[mmr_count_hyb] [int] NOT NULL,
	[meas_count_hyb] [int] NOT NULL,
	[mumps_count_hyb] [int] NOT NULL,
	[rub_count_hyb] [int] NOT NULL,
	[meas_evidence_hyb] [int] NOT NULL,
	[mumps_evidence_hyb] [int] NOT NULL,
	[rub_evidence_hyb] [int] NOT NULL,
	[hepa_count_adm] [int] NOT NULL,
	[hepa_evidence_adm] [int] NOT NULL,
	[hepa_count_mr] [int] NOT NULL,
	[hepa_evidence_mr] [int] NOT NULL,
	[hepa_count_hyb] [int] NOT NULL,
	[hepa_evidence_hyb] [int] NOT NULL,
	[rota2_count_adm] [int] NOT NULL,
	[rota3_count_adm] [int] NOT NULL,
	[rota2_count_mr] [int] NOT NULL,
	[rota3_count_mr] [int] NOT NULL,
	[rota2_count_hyb] [int] NOT NULL,
	[rota3_count_hyb] [int] NOT NULL,
	[infl_count_adm] [int] NOT NULL,
	[infl_count_mr] [int] NOT NULL,
	[infl_count_hyb] [int] NOT NULL
)
AS
BEGIN
	DECLARE @HEDISSubMetricComponent TABLE
	(
	 HEDISSubMetricComponentID int IDENTITY(1, 1) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 HEDISSubMetricComponentDesc varchar(50) NOT NULL,
	 HEDISSubMetricCode varchar(50) NOT NULL,
	 StartDays int NOT NULL,
	 StartMonths int NOT NULL,
	 EndDays int NOT NULL,
	 EndMonths int NOT NULL,
	 QuantityNeeded int NOT NULL,
	 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentID),
	 UNIQUE NONCLUSTERED (HEDISSubMetricComponentCode)
	);

	INSERT INTO @HEDISSubMetricComponent
	        (HEDISSubMetricComponentCode,
	        HEDISSubMetricComponentDesc,
	        HEDISSubMetricCode,
			StartDays,
			StartMonths,
			EndDays,
			EndMonths,
			QuantityNeeded)
	SELECT	HEDISSubMetricComponentCode,
			HEDISSubMetricComponentDesc,
			HEDISSubMetricCode,
			StartDays,
			StartMonths,
			EndDays,
			EndMonths,
			ISNULL(QuantityNeeded, 1) 
    FROM	dbo.GetCISMetricComponents();

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @HEDISSubMetricComponent

	DECLARE @HEDISSubMetricComponent_ProcCode_xref TABLE
	(
	 ProcCode varchar(10) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 PRIMARY KEY CLUSTERED (ProcCode, HEDISSubMetricComponentCode)
	);

	INSERT  INTO @HEDISSubMetricComponent_ProcCode_xref VALUES  
	('90698', 'DTP')
	,('90700', 'DTP')
	,('90721', 'DTP')
	,('90723', 'DTP')
	,('90698', 'IPV')
	,('90713', 'IPV')
	,('90723', 'IPV')
	,('90705', 'MMR')
	,('90707', 'MMR')
	,('90710', 'MMR')
	,('90708', 'MMR')
	,('90704', 'MMR')
	,('90706', 'MMR')
	,('90644', 'HIB')
	,('90645', 'HIB')
	,('90646', 'HIB')
	,('90647', 'HIB')
	,('90648', 'HIB')
	,('90698', 'HIB')
	,('90721', 'HIB')
	,('90748', 'HIB')
	,('90723', 'HEPB')
	,('90740', 'HEPB')
	,('90744', 'HEPB')
	,('90747', 'HEPB')
	,('90748', 'HEPB')
	,('G0010', 'HEPB')
	,('3E0234Z', 'HEPB')
	,('99.55', 'HEPB')
	,('90710', 'VZV')
	,('90716', 'VZV')
	,('90669', 'PNEU')
	,('90670', 'PNEU')
	,('G0009', 'PNEU')
	,('90633', 'HEPA')
	,('90681', 'ROTA2')
	,('90680', 'ROTA3')
	,('90655', 'INFL')
	,('90657', 'INFL')
	,('90661', 'INFL')
	,('90662', 'INFL')
	,('90673', 'INFL')
	,('90685', 'INFL')
	,('90687', 'INFL')
	,('G0008', 'INFL')

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @HEDISSubMetricComponent_ProcCode_xref


	DECLARE @HEDISSubMetricComponent_DiagCode3_xref TABLE
	(
	 DiagCode3 varchar(3) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentCode, DiagCode3)
	)

	INSERT  INTO @HEDISSubMetricComponent_DiagCode3_xref VALUES  
	('B15', 'HEPA')
	,('B16', 'HEPB')
	,('B17', 'HEPB')
	,('B18', 'HEPB')
	,('B19', 'HEPB')
	,('Z22', 'HEPB')
	,('B05', 'MMR')
	,('B06', 'MMR')
	,('B26', 'MMR')
	,('B01', 'VZV')
	,('B02', 'VZV')

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @HEDISSubMetricComponent_DiagCode3_xref

	DECLARE @HEDISSubMetricComponent_DiagCode5_xref TABLE
	(
	 DiagCode5 varchar(10) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentCode, DiagCode5)
	)

	INSERT  INTO @HEDISSubMetricComponent_DiagCode5_xref VALUES  
	('070.0', 'HEPA')
	,('070.1', 'HEPA')
	,('070.2', 'HEPB')
	,('070.3', 'HEPB')
	,('V02.6', 'HEPB')
	,('055.0', 'MMR')
	,('055.1', 'MMR')
	,('055.2', 'MMR')
	,('055.7', 'MMR')
	,('055.8', 'MMR')
	,('055.9', 'MMR')
	,('056.0', 'MMR')
	,('056.7', 'MMR')
	,('056.8', 'MMR')
	,('056.9', 'MMR')
	,('072.0', 'MMR')
	,('072.1', 'MMR')
	,('072.2', 'MMR')
	,('072.3', 'MMR')
	,('072.7', 'MMR')
	,('072.8', 'MMR')
	,('072.9', 'MMR')
	,('052.0', 'VZV')
	,('052.1', 'VZV')
	,('052.2', 'VZV')
	,('052.7', 'VZV')
	,('052.8', 'VZV')
	,('052.9', 'VZV')
	,('053.0', 'VZV')
	,('053.1', 'VZV')
	,('053.2', 'VZV')
	,('053.7', 'VZV')
	,('053.8', 'VZV')
	,('053.9', 'VZV')

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @HEDISSubMetricComponent_DiagCode5_xref


	DECLARE @HEDISSubMetricComponent_ICD9Proc_xref TABLE
	(
	 ICD9Proc varchar(10) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentCode, ICD9Proc)
	)

	INSERT  INTO @HEDISSubMetricComponent_ICD9Proc_xref VALUES  
	('3E0234Z', 'HEPB')
	,('99.55', 'HEPB')

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @HEDISSubMetricComponent_ICD9Proc_xref


	DECLARE @AdministrativeEvent table
	(
		MeasureID int NOT NULL,
		HEDISSubMetricComponentCode varchar(50) NOT NULL,
		HEDISSubMetricComponentID int NOT NULL,
		HEDISSubMetricCode varchar(50) NOT NULL,
		MemberID int NOT NULL,
		ServiceDate datetime NULL,
		DateOfBirth datetime NULL,
		DateOfBirth_42days datetime NULL,
		DateOfBirth_2years datetime NULL,
		DateOfBirth_180days datetime NULL
	);

	INSERT INTO @AdministrativeEvent
			(MeasureID,
			HEDISSubMetricComponentCode,
			HEDISSubMetricComponentID,
			HEDISSubMetricCode,
			MemberID,
			ServiceDate,
			DateOfBirth,
			DateOfBirth_42days,
			DateOfBirth_2years,
			DateOfBirth_180days)
	SELECT DISTINCT
			MeasureID = a.MeasureID,
			HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode,
			HEDISSubMetricComponentID = c.HEDISSubMetricComponentID,
			HEDISSubMetricCode = c.HEDISSubMetricCode,
			MemberID = a.MemberID,
			ServiceDate = a.ServiceDate,
			DateOfBirth,
			DateOfBirth_42days = DATEADD(dd, 42, DateOfBirth),
			DateOfBirth_2years = DATEADD(yy, 2, DateOfBirth),
			DateOfBirth_180days = DATEADD(dd, 180, DateOfBirth)
	FROM    AdministrativeEvent a
			INNER JOIN @HEDISSubMetricComponent_ProcCode_xref b ON a.ProcedureCode = b.ProcCode
			INNER JOIN @HEDISSubMetricComponent c ON b.HEDISSubMetricComponentCode = c.HEDISSubMetricComponentCode
			INNER JOIN Member d ON a.MemberID = d.MemberID
	WHERE   a.MemberID = @MemberID 

	INSERT  INTO @AdministrativeEvent
			SELECT DISTINCT
					MeasureID = a.MeasureID,
					HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode,
					HEDISSubMetricComponentID = c.HEDISSubMetricComponentID,
					HEDISSubMetricCode = c.HEDISSubMetricCode,
					MemberID = a.MemberID,
					ServiceDate = a.ServiceDate,
					DateOfBirth,
					DateOfBirth_42days = DATEADD(dd, 42, DateOfBirth),
					DateOfBirth_2years = DATEADD(yy, 2, DateOfBirth),
					DateOfBirth_180days = DATEADD(dd, 180, DateOfBirth)
			FROM    AdministrativeEvent a
					INNER JOIN @HEDISSubMetricComponent_DiagCode3_xref b ON LEFT(a.DiagnosisCode, 3) = b.DiagCode3
					INNER JOIN @HEDISSubMetricComponent c ON b.HEDISSubMetricComponentCode = c.HEDISSubMetricComponentCode
					INNER JOIN Member d ON a.MemberID = d.MemberID
			WHERE   a.MemberID = @MemberID AND
					NOT EXISTS ( SELECT *
								 FROM   @AdministrativeEvent a2
								 WHERE  a.MemberID = a2.MemberID AND
										a.ServiceDate = a2.ServiceDate AND
										b.HEDISSubMetricComponentCode = a2.HEDISSubMetricComponentCode )

	INSERT  INTO @AdministrativeEvent
			SELECT DISTINCT
					MeasureID = a.MeasureID,
					HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode,
					HEDISSubMetricComponentID = c.HEDISSubMetricComponentID,
					HEDISSubMetricCode = c.HEDISSubMetricCode,
					MemberID = a.MemberID,
					ServiceDate = a.ServiceDate,
					DateOfBirth,
					DateOfBirth_42days = DATEADD(dd, 42, DateOfBirth),
					DateOfBirth_2years = DATEADD(yy, 2, DateOfBirth),
					DateOfBirth_180days = DATEADD(dd, 180, DateOfBirth)
			FROM    AdministrativeEvent a
					INNER JOIN @HEDISSubMetricComponent_DiagCode5_xref b ON LEFT(a.DiagnosisCode,
																  5) = b.DiagCode5
					INNER JOIN @HEDISSubMetricComponent c ON b.HEDISSubMetricComponentCode = c.HEDISSubMetricComponentCode
					INNER JOIN Member d ON a.MemberID = d.MemberID
			WHERE   a.MemberID = @MemberID AND
					NOT EXISTS ( SELECT *
								 FROM   @AdministrativeEvent a2
								 WHERE  a.MemberID = a2.MemberID AND
										a.ServiceDate = a2.ServiceDate AND
										b.HEDISSubMetricComponentCode = a2.HEDISSubMetricComponentCode )


	--set up a rules table that is 1 row per HEDISSubMetric, containing 
	--all necessary decision flags:


	DECLARE @SingleShotXref TABLE
	(
	 compound_shot varchar(50) NOT NULL,
	 single_shot varchar(50) NOT NULL,
	 HEDISSubMetricCode varchar(50) NOT NULL,
	 HEDISSubMetricComponentCode varchar(50) NOT NULL,
	 HEDISSubMetricID int NULL,
	 HEDISSubMetricComponentID int NULL,
	 PRIMARY KEY CLUSTERED (single_shot, HEDISSubMetricCode, compound_shot, HEDISSubMetricComponentCode)
	);

	INSERT  INTO @SingleShotXref
			(compound_shot,
			 single_shot,
			 HEDISSubMetricCode,
			 HEDISSubMetricComponentCode
			)
			SELECT  'DTaP',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL --standard
			SELECT  'Diphtheria',
					'Diphtheria',
					'CISDTP',
					'DIPTH'
			UNION ALL --standard
			SELECT  'Tetanus',
					'Tetanus',
					'CISDTP',
					'TET'
			UNION ALL --standard
			SELECT  'Acellular pertussis',
					'Acellular pertussis',
					'CISDTP',
					'AP'
			UNION ALL --standard
			SELECT  'DT',
					'Diphtheria',
					'CISDTP',
					'DIPTH'
			UNION ALL
			SELECT  'DT',
					'Tetanus',
					'CISDTP',
					'TET'
			UNION ALL
			SELECT  'Trihibit',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Trihibit',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'Trihibit (Dtap + HIB)',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Trihibit (Dtap + HIB)',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'Pediarix',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Pediarix',
					'IPV',
					'CISOPV',
					'IPV'
			UNION ALL
			SELECT  'Pediarix',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'Pentacel (DTap, HiB, IPV)',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Pentacel (DTap, HiB, IPV)',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'Pentacel (DTap, HiB, IPV)',
					'IPV',
					'CISOPV',
					'IPV'
			UNION ALL
			SELECT  'Tripedia',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Tripedia (Dtap)',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'DTP',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'DTP+',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Pertussis',
					'Acellular pertussis',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'HiB',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL --standard
			SELECT  'Comvax',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'Comvax',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'MMR',
					'MMR',
					'CISMMR',
					'MMR'
			UNION ALL --standard
			SELECT  'Measles',
					'Measles',
					'CISMMR',
					'MEAS'
			UNION ALL --standard
			SELECT  'Mumps',
					'Mumps',
					'CISMMR',
					'MUMPS'
			UNION ALL --standard
			SELECT  'Rubella',
					'Rubella',
					'CISMMR',
					'RUB'
			UNION ALL --standard
			SELECT  'Proquad',
					'MMR',
					'CISMMR',
					'MMR'
			UNION ALL
			SELECT  'Proquad',
					'VZV',
					'CISVZV',
					'VZV'
			UNION ALL
			SELECT  'Proquad (MMR + Varicella)',
					'MMR',
					'CISMMR',
					'MMR'
			UNION ALL
			SELECT  'Proquad (MMR + Varicella)',
					'VZV',
					'CISVZV',
					'VZV'
			UNION ALL
			SELECT  'MMRV (MMR and Varicella)',
					'MMR',
					'CISMMR',
					'MMR'
			UNION ALL
			SELECT  'MMRV (MMR and Varicella)',
					'VZV',
					'CISVZV',
					'VZV'
			UNION ALL
			SELECT  'VZV',
					'VZV',
					'CISVZV',
					'VZV'
			UNION ALL --standard
			SELECT  'Varicella',
					'VZV',
					'CISVZV',
					'VZV'
			UNION ALL
			SELECT  'VariVax',
					'VZV',
					'CISVZV',
					'VZV'
			--UNION ALL
			--SELECT  'VariVax',
			--        'IPV',
			--        'CISOPV',
			--        'IPV'
			UNION ALL
			SELECT  'VariVax (Varicella/Chicken Pox)',
					'VZV',
					'CISVZV',
					'VZV'
			--UNION ALL
			--SELECT  'VariVax (Varicella/Chicken Pox)',
			--        'IPV',
			--        'CISOPV',
			--        'IPV'
			UNION ALL
			SELECT  'IPV',
					'IPV',
					'CISOPV',
					'IPV'
			UNION ALL --standard
			SELECT  'HepB',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'Pneumo',
					'Pneumococcal conjugate',
					'CISPNEU',
					'PNEU'
			UNION ALL
			SELECT  'Hepatitis B',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'Pneumococcal conjugate',
					'Pneumococcal conjugate',
					'CISPNEU',
					'PNEU'
			UNION ALL
			SELECT  'Prevnar',
					'Pneumococcal conjugate',
					'CISPNEU',
					'PNEU'
			UNION ALL
			SELECT  'Prevnar (Pneumococcal Vaccine)',
					'Pneumococcal conjugate',
					'CISPNEU',
					'PNEU'
			UNION ALL
			SELECT  'Attenuvax(Measles)',
					'Measles',
					'CISMMR',
					'MEAS'
			UNION ALL
			SELECT  'Comvax (HIB + HepB)',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'Comvax (HIB + HepB)',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'HibTiTER (HIB)',
					'HiB',
					'CISHIB',
					'HIB'
			UNION ALL
			SELECT  'IPV (Polio)',
					'IPV',
					'CISOPV',
					'IPV'
			UNION ALL
			SELECT  'MMR (Measles, Mumps and Rubella)',
					'MMR',
					'CISMMR',
					'MMR'
			UNION ALL --standard
			SELECT  'Pediarix (DTaP/IPV/HepB)',
					'DTaP',
					'CISDTP',
					'DTP'
			UNION ALL
			SELECT  'Pediarix (DTaP/IPV/HepB)',
					'IPV',
					'CISOPV',
					'IPV'
			UNION ALL
			SELECT  'Pediarix (DTaP/IPV/HepB)',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'Recombinax HB (HepB (recombinant))',
					'Hepatitis B',
					'CISHEPB',
					'HEPB'
			UNION ALL
			SELECT  'Hepatitis A',
					'Hepatitis A',
					'CISHEPA',
					'HEPA'
			UNION ALL
			SELECT  'Rotarix (2)',
					'Rotarix (2)',
					'CISROTA',
					'ROTA2'
			UNION ALL
			SELECT  'Rotateq (3)',
					'Rotateq (3)',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus (3)',
					'Rotavirus (3)',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus 3',
					'Rotavirus 3',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus (Unknown Dosage)',
					'Rotavirus (Unknown Dosage)',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus',
					'Rotavirus 3',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus 2',
					'Rotavirus 2',
					'CISROTA',
					'ROTA2'
			--Added 11/16/2015-----------------
			UNION ALL
			SELECT  'Rotavirus, Unknown',
					'Rotavirus (Unknown Dosage)',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus, 3-Dose',
					'Rotavirus 3',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus, 2-Dose',
					'Rotavirus 2',
					'CISROTA',
					'ROTA2'
			UNION ALL
			SELECT  'Rotavirus Unknown',
					'Rotavirus (Unknown Dosage)',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus 3-Dose',
					'Rotavirus 3',
					'CISROTA',
					'ROTA3'
			UNION ALL
			SELECT  'Rotavirus 2-Dose',
					'Rotavirus 2',
					'CISROTA',
					'ROTA2'
			--END: Added 11/16/2015-----------------
			UNION ALL
			SELECT  'Influenza',
					'Influenza',
					'CISINFL',
					'INFL'
			UNION ALL
			SELECT  'Fluzone',
					'Influenza',
					'CISINFL',
					'INFL'	


	UPDATE  @SingleShotXref
	SET     HEDISSubMetricComponentID = b.HEDISSubMetricComponentID
	FROM    @SingleShotXref a
			INNER JOIN @HEDISSubMetricComponent b ON a.HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode


	UPDATE  @SingleShotXref
	SET     HEDISSubMetricID = b.HEDISSubMetricID
	FROM    @SingleShotXref a
			INNER JOIN HEDISSubMetric b ON a.HEDISSubMetricCode = b.HEDISSubMetricCode

	--IF @debug = 1 
	--	SELECT  *
	--	FROM    @SingleShotXref


	DECLARE @MedicalRecordEvent table
	(
		[MedicalRecordKey] [int] NOT NULL,
		[PursuitID] [int] NULL,
		[PursuitEventID] [int] NULL,
		[CIS_ImmunizationType] [varchar](50) NULL,
		[MedicalRecordEvidenceKey] [int] NULL,
		[CIS_MR_NumeratorEventFlag] [int] NULL,
		[CIS_MR_NumeratorEvidenceFlag] [int] NULL,
		[CIS_MR_ExclusionFlag] [int] NULL,
		[CIS_IMMEventFlag] [int] NULL,
		[CIS_HistIllnessFlag] [int] NULL,
		[CIS_SeroposResultFlag] [int] NULL,
		[CIS_ExclContrFlag] [int] NULL,
		[PursuitEventSequenceID] [int] NULL,
		[ServiceDate] [datetime] NULL,
		[CreatedDate] [datetime] NOT NULL DEFAULT (GETDATE()),
		[CreatedUser] [nvarchar](100) NULL,
		[LastChangedDate] [datetime] NOT NULL DEFAULT (GETDATE()),
		[LastChangedUser] [nvarchar](100) NULL,
		MemberID int NOT NULL,
		HEDISSubMetricCode varchar(50) NOT NULL,
		HEDISSubMetricComponentCode varchar(50) NOT NULL,
		DateOfBirth datetime NULL,
		DateOfBirth_42days datetime NULL,
		DateOfBirth_2years datetime NULL,
		DateOfBirth_180days datetime NULL
	);

	INSERT INTO @MedicalRecordEvent
			(MedicalRecordKey,
			PursuitID,
			PursuitEventID,
			CIS_ImmunizationType,
			MedicalRecordEvidenceKey,
			CIS_MR_NumeratorEventFlag,
			CIS_MR_NumeratorEvidenceFlag,
			CIS_MR_ExclusionFlag,
			CIS_IMMEventFlag,
			CIS_HistIllnessFlag,
			CIS_SeroposResultFlag,
			CIS_ExclContrFlag,
			PursuitEventSequenceID,
			ServiceDate,
			CreatedDate,
			CreatedUser,
			LastChangedDate,
			LastChangedUser,
			MemberID,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			DateOfBirth,
			DateOfBirth_42days,
			DateOfBirth_2years,
			DateOfBirth_180days)
	SELECT  a.MedicalRecordKey,
			a.PursuitID,
			a.PursuitEventID,
			a.CIS_ImmunizationType,
			a.MedicalRecordEvidenceKey,
			a.CIS_MR_NumeratorEventFlag,
			a.CIS_MR_NumeratorEvidenceFlag,
			a.CIS_MR_ExclusionFlag,
			a.CIS_IMMEventFlag,
			a.CIS_HistIllnessFlag,
			a.CIS_SeroposResultFlag,
			a.CIS_ExclContrFlag,
			a.PursuitEventSequenceID,
			a.ServiceDate,
			a.CreatedDate,
			a.CreatedUser,
			a.LastChangedDate,
			a.LastChangedUser,
			b.MemberID,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			DateOfBirth,
			DateOfBirth_42days = DATEADD(dd, 42, DateOfBirth),
			DateOfBirth_2years = DATEADD(yy, 2, DateOfBirth),
			DateOfBirth_180days = DATEADD(dd, 180, DateOfBirth)
	FROM    MedicalRecordCIS a
			INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
			INNER JOIN @SingleShotXref c ON a.CIS_ImmunizationType = c.compound_shot
			INNER JOIN Member d ON b.MemberID = d.MemberID
	WHERE   CIS_IMMEventFlag = 1 AND
			b.MemberID = @MemberID /*AND
			NOT EXISTS ( SELECT *
						 FROM   @AdministrativeEvent a2
						 WHERE  b.MemberID = a2.MemberID AND
									c.HEDISSubMetricComponentID = a2.HEDISSubMetricComponentID AND
								a.ServiceDate BETWEEN DATEADD(dd, -14, a2.ServiceDate) AND DATEADD(dd, 14, a2.ServiceDate))*/
	UNION ALL
	SELECT  a.MedicalRecordKey,
			a.PursuitID,
			a.PursuitEventID,
			a.CIS_ImmunizationType,
			a.MedicalRecordEvidenceKey,
			a.CIS_MR_NumeratorEventFlag,
			a.CIS_MR_NumeratorEvidenceFlag,
			a.CIS_MR_ExclusionFlag,
			a.CIS_IMMEventFlag,
			a.CIS_HistIllnessFlag,
			a.CIS_SeroposResultFlag,
			a.CIS_ExclContrFlag,
			a.PursuitEventSequenceID,
			a.ServiceDate,
			a.CreatedDate,
			a.CreatedUser,
			a.LastChangedDate,
			a.LastChangedUser,
			b.MemberID,
			e.HEDISSubMetricCode,
			d.HEDISSubMetricComponentCode,
			DateOfBirth,
			DateOfBirth_42days = DATEADD(dd, 42, DateOfBirth),
			DateOfBirth_2years = DATEADD(yy, 2, DateOfBirth),
			DateOfBirth_180days = DATEADD(dd, 180, DateOfBirth)
	FROM    MedicalRecordCIS a
			INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
			INNER JOIN MedicalRecordEvidence c ON a.MedicalRecordEvidenceKey = c.EvidenceKey
			INNER JOIN Member f ON b.MemberID = f.MemberID
			INNER JOIN @HEDISSubMetricComponent d ON d.HEDISSubMetricComponentCode = CASE
																  WHEN c.Description = 'Measles'
																  THEN 'MEAS_Evidence'
																  WHEN c.Description = 'Mumps'
																  THEN 'MUMPS_Evidence'
																  WHEN c.Description = 'Rubella'
																  THEN 'RUB_Evidence'
																  WHEN c.Description = 'MMR'
																  THEN 'MMR_Evidence'
																  WHEN c.Description = 'Hepatitis B'
																  THEN 'HEPB_Evidence'
																  WHEN c.Description = 'VZV'
																  THEN 'VZV_Evidence'
																  WHEN c.Description = 'Chicken Pox'
																  THEN 'VZV_Evidence'
																  WHEN c.Description = 'Hepatitis A'
																  THEN 'HEPA_Evidence'
																  ELSE ''
																  END
			INNER JOIN HEDISSubMetric e ON d.HEDISSubMetricCode = e.HEDISSubMetricCode
	WHERE   (CIS_HistIllnessFlag = 1 OR CIS_SeroposResultFlag = 1) AND
			b.MemberID = @MemberID /*AND
			NOT EXISTS ( SELECT *
						 FROM   @AdministrativeEvent a2
						 WHERE  b.MemberID = a2.MemberID AND
									d.HEDISSubMetricComponentID = a2.HEDISSubMetricComponentID AND
								a.ServiceDate BETWEEN DATEADD(dd, -14, a2.ServiceDate) AND DATEADD(dd, 14, a2.ServiceDate) )*/


	DELETE	AV 
	FROM	@AdministrativeEvent AS AV 
			INNER JOIN @MedicalRecordEvent AS MRV 
					ON MRV.MemberID = AV.MemberID AND 
						MRV.HEDISSubMetricComponentCode = AV.HEDISSubMetricComponentCode AND
						MRV.ServiceDate BETWEEN DATEADD(dd, -14, AV.ServiceDate) AND DATEADD(dd, 14, AV.ServiceDate)

	--IF @debug = 1 
	--	SELECT  '@AdministrativeEvent' AS TableName, *
	--	FROM    @AdministrativeEvent

	--IF @debug = 1 
	--	SELECT  '@MedicalRecordEvent' AS TableName, *
	--	FROM    @MedicalRecordEvent

	--DECLARE @SubMetricRuleComponentMetricsMedicalRecordDetail TABLE
	--(
	--	[MemberID] [int] NOT NULL,
	--	[ServiceDate] [datetime] NULL,
	--	[HEDISSubMetricCode] [varchar](50) NOT NULL,
	--	[HEDISSubMetricComponentCode] [varchar](50) NOT NULL,
	--	[dtap_svc_adm] [int] NOT NULL,
	--	[diptheria_svc_adm] [int] NOT NULL,
	--	[tetanus_svc_adm] [int] NOT NULL,
	--	[pertussis_svc_adm] [int] NOT NULL,
	--	[total_dtap_adm] [int] NOT NULL,
	--	[dtap_svc_mr] [int] NOT NULL,
	--	[diptheria_svc_mr] [int] NOT NULL,
	--	[tetanus_svc_mr] [int] NOT NULL,
	--	[pertussis_svc_mr] [int] NOT NULL,
	--	[total_dtap_mr] [int] NOT NULL,
	--	[dtap_svc_hyb] [int] NOT NULL,
	--	[diptheria_svc_hyb] [int] NOT NULL,
	--	[tetanus_svc_hyb] [int] NOT NULL,
	--	[pertussis_svc_hyb] [int] NOT NULL,
	--	[total_dtap_hyb] [int] NOT NULL,
	--	[hepb_count_adm] [int] NOT NULL,
	--	[hepb_evidence_adm] [int] NOT NULL,
	--	[hepb_count_mr] [int] NOT NULL,
	--	[hepb_evidence_mr] [int] NOT NULL,
	--	[hepb_count_hyb] [int] NOT NULL,
	--	[hepb_evidence_hyb] [int] NOT NULL,
	--	[vzv_count_adm] [int] NOT NULL,
	--	[vzv_evidence_adm] [int] NOT NULL,
	--	[vzv_count_mr] [int] NOT NULL,
	--	[vzv_evidence_mr] [int] NOT NULL,
	--	[vzv_count_hyb] [int] NOT NULL,
	--	[vzv_evidence_hyb] [int] NOT NULL,
	--	[pneu_count_adm] [int] NOT NULL,
	--	[pneu_count_mr] [int] NOT NULL,
	--	[pneu_count_hyb] [int] NOT NULL,
	--	[ipv_count_adm] [int] NOT NULL,
	--	[ipv_count_mr] [int] NOT NULL,
	--	[ipv_count_hyb] [int] NOT NULL,
	--	[hib_count_adm] [int] NOT NULL,
	--	[hib_count_mr] [int] NOT NULL,
	--	[hib_count_hyb] [int] NOT NULL,
	--	[mmr_count_adm] [int] NOT NULL,
	--	[meas_count_adm] [int] NOT NULL,
	--	[mumps_count_adm] [int] NOT NULL,
	--	[rub_count_adm] [int] NOT NULL,
	--	[meas_evidence_adm] [int] NOT NULL,
	--	[mumps_evidence_adm] [int] NOT NULL,
	--	[rub_evidence_adm] [int] NOT NULL,
	--	[mmr_count_mr] [int] NOT NULL,
	--	[meas_count_mr] [int] NOT NULL,
	--	[mumps_count_mr] [int] NOT NULL,
	--	[rub_count_mr] [int] NOT NULL,
	--	[meas_evidence_mr] [int] NOT NULL,
	--	[mumps_evidence_mr] [int] NOT NULL,
	--	[rub_evidence_mr] [int] NOT NULL,
	--	[mmr_count_hyb] [int] NOT NULL,
	--	[meas_count_hyb] [int] NOT NULL,
	--	[mumps_count_hyb] [int] NOT NULL,
	--	[rub_count_hyb] [int] NOT NULL,
	--	[meas_evidence_hyb] [int] NOT NULL,
	--	[mumps_evidence_hyb] [int] NOT NULL,
	--	[rub_evidence_hyb] [int] NOT NULL,
	--	[hepa_count_adm] [int] NOT NULL,
	--	[hepa_evidence_adm] [int] NOT NULL,
	--	[hepa_count_mr] [int] NOT NULL,
	--	[hepa_evidence_mr] [int] NOT NULL,
	--	[hepa_count_hyb] [int] NOT NULL,
	--	[hepa_evidence_hyb] [int] NOT NULL,
	--	[rota2_count_adm] [int] NOT NULL,
	--	[rota3_count_adm] [int] NOT NULL,
	--	[rota2_count_mr] [int] NOT NULL,
	--	[rota3_count_mr] [int] NOT NULL,
	--	[rota2_count_hyb] [int] NOT NULL,
	--	[rota3_count_hyb] [int] NOT NULL,
	--	[infl_count_adm] [int] NOT NULL,
	--	[infl_count_mr] [int] NOT NULL,
	--	[infl_count_hyb] [int] NOT NULL
	--);

	INSERT INTO @Results
			(MemberID,
			 ServiceDate,
			 HEDISSubMetricCode,
			 HEDISSubMetricComponentCode,
			 SourceType,
			 QuantityNeeded,
			 dtap_svc_adm,
			 diptheria_svc_adm,
			 tetanus_svc_adm,
			 pertussis_svc_adm,
			 total_dtap_adm,
			 dtap_svc_mr,
			 diptheria_svc_mr,
			 tetanus_svc_mr,
			 pertussis_svc_mr,
			 total_dtap_mr,
			 dtap_svc_hyb,
			 diptheria_svc_hyb,
			 tetanus_svc_hyb,
			 pertussis_svc_hyb,
			 total_dtap_hyb,
			 hepb_count_adm,
			 hepb_evidence_adm,
			 hepb_count_mr,
			 hepb_evidence_mr,
			 hepb_count_hyb,
			 hepb_evidence_hyb,
			 vzv_count_adm,
			 vzv_evidence_adm,
			 vzv_count_mr,
			 vzv_evidence_mr,
			 vzv_count_hyb,
			 vzv_evidence_hyb,
			 pneu_count_adm,
			 pneu_count_mr,
			 pneu_count_hyb,
			 ipv_count_adm,
			 ipv_count_mr,
			 ipv_count_hyb,
			 hib_count_adm,
			 hib_count_mr,
			 hib_count_hyb,
			 mmr_count_adm,
			 meas_count_adm,
			 mumps_count_adm,
			 rub_count_adm,
			 meas_evidence_adm,
			 mumps_evidence_adm,
			 rub_evidence_adm,
			 mmr_count_mr,
			 meas_count_mr,
			 mumps_count_mr,
			 rub_count_mr,
			 meas_evidence_mr,
			 mumps_evidence_mr,
			 rub_evidence_mr,
			 mmr_count_hyb,
			 meas_count_hyb,
			 mumps_count_hyb,
			 rub_count_hyb,
			 meas_evidence_hyb,
			 mumps_evidence_hyb,
			 rub_evidence_hyb,
			 hepa_count_adm,
			 hepa_evidence_adm,
			 hepa_count_mr,
			 hepa_evidence_mr,
			 hepa_count_hyb,
			 hepa_evidence_hyb,
			 rota2_count_adm,
			 rota3_count_adm,
			 rota2_count_mr,
			 rota3_count_mr,
			 rota2_count_hyb,
			 rota3_count_hyb,
			 infl_count_adm,
			 infl_count_mr,
			 infl_count_hyb)
	SELECT  MemberID,
			ServiceDate,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			SourceType = 'MR',
			QuantityNeeded,
			--************************************************************************************************
			dtap_svc_adm = 0,
			diptheria_svc_adm = 0,
			tetanus_svc_adm = 0,
			pertussis_svc_adm = 0,
			total_dtap_adm = 0,
			dtap_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'DTP' /*AND
									ServiceDate BETWEEN DateOfBirth_42days
												AND     DateOfBirth_2years*/
							   THEN 1
							   ELSE 0
						  END,
			diptheria_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'DIPTH' /*AND
										 ServiceDate BETWEEN DateOfBirth_42days
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			tetanus_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'TET' /*AND
									   ServiceDate BETWEEN DateOfBirth_42days
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			pertussis_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'AP' /*AND
										 ServiceDate BETWEEN DateOfBirth_42days
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			total_dtap_mr = 0,
			dtap_svc_hyb = 0,
			diptheria_svc_hyb = 0,
			tetanus_svc_hyb = 0,
			pertussis_svc_hyb = 0,
			total_dtap_hyb = 0,
			--************************************************************************************************
			hepb_count_adm = 0,
			hepb_evidence_adm = 0,
			hepb_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'HEPB' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			hepb_evidence_mr = CASE WHEN HEDISSubMetricComponentCode = 'HEPB_Evidence' /*AND
										 ServiceDate BETWEEN DateOfBirth
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			hepb_count_hyb = 0,
			hepb_evidence_hyb = 0,
			--************************************************************************************************
			vzv_count_adm = 0,
			vzv_evidence_adm = 0,
			vzv_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'VZV' /*AND
									 ServiceDate BETWEEN DateOfBirth
												 AND     DateOfBirth_2years*/ 
								THEN 1
								ELSE 0
						   END,
			vzv_evidence_mr = CASE WHEN HEDISSubMetricComponentCode = 'VZV_Evidence' /*AND
										ServiceDate BETWEEN DateOfBirth
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			vzv_count_hyb = 0,
			vzv_evidence_hyb = 0,
			--************************************************************************************************
			pneu_count_adm = 0,
			pneu_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'PNEU' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			pneu_count_hyb = 0,
			--************************************************************************************************
			ipv_count_adm = 0,
			ipv_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'IPV' AND
									 ServiceDate BETWEEN DateOfBirth_42days
												 AND     DateOfBirth_2years THEN 1
								ELSE 0
						   END,
			ipv_count_hyb = 0,
			--************************************************************************************************
			hib_count_adm = 0,
			hib_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'HIB' /*AND
									 ServiceDate BETWEEN DateOfBirth_42days
												 AND     DateOfBirth_2years*/ 
								THEN 1
								ELSE 0
						   END,
			hib_count_hyb = 0,
			--************************************************************************************************
			mmr_count_adm = 0,
			meas_count_adm = 0,
			mumps_count_adm = 0,
			rub_count_adm = 0,
			meas_evidence_adm = 0,
			mumps_evidence_adm = 0,
			rub_evidence_adm = 0,
			mmr_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'MMR' /*AND
									 ServiceDate BETWEEN DateOfBirth
												 AND     DateOfBirth_2years*/ 
								THEN 1
								ELSE 0
						   END,
			meas_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'MEAS' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			mumps_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'MUMPS' /*AND
									   ServiceDate BETWEEN DateOfBirth
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			rub_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'RUB' /*AND
									 ServiceDate BETWEEN DateOfBirth
												 AND     DateOfBirth_2years*/ 
								THEN 1
								ELSE 0
						   END,
			meas_evidence_mr = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'MEAS_Evidence') /*AND
										 ServiceDate BETWEEN DateOfBirth
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			mumps_evidence_mr = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'MUMPS_Evidence') /*AND
										  ServiceDate BETWEEN DateOfBirth
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			rub_evidence_mr = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'RUB_Evidence') /*AND
										ServiceDate BETWEEN DateOfBirth
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			mmr_count_hyb = 0,
			meas_count_hyb = 0,
			mumps_count_hyb = 0,
			rub_count_hyb = 0,
			meas_evidence_hyb = 0,
			mumps_evidence_hyb = 0,
			rub_evidence_hyb = 0,
			--************************************************************************************************
			hepa_count_adm = 0,
			hepa_evidence_adm = 0,
			hepa_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'HEPA' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			hepa_evidence_mr = CASE WHEN HEDISSubMetricComponentCode = 'HEPA_Evidence' /*AND
										 ServiceDate BETWEEN DateOfBirth
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			hepa_count_hyb = 0,
			hepa_evidence_hyb = 0,
			--************************************************************************************************
			rota2_count_adm = 0,
			rota3_count_adm = 0,
			rota2_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'ROTA2' /*AND
									   ServiceDate BETWEEN DateOfBirth_42days
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			rota3_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'ROTA3' /*AND
									   ServiceDate BETWEEN DateOfBirth_42days
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			rota2_count_hyb = 0,
			rota3_count_hyb = 0,
			--************************************************************************************************
			infl_count_adm = 0,
			infl_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'INFL' /*AND
									  ServiceDate BETWEEN DateOfBirth_180days
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			infl_count_hyb = 0
			--************************************************************************************************
	FROM    @MedicalRecordEvent a
	--CROSS APPLY and WHERE statements replace the need for ServiceDate filtering the above CASE statements---------------------------------------------------------------------
			CROSS APPLY (
							SELECT	tb.StartDays, tb.StartMonths, tb.EndDays, tb.EndMonths, tb.QuantityNeeded
							FROM	@HEDISSubMetricComponent tb
							WHERE	tb.HEDISSubMetricCode = a.HEDISSubMetricCode AND
									tb.HEDISSubMetricComponentCode = a.HEDISSubMetricComponentCode
						) b
	WHERE	a.ServiceDate BETWEEN DATEADD(dd, b.StartDays, DATEADD(mm, b.StartMonths, a.DateOfBirth)) AND DATEADD(dd, b.EndDays, DATEADD(mm, b.EndMonths, a.DateOfBirth))
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	UNION ALL
	SELECT  MemberID,
			ServiceDate,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			SourceType = 'ADMIN',
			QuantityNeeded,
			--************************************************************************************************
			dtap_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'DTP' /*AND
									 ServiceDate BETWEEN DateOfBirth_42days
												 AND     DateOfBirth_2years*/ 
								THEN 1
								ELSE 0
						   END,
			diptheria_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'DIPTH' /*AND
										  ServiceDate BETWEEN DateOfBirth_42days
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			tetanus_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'TET' /*AND
										ServiceDate BETWEEN DateOfBirth_42days
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			pertussis_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'AP' /*AND
										  ServiceDate BETWEEN DateOfBirth_42days
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			total_dtap_adm = 0,
			dtap_svc_mr = 0,
			diptheria_svc_mr = 0,
			tetanus_svc_mr = 0,
			pertussis_svc_mr = 0,
			total_dtap_mr = 0,
			dtap_svc_hyb = 0,
			diptheria_svc_hyb = 0,
			tetanus_svc_hyb = 0,
			pertussis_svc_hyb = 0,
			total_dtap_hyb = 0,
			--************************************************************************************************
			hepb_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'HEPB' /*AND
									   ServiceDate BETWEEN DateOfBirth
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			hepb_evidence_adm = CASE WHEN HEDISSubMetricComponentCode = 'HEPB_Evidence' /*AND
										  ServiceDate BETWEEN DateOfBirth
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			hepb_count_mr = 0,
			hepb_evidence_mr = 0,
			hepb_count_hyb = 0,
			hepb_evidence_hyb = 0,
			--************************************************************************************************
			vzv_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'VZV' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			vzv_evidence_adm = CASE WHEN HEDISSubMetricComponentCode = 'VZV_Evidence' /*AND
										 ServiceDate BETWEEN DateOfBirth
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			vzv_count_mr = 0,
			vzv_evidence_mr = 0,
			vzv_count_hyb = 0,
			vzv_evidence_hyb = 0,
			--************************************************************************************************
			pneu_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'PNEU' /*AND
									   ServiceDate BETWEEN DateOfBirth
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			pneu_count_mr = 0,
			pneu_count_hyb = 0,
			--************************************************************************************************
			ipv_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'IPV' /*AND
									  ServiceDate BETWEEN DateOfBirth_42days
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			ipv_count_mr = 0,
			ipv_count_hyb = 0,
			--************************************************************************************************
			hib_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'HIB' /*AND
									  ServiceDate BETWEEN DateOfBirth_42days
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			hib_count_mr = 0,
			hib_count_hyb = 0,
			--************************************************************************************************
			mmr_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'MMR' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			meas_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'MEAS' /*AND
									   ServiceDate BETWEEN DateOfBirth
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			mumps_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'MUMPS' /*AND
										ServiceDate BETWEEN DateOfBirth
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			rub_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'RUB' /*AND
									  ServiceDate BETWEEN DateOfBirth
												  AND     DateOfBirth_2years*/
								 THEN 1
								 ELSE 0
							END,
			meas_evidence_adm = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'MEAS_Evidence') /*AND
										  ServiceDate BETWEEN DateOfBirth
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			mumps_evidence_adm = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'MUMPS_Evidence') /*AND
										   ServiceDate BETWEEN DateOfBirth
													   AND     DateOfBirth_2years*/
									  THEN 1
									  ELSE 0
								 END,
			rub_evidence_adm = CASE WHEN HEDISSubMetricComponentCode IN ('MMR_Evidence', 'RUB_Evidence') /*AND
										 ServiceDate BETWEEN DateOfBirth
													 AND     DateOfBirth_2years*/
									THEN 1
									ELSE 0
							   END,
			mmr_count_mr = 0,
			meas_count_mr = 0,
			mumps_count_mr = 0,
			rub_count_mr = 0,
			meas_evidence_mr = 0,
			mumps_evidence_mr = 0,
			rub_evidence_mr = 0,
			mmr_count_hyb = 0,
			meas_count_hyb = 0,
			mumps_count_hyb = 0,
			rub_count_hyb = 0,
			meas_evidence_hyb = 0,
			mumps_evidence_hyb = 0,
			rub_evidence_hyb = 0,
			--************************************************************************************************
			hepa_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'HEPA' /*AND
									   ServiceDate BETWEEN DateOfBirth
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			hepa_evidence_adm = CASE WHEN HEDISSubMetricComponentCode = 'HEPA_Evidence' /*AND
										  ServiceDate BETWEEN DateOfBirth
													  AND     DateOfBirth_2years*/
									 THEN 1
									 ELSE 0
								END,
			hepa_count_mr = 0,
			hepa_evidence_mr = 0,
			hepa_count_hyb = 0,
			hepa_evidence_hyb = 0,
			--************************************************************************************************
			rota2_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'ROTA2' /*AND
										ServiceDate BETWEEN DateOfBirth_42days
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			rota3_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'ROTA3' /*AND
										ServiceDate BETWEEN DateOfBirth_42days
													AND     DateOfBirth_2years*/
								   THEN 1
								   ELSE 0
							  END,
			rota2_count_mr = 0,
			rota3_count_mr = 0,
			rota2_count_hyb = 0,
			rota3_count_hyb = 0,
			--************************************************************************************************
			infl_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'INFL' /*AND
									   ServiceDate BETWEEN DateOfBirth_180days
												   AND     DateOfBirth_2years*/
								  THEN 1
								  ELSE 0
							 END,
			infl_count_mr = 0,
			infl_count_hyb = 0
			--************************************************************************************************
	FROM    @AdministrativeEvent a
	--CROSS APPLY and WHERE statements replace the need for ServiceDate filtering the above CASE statements---------------------------------------------------------------------
			CROSS APPLY (
							SELECT	tb.StartDays, tb.StartMonths, tb.EndDays, tb.EndMonths, tb.QuantityNeeded
							FROM	@HEDISSubMetricComponent tb
							WHERE	tb.HEDISSubMetricCode = a.HEDISSubMetricCode AND
									tb.HEDISSubMetricComponentCode = a.HEDISSubMetricComponentCode
						) b
	WHERE	a.ServiceDate BETWEEN DATEADD(dd, b.StartDays, DATEADD(mm, b.StartMonths, a.DateOfBirth)) AND DATEADD(dd, b.EndDays, DATEADD(mm, b.EndMonths, a.DateOfBirth))
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	RETURN 
END

GO
