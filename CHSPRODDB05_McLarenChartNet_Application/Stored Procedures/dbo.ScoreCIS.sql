SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for CIS measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordCIS table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreAWC '78551528'
CREATE PROCEDURE [dbo].[ScoreCIS] @MemberID int
AS 

SET NOCOUNT ON;

--*****************************************

DECLARE @debug bit
SET @debug = 0;

DECLARE @HEDISSubMetricComponent TABLE
(
 HEDISSubMetricComponentID int IDENTITY(1, 1) NOT NULL,
 HEDISSubMetricComponentCode varchar(50) NOT NULL,
 HEDISSubMetricComponentDesc varchar(50) NOT NULL,
 HEDISSubMetricCode varchar(50) NOT NULL,
 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentID),
 UNIQUE NONCLUSTERED (HEDISSubMetricComponentCode)
);

INSERT  INTO @HEDISSubMetricComponent VALUES  
('DTP', 'Diphtheria, Tetanus, and Acellular pertussis', 'CISDTP')
,('DIPTH', 'Diphtheria', 'CISDTP')
,('TET', 'Tetanus', 'CISDTP')
,('AP', 'Acellular pertussis', 'CISDTP')
,('HEPB', 'Hepatitis B', 'CISHEPB')
,('HEPB_Evidence', 'Hepatitis B Evidence', 'CISHEPB')
,('VZV', 'VZV', 'CISVZV')
,('VZV_Evidence', 'VZV Evidence', 'CISVZV')
,('PNEU', 'PNEU', 'CISPNEU')
,('IPV', 'IPV', 'CISOPV')
,('HIB', 'HIB', 'CISHIB')
,('MMR', 'MMR', 'CISMMR')
,('MEAS', 'Measles', 'CISMMR')
,('MEAS_Evidence', 'Measles Evidence', 'CISMMR')
,('MUMPS', 'Mumps', 'CISMMR')
,('MUMPS_Evidence', 'Mumps Evidence', 'CISMMR')
,('RUB', 'Rubella', 'CISMMR')
,('RUB_Evidence', 'Rubella Evidence', 'CISMMR')
,('MMR_Evidence', 'MMR Evidence', 'CISMMR')
,('HEPA', 'Hepatitis A', 'CISHEPA')
,('HEPA_Evidence', 'Hepatitis A Evidence', 'CISHEPA')
,('ROTA2', 'Rotavirus 2 Dose', 'CISROTA')
,('ROTA3', 'Rotavirus 3 Dose', 'CISROTA')
,('INFL', 'Influenza', 'CISINFL')

IF @debug = 1 
    SELECT  *
    FROM    @HEDISSubMetricComponent

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

IF @debug = 1 
    SELECT  *
    FROM    @HEDISSubMetricComponent_ProcCode_xref


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



IF @debug = 1 
    SELECT  *
    FROM    @HEDISSubMetricComponent_DiagCode3_xref

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


IF @debug = 1 
    SELECT  *
    FROM    @HEDISSubMetricComponent_DiagCode5_xref


DECLARE @HEDISSubMetricComponent_ICD9Proc_xref TABLE
(
 ICD9Proc varchar(10) NOT NULL,
 HEDISSubMetricComponentCode varchar(50) NOT NULL,
 PRIMARY KEY CLUSTERED (HEDISSubMetricComponentCode, ICD9Proc)
)

INSERT  INTO @HEDISSubMetricComponent_ICD9Proc_xref VALUES  
('3E0234Z', 'HEPB')
,('99.55', 'HEPB')


IF @debug = 1 
    SELECT  *
    FROM    @HEDISSubMetricComponent_ICD9Proc_xref


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

IF @debug = 1 
    SELECT  *
    FROM    @SingleShotXref


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
        b.MemberID = @MemberID AND
        NOT EXISTS ( SELECT *
                     FROM   @AdministrativeEvent a2
                     WHERE  b.MemberID = a2.MemberID AND
								c.HEDISSubMetricComponentID = a2.HEDISSubMetricComponentID AND
                            a.ServiceDate BETWEEN DATEADD(dd, -14, a2.ServiceDate) AND DATEADD(dd, 14, a2.ServiceDate))
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

IF @debug = 1 
    SELECT  '@AdministrativeEvent' AS TableName, *
    FROM    @AdministrativeEvent

IF @debug = 1 
    SELECT  '@MedicalRecordEvent' AS TableName, *
    FROM    @MedicalRecordEvent

DECLARE @SubMetricRuleComponentMetricsMedicalRecordDetail TABLE
(
	[MemberID] [int] NOT NULL,
	[ServiceDate] [datetime] NULL,
	[HEDISSubMetricCode] [varchar](50) NOT NULL,
	[HEDISSubMetricComponentCode] [varchar](50) NOT NULL,
	[SourceType] [varchar](50) NOT NULL,
	[QuantityNeeded] [int] NOT NULL,
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
);

INSERT INTO @SubMetricRuleComponentMetricsMedicalRecordDetail
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
SELECT	 MemberID,
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
         infl_count_hyb
FROM	dbo.GetCISImmunizations(@MemberID);

IF @debug = 1 
    SELECT  *
    FROM    @SubMetricRuleComponentMetricsMedicalRecordDetail


IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord

SELECT  MemberID,
        ServiceDate,
        HEDISSubMetricCode,
		--************************************************************************************************
        dtap_svc_adm = SUM(dtap_svc_adm),
        diptheria_svc_adm = SUM(diptheria_svc_adm),
        tetanus_svc_adm = SUM(tetanus_svc_adm),
        pertussis_svc_adm = SUM(pertussis_svc_adm),
        total_dtap_adm = 0,
        dtap_svc_mr = SUM(dtap_svc_mr),
        diptheria_svc_mr = SUM(diptheria_svc_mr),
        tetanus_svc_mr = SUM(tetanus_svc_mr),
        pertussis_svc_mr = SUM(pertussis_svc_mr),
        total_dtap_mr = 0,
        dtap_svc_hyb = SUM(dtap_svc_adm + dtap_svc_mr),
        diptheria_svc_hyb = SUM(diptheria_svc_adm + diptheria_svc_mr),
        tetanus_svc_hyb = SUM(tetanus_svc_adm + tetanus_svc_mr),
        pertussis_svc_hyb = SUM(pertussis_svc_adm + pertussis_svc_mr),
        total_dtap_hyb = 0,
		--************************************************************************************************
        hepb_count_adm = MAX(hepb_count_adm),
        hepb_evidence_adm = MAX(hepb_evidence_adm),
        hepb_count_mr = MAX(hepb_count_mr),
        hepb_evidence_mr = MAX(hepb_evidence_mr),
        hepb_count_hyb = MAX(CASE WHEN hepb_count_adm > 0 THEN hepb_count_adm
                                  ELSE hepb_count_mr
                             END),
        hepb_evidence_hyb = MAX(hepb_evidence_adm + hepb_evidence_mr),
		--************************************************************************************************
        vzv_count_adm = MAX(vzv_count_adm),
        vzv_evidence_adm = MAX(vzv_evidence_adm),
        vzv_count_mr = MAX(vzv_count_mr),
        vzv_evidence_mr = MAX(vzv_evidence_mr),
        vzv_count_hyb = MAX(vzv_count_adm + vzv_count_mr),
        vzv_evidence_hyb = MAX(vzv_evidence_adm + vzv_evidence_mr),
		--************************************************************************************************
        pneu_count_adm = MAX(pneu_count_adm),
        pneu_count_mr = MAX(pneu_count_mr),
        pneu_count_hyb = MAX(CASE WHEN pneu_count_adm > 0 THEN pneu_count_adm
                                  ELSE pneu_count_mr
                             END),
		--************************************************************************************************
        ipv_count_adm = MAX(ipv_count_adm),
        ipv_count_mr = MAX(ipv_count_mr),
        ipv_count_hyb = MAX(CASE WHEN ipv_count_adm > 0 THEN ipv_count_adm
                                 ELSE ipv_count_mr
                            END),
		--************************************************************************************************
        hib_count_adm = MAX(hib_count_adm),
        hib_count_mr = MAX(hib_count_mr),
        hib_count_hyb = MAX(CASE WHEN hib_count_adm > 0 THEN hib_count_adm
                                 ELSE hib_count_mr
                            END),
		--************************************************************************************************
        mmr_count_adm = MAX(mmr_count_adm),
        meas_count_adm = MAX(meas_count_adm),
        mumps_count_adm = MAX(mumps_count_adm),
        rub_count_adm = MAX(rub_count_adm),
        meas_evidence_adm = MAX(meas_evidence_adm),
        mumps_evidence_adm = MAX(mumps_evidence_adm),
        rub_evidence_adm = MAX(rub_evidence_adm),
        mmr_count_mr = MAX(mmr_count_mr),
        meas_count_mr = MAX(meas_count_mr),
        mumps_count_mr = MAX(mumps_count_mr),
        rub_count_mr = MAX(rub_count_mr),
        meas_evidence_mr = MAX(meas_evidence_mr),
        mumps_evidence_mr = MAX(mumps_evidence_mr),
        rub_evidence_mr = MAX(rub_evidence_mr),
        mmr_count_hyb = MAX(mmr_count_adm + mmr_count_mr),
        meas_count_hyb = MAX(meas_count_adm + meas_count_mr),
        mumps_count_hyb = MAX(mumps_count_adm + mumps_count_mr),
        rub_count_hyb = MAX(rub_count_adm + rub_count_mr),
        meas_evidence_hyb = MAX(meas_evidence_adm + meas_evidence_mr),
        mumps_evidence_hyb = MAX(mumps_evidence_adm + mumps_evidence_mr),
        rub_evidence_hyb = MAX(rub_evidence_adm + rub_evidence_mr),
		--************************************************************************************************
        hepa_count_adm = MAX(hepa_count_adm),
        hepa_evidence_adm = MAX(hepa_evidence_adm),
        hepa_count_mr = MAX(hepa_count_mr),
        hepa_evidence_mr = MAX(hepa_evidence_mr),
        hepa_count_hyb = MAX(hepa_count_adm + hepa_count_mr),
        hepa_evidence_hyb = MAX(hepa_evidence_adm + hepa_evidence_mr),
		--************************************************************************************************
        rota2_count_adm = MAX(rota2_count_adm),
        rota3_count_adm = MAX(rota3_count_adm),
        rota2_count_mr = MAX(rota2_count_mr),
        rota3_count_mr = MAX(rota3_count_mr),
        rota2_count_hyb = MAX(rota2_count_adm + rota2_count_mr),
        rota3_count_hyb = MAX(rota3_count_adm + rota3_count_mr),
		--************************************************************************************************
        infl_count_adm = MAX(infl_count_adm),
        infl_count_mr = MAX(infl_count_mr),
        infl_count_hyb = MAX(infl_count_adm + infl_count_mr)
		--************************************************************************************************
INTO    #SubMetricRuleComponentMetricsMedicalRecord
FROM    @SubMetricRuleComponentMetricsMedicalRecordDetail
GROUP BY MemberID,
        ServiceDate,
        HEDISSubMetricCode




UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
SET     total_dtap_adm = 1
WHERE   dtap_svc_adm > 0 OR
        (diptheria_svc_adm > 0 AND
         tetanus_svc_adm > 0 AND
         pertussis_svc_adm > 0
        ) 

UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
SET     total_dtap_mr = 1
WHERE   dtap_svc_mr > 0 OR
        (diptheria_svc_mr > 0 AND
         tetanus_svc_mr > 0 AND
         pertussis_svc_mr > 0
        ) 

UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
SET     total_dtap_hyb = 1
WHERE   dtap_svc_hyb > 0 OR
        (diptheria_svc_hyb > 0 AND
         tetanus_svc_hyb > 0 AND
         pertussis_svc_hyb > 0
        ) 


IF @debug = 1 
    SELECT  *
    FROM    #SubMetricRuleComponentMetricsMedicalRecord

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        c.HEDISSubMetricCode,
		--****************************************************************************************
        dtap_events_admin = SUM(total_dtap_adm),
        dtap_events_mr_supp = SUM(total_dtap_mr),
        dtap_events_hyb = SUM(total_dtap_hyb),
		--****************************************************************************************
        hepb_events_admin = SUM(hepb_count_adm),
        hepb_evidence_admin = SUM(hepb_evidence_adm),
        hepb_events_mr_supp = SUM(hepb_count_mr),
        hepb_evidence_mr_supp = SUM(hepb_evidence_mr),
        hepb_events_hyb = SUM(hepb_count_hyb),
        hepb_evidence_hyb = SUM(hepb_evidence_hyb),
		--****************************************************************************************
        vzv_events_admin = SUM(vzv_count_adm),
        vzv_evidence_admin = SUM(vzv_evidence_adm),
        vzv_events_mr_supp = SUM(vzv_count_mr),
        vzv_evidence_mr_supp = SUM(vzv_evidence_mr),
        vzv_events_hyb = SUM(vzv_count_hyb),
        vzv_evidence_hyb = SUM(vzv_evidence_hyb),
		--****************************************************************************************
        pneu_events_admin = SUM(pneu_count_adm),
        pneu_events_mr_supp = SUM(pneu_count_mr),
        pneu_events_hyb = SUM(pneu_count_hyb),
		--************************************************************************************************
        ipv_events_admin = SUM(ipv_count_adm),
        ipv_events_mr_supp = SUM(ipv_count_mr),
        ipv_events_hyb = SUM(ipv_count_hyb),
		--************************************************************************************************
        hib_events_admin = SUM(hib_count_adm),
        hib_events_mr_supp = SUM(hib_count_mr),
        hib_events_hyb = SUM(hib_count_hyb),
		--************************************************************************************************
        mmr_events_admin = SUM(mmr_count_adm),
        meas_events_admin = SUM(meas_count_adm),
        mumps_events_admin = SUM(mumps_count_adm),
        rub_events_admin = SUM(rub_count_adm),
        meas_evidence_admin = SUM(meas_evidence_adm),
        mumps_evidence_admin = SUM(mumps_evidence_adm),
        rub_evidence_admin = SUM(rub_evidence_adm),
        mmr_events_mr_supp = SUM(mmr_count_mr),
        meas_events_mr_supp = SUM(meas_count_mr),
        mumps_events_mr_supp = SUM(mumps_count_mr),
        rub_events_mr_supp = SUM(rub_count_mr),
        meas_evidence_mr_supp = SUM(meas_evidence_mr),
        mumps_evidence_mr_supp = SUM(mumps_evidence_mr),
        rub_evidence_mr_supp = SUM(rub_evidence_mr),
        mmr_events_hyb = SUM(mmr_count_hyb),
        meas_events_hyb = SUM(meas_count_hyb),
        mumps_events_hyb = SUM(mumps_count_hyb),
        rub_events_hyb = SUM(rub_count_hyb),
        meas_evidence_hyb = SUM(meas_evidence_hyb),
        mumps_evidence_hyb = SUM(mumps_evidence_hyb),
        rub_evidence_hyb = SUM(rub_evidence_hyb),
		--************************************************************************************************
        hepa_events_admin = SUM(hepa_count_adm),
        hepa_evidence_admin = SUM(hepa_evidence_adm),
        hepa_events_mr_supp = SUM(hepa_count_mr),
        hepa_evidence_mr_supp = SUM(hepa_evidence_mr),
        hepa_events_hyb = SUM(hepa_count_hyb),
        hepa_evidence_hyb = SUM(hepa_evidence_hyb),
		--************************************************************************************************
        rota2_events_admin = SUM(rota2_count_adm),
        rota3_events_admin = SUM(rota3_count_adm),
        rota2_events_mr_supp = SUM(rota2_count_mr),
        rota3_events_mr_supp = SUM(rota3_count_mr),
        rota2_events_hyb = SUM(rota2_count_hyb),
        rota3_events_hyb = SUM(rota3_count_hyb),
		--************************************************************************************************
        infl_events_admin = SUM(infl_count_adm),
        infl_events_mr_supp = SUM(infl_count_mr),
        infl_events_hyb = SUM(infl_count_hyb),
		--************************************************************************************************
        combo2_admin = 0,
        combo2_mr = 0,
        combo2_hyb = 0,
		--************************************************************************************************
        combo3_admin = 0,
        combo3_mr = 0,
        combo3_hyb = 0,
		--************************************************************************************************
        combo4_admin = 0,
        combo4_mr = 0,
        combo4_hyb = 0,
		--************************************************************************************************
        combo5_admin = 0,
        combo5_mr = 0,
        combo5_hyb = 0,
		--************************************************************************************************
        combo6_admin = 0,
        combo6_mr = 0,
        combo6_hyb = 0,
		--************************************************************************************************
        combo7_admin = 0,
        combo7_mr = 0,
        combo7_hyb = 0,
		--************************************************************************************************
        combo8_admin = 0,
        combo8_mr = 0,
        combo8_hyb = 0,
		--************************************************************************************************
        combo9_admin = 0,
        combo9_mr = 0,
        combo9_hyb = 0,
		--************************************************************************************************
        combo10_admin = 0,
        combo10_mr = 0,
        combo10_hyb = 0
		--************************************************************************************************
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
        LEFT JOIN #SubMetricRuleComponentMetricsMedicalRecord d ON d.MemberID = b.MemberID AND
                                                              d.HEDISSubMetricCode = c.HEDISSubMetricCode
WHERE   HEDISMeasureInit = 'CIS' AND
        b.MemberID = @MemberID
GROUP BY MemberMeasureMetricScoringID,
        c.HEDISSubMetricCode

IF @debug = 1 
    SELECT  *
    FROM    #SubMetricRuleComponents 

IF OBJECT_ID('tempdb..#SubMetricRuleComponentsTotal') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentsTotal

SELECT  dtap_events_admin = SUM(ISNULL(dtap_events_admin, 0)),
        dtap_events_mr_supp = SUM(ISNULL(dtap_events_mr_supp, 0)),
        dtap_events_hyb = SUM(ISNULL(dtap_events_hyb, 0)),
        hepb_events_admin = SUM(ISNULL(hepb_events_admin, 0)),
        hepb_evidence_admin = SUM(ISNULL(hepb_evidence_admin, 0)),
        hepb_events_mr_supp = SUM(ISNULL(hepb_events_mr_supp, 0)),
        hepb_evidence_mr_supp = SUM(ISNULL(hepb_evidence_mr_supp, 0)),
        hepb_events_hyb = SUM(ISNULL(hepb_events_hyb, 0)),
        hepb_evidence_hyb = SUM(ISNULL(hepb_evidence_hyb, 0)),
        vzv_events_admin = SUM(ISNULL(vzv_events_admin, 0)),
        vzv_evidence_admin = SUM(ISNULL(vzv_evidence_admin, 0)),
        vzv_events_mr_supp = SUM(ISNULL(vzv_events_mr_supp, 0)),
        vzv_evidence_mr_supp = SUM(ISNULL(vzv_evidence_mr_supp, 0)),
        vzv_events_hyb = SUM(ISNULL(vzv_events_hyb, 0)),
        vzv_evidence_hyb = SUM(ISNULL(vzv_evidence_hyb, 0)),
        pneu_events_admin = SUM(ISNULL(pneu_events_admin, 0)),
        pneu_events_mr_supp = SUM(ISNULL(pneu_events_mr_supp, 0)),
        pneu_events_hyb = SUM(ISNULL(pneu_events_hyb, 0)),
        ipv_events_admin = SUM(ISNULL(ipv_events_admin, 0)),
        ipv_events_mr_supp = SUM(ISNULL(ipv_events_mr_supp, 0)),
        ipv_events_hyb = SUM(ISNULL(ipv_events_hyb, 0)),
        hib_events_admin = SUM(ISNULL(hib_events_admin, 0)),
        hib_events_mr_supp = SUM(ISNULL(hib_events_mr_supp, 0)),
        hib_events_hyb = SUM(ISNULL(hib_events_hyb, 0)),
        mmr_events_admin = SUM(ISNULL(mmr_events_admin, 0)),
        meas_events_admin = SUM(ISNULL(meas_events_admin, 0)),
        mumps_events_admin = SUM(ISNULL(mumps_events_admin, 0)),
        rub_events_admin = SUM(ISNULL(rub_events_admin, 0)),
        meas_evidence_admin = SUM(ISNULL(meas_evidence_admin, 0)),
        mumps_evidence_admin = SUM(ISNULL(mumps_evidence_admin, 0)),
        rub_evidence_admin = SUM(ISNULL(rub_evidence_admin, 0)),
        mmr_events_mr_supp = SUM(ISNULL(mmr_events_mr_supp, 0)),
        meas_events_mr_supp = SUM(ISNULL(meas_events_mr_supp, 0)),
        mumps_events_mr_supp = SUM(ISNULL(mumps_events_mr_supp, 0)),
        rub_events_mr_supp = SUM(ISNULL(rub_events_mr_supp, 0)),
        meas_evidence_mr_supp = SUM(ISNULL(meas_evidence_mr_supp, 0)),
        mumps_evidence_mr_supp = SUM(ISNULL(mumps_evidence_mr_supp, 0)),
        rub_evidence_mr_supp = SUM(ISNULL(rub_evidence_mr_supp, 0)),
        mmr_events_hyb = SUM(ISNULL(mmr_events_hyb, 0)),
        meas_events_hyb = SUM(ISNULL(meas_events_hyb, 0)),
        mumps_events_hyb = SUM(ISNULL(mumps_events_hyb, 0)),
        rub_events_hyb = SUM(ISNULL(rub_events_hyb, 0)),
        meas_evidence_hyb = SUM(ISNULL(meas_evidence_hyb, 0)),
        mumps_evidence_hyb = SUM(ISNULL(mumps_evidence_hyb, 0)),
        rub_evidence_hyb = SUM(ISNULL(rub_evidence_hyb, 0)),
        hepa_events_admin = SUM(ISNULL(hepa_events_admin, 0)),
        hepa_evidence_admin = SUM(ISNULL(hepa_evidence_admin, 0)),
        hepa_events_mr_supp = SUM(ISNULL(hepa_events_mr_supp, 0)),
        hepa_evidence_mr_supp = SUM(ISNULL(hepa_evidence_mr_supp, 0)),
        hepa_events_hyb = SUM(ISNULL(hepa_events_hyb, 0)),
        hepa_evidence_hyb = SUM(ISNULL(hepa_evidence_hyb, 0)),
        rota2_events_admin = SUM(ISNULL(rota2_events_admin, 0)),
        rota3_events_admin = SUM(ISNULL(rota3_events_admin, 0)),
        rota2_events_mr_supp = SUM(ISNULL(rota2_events_mr_supp, 0)),
        rota3_events_mr_supp = SUM(ISNULL(rota3_events_mr_supp, 0)),
        rota2_events_hyb = SUM(ISNULL(rota2_events_hyb, 0)),
        rota3_events_hyb = SUM(ISNULL(rota3_events_hyb, 0)),
        infl_events_admin = SUM(ISNULL(infl_events_admin, 0)),
        infl_events_mr_supp = SUM(ISNULL(infl_events_mr_supp, 0)),
        infl_events_hyb = SUM(ISNULL(infl_events_hyb, 0)),
        combo2_admin = SUM(ISNULL(combo2_admin, 0)),
        combo2_mr = SUM(ISNULL(combo2_mr, 0)),
        combo2_hyb = SUM(ISNULL(combo2_hyb, 0)),
        combo3_admin = SUM(ISNULL(combo3_admin, 0)),
        combo3_mr = SUM(ISNULL(combo3_mr, 0)),
        combo3_hyb = SUM(ISNULL(combo3_hyb, 0)),
        combo4_admin = SUM(ISNULL(combo4_admin, 0)),
        combo4_mr = SUM(ISNULL(combo4_mr, 0)),
        combo4_hyb = SUM(ISNULL(combo4_hyb, 0)),
        combo5_admin = SUM(ISNULL(combo5_admin, 0)),
        combo5_mr = SUM(ISNULL(combo5_mr, 0)),
        combo5_hyb = SUM(ISNULL(combo5_hyb, 0)),
        combo6_admin = SUM(ISNULL(combo6_admin, 0)),
        combo6_mr = SUM(ISNULL(combo6_mr, 0)),
        combo6_hyb = SUM(ISNULL(combo6_hyb, 0)),
        combo7_admin = SUM(ISNULL(combo7_admin, 0)),
        combo7_mr = SUM(ISNULL(combo7_mr, 0)),
        combo7_hyb = SUM(ISNULL(combo7_hyb, 0)),
        combo8_admin = SUM(ISNULL(combo8_admin, 0)),
        combo8_mr = SUM(ISNULL(combo8_mr, 0)),
        combo8_hyb = SUM(ISNULL(combo8_hyb, 0)),
        combo9_admin = SUM(ISNULL(combo9_admin, 0)),
        combo9_mr = SUM(ISNULL(combo9_mr, 0)),
        combo9_hyb = SUM(ISNULL(combo9_hyb, 0)),
        combo10_admin = SUM(ISNULL(combo10_admin, 0)),
        combo10_mr = SUM(ISNULL(combo10_mr, 0)),
        combo10_hyb = SUM(ISNULL(combo10_hyb, 0))
INTO    #SubMetricRuleComponentsTotal
FROM    #SubMetricRuleComponents
WHERE   HEDISSubMetricCode NOT IN ('CISCMB2', 'CISCMB3', 'CISCMB4', 'CISCMB5',
                                   'CISCMB6', 'CISCMB7', 'CISCMB8', 'CISCMB9',
                                   'CISCMB10')


IF @debug = 1 
    SELECT  *
    FROM    #SubMetricRuleComponentsTotal 

UPDATE  #SubMetricRuleComponents
SET     combo2_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) THEN 1
                            ELSE 0
                       END,
        combo2_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) THEN 1
                         ELSE 0
                    END,
        combo2_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB2'



UPDATE  #SubMetricRuleComponents
SET     combo3_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 THEN 1
                            ELSE 0
                       END,
        combo3_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 THEN 1
                         ELSE 0
                    END,
        combo3_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB3'



UPDATE  #SubMetricRuleComponents
SET     combo4_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 (b.hepa_events_admin >= 1 OR
                                  b.hepa_evidence_admin >= 1
                                 ) THEN 1
                            ELSE 0
                       END,
        combo4_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              (b.hepa_events_mr_supp >= 1 OR
                               b.hepa_evidence_mr_supp >= 1
                              ) THEN 1
                         ELSE 0
                    END,
        combo4_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               (b.hepa_events_hyb >= 1 OR
                                b.hepa_evidence_hyb >= 1
                               ) THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB4'



UPDATE  #SubMetricRuleComponents
SET     combo5_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 (b.rota2_events_admin >= 2 OR
                                  b.rota3_events_admin >= 3 OR
                                  (b.rota2_events_admin >= 1 AND
                                   b.rota3_events_admin >= 2
                                  )
                                 ) THEN 1
                            ELSE 0
                       END,
        combo5_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              (b.rota2_events_mr_supp >= 2 OR
                               b.rota3_events_mr_supp >= 3 OR
                               (b.rota2_events_mr_supp >= 1 AND
                                b.rota3_events_mr_supp >= 2
                               )
                              ) THEN 1
                         ELSE 0
                    END,
        combo5_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               (b.rota2_events_hyb >= 2 OR
                                b.rota3_events_hyb >= 3 OR
                                (b.rota2_events_hyb >= 1 AND
                                 b.rota3_events_hyb >= 2
                                )
                               ) THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB5'



UPDATE  #SubMetricRuleComponents
SET     combo6_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 b.infl_events_admin >= 2 THEN 1
                            ELSE 0
                       END,
        combo6_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              b.infl_events_mr_supp >= 2 THEN 1
                         ELSE 0
                    END,
        combo6_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               b.infl_events_hyb >= 2 THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB6'



UPDATE  #SubMetricRuleComponents
SET     combo7_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 (b.hepa_events_admin >= 1 OR
                                  b.hepa_evidence_admin >= 1
                                 ) AND
                                 (b.rota2_events_admin >= 2 OR
                                  b.rota3_events_admin >= 3 OR
                                  (b.rota2_events_admin >= 1 AND
                                   b.rota3_events_admin >= 2
                                  )
                                 ) THEN 1
                            ELSE 0
                       END,
        combo7_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              (b.hepa_events_mr_supp >= 1 OR
                               b.hepa_evidence_mr_supp >= 1
                              ) AND
                              (b.rota2_events_mr_supp >= 2 OR
                               b.rota3_events_mr_supp >= 3 OR
                               (b.rota2_events_mr_supp >= 1 AND
                                b.rota3_events_mr_supp >= 2
                               )
                              ) THEN 1
                         ELSE 0
                    END,
        combo7_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               (b.hepa_events_hyb >= 1 OR
                                b.hepa_evidence_hyb >= 1
                               ) AND
                               (b.rota2_events_hyb >= 2 OR
                                b.rota3_events_hyb >= 3 OR
                                (b.rota2_events_hyb >= 1 AND
                                 b.rota3_events_hyb >= 2
                                )
                               ) THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB7'




UPDATE  #SubMetricRuleComponents
SET     combo8_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 (b.hepa_events_admin >= 1 OR
                                  b.hepa_evidence_admin >= 1
                                 ) AND
                                 b.infl_events_admin >= 2 THEN 1
                            ELSE 0
                       END,
        combo8_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              (b.hepa_events_mr_supp >= 1 OR
                               b.hepa_evidence_mr_supp >= 1
                              ) AND
                              b.infl_events_mr_supp >= 2 THEN 1
                         ELSE 0
                    END,
        combo8_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               (b.hepa_events_hyb >= 1 OR
                                b.hepa_evidence_hyb >= 1
                               ) AND
                               b.infl_events_hyb >= 2 THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB8'




UPDATE  #SubMetricRuleComponents
SET     combo9_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                 b.ipv_events_admin >= 3 AND
                                 (b.mmr_events_admin >= 1 OR
                                  ((b.meas_events_admin >= 1 OR
                                    b.meas_evidence_admin >= 1
                                   ) AND
                                   (b.mumps_events_admin >= 1 OR
                                    b.mumps_evidence_admin >= 1
                                   ) AND
                                   (b.rub_events_admin >= 1 OR
                                    b.rub_evidence_admin >= 1
                                   )
                                  )
                                 ) AND
                                 b.hib_events_admin >= 3 AND
                                 (b.hepb_events_admin >= 3 OR
                                  b.hepb_evidence_admin >= 1
                                 ) AND
                                 (b.vzv_events_admin >= 1 OR
                                  b.vzv_evidence_admin >= 1
                                 ) AND
                                 b.pneu_events_admin >= 4 AND
                                 (b.rota2_events_admin >= 2 OR
                                  b.rota3_events_admin >= 3 OR
                                  (b.rota2_events_admin >= 1 AND
                                   b.rota3_events_admin >= 2
                                  )
                                 ) AND
                                 b.infl_events_admin >= 2 THEN 1
                            ELSE 0
                       END,
        combo9_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                              b.ipv_events_mr_supp >= 3 AND
                              (b.mmr_events_mr_supp >= 1 OR
                               ((b.meas_events_mr_supp >= 1 OR
                                 b.meas_evidence_mr_supp >= 1
                                ) AND
                                (b.mumps_events_mr_supp >= 1 OR
                                 b.mumps_evidence_mr_supp >= 1
                                ) AND
                                (b.rub_events_mr_supp >= 1 OR
                                 b.rub_evidence_mr_supp >= 1
                                )
                               )
                              ) AND
                              b.hib_events_mr_supp >= 3 AND
                              (b.hepb_events_mr_supp >= 3 OR
                               b.hepb_evidence_mr_supp >= 1
                              ) AND
                              (b.vzv_events_mr_supp >= 1 OR
                               b.vzv_evidence_mr_supp >= 1
                              ) AND
                              b.pneu_events_mr_supp >= 4 AND
                              (b.rota2_events_mr_supp >= 2 OR
                               b.rota3_events_mr_supp >= 3 OR
                               (b.rota2_events_mr_supp >= 1 AND
                                b.rota3_events_mr_supp >= 2
                               )
                              ) AND
                              b.infl_events_mr_supp >= 2 THEN 1
                         ELSE 0
                    END,
        combo9_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                               b.ipv_events_hyb >= 3 AND
                               (b.mmr_events_hyb >= 1 OR
                                ((b.meas_events_hyb >= 1 OR
                                  b.meas_evidence_hyb >= 1
                                 ) AND
                                 (b.mumps_events_hyb >= 1 OR
                                  b.mumps_evidence_hyb >= 1
                                 ) AND
                                 (b.rub_events_hyb >= 1 OR
                                  b.rub_evidence_hyb >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_hyb >= 3 AND
                               (b.hepb_events_hyb >= 3 OR
                                b.hepb_evidence_hyb >= 1
                               ) AND
                               (b.vzv_events_hyb >= 1 OR
                                b.vzv_evidence_hyb >= 1
                               ) AND
                               b.pneu_events_hyb >= 4 AND
                               (b.rota2_events_hyb >= 2 OR
                                b.rota3_events_hyb >= 3 OR
                                (b.rota2_events_hyb >= 1 AND
                                 b.rota3_events_hyb >= 2
                                )
                               ) AND
                               b.infl_events_hyb >= 2 THEN 1
                          ELSE 0
                     END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB9'




UPDATE  #SubMetricRuleComponents
SET     combo10_admin = CASE WHEN b.dtap_events_admin >= 4 AND
                                  b.ipv_events_admin >= 3 AND
                                  (b.mmr_events_admin >= 1 OR
                                   ((b.meas_events_admin >= 1 OR
                                     b.meas_evidence_admin >= 1
                                    ) AND
                                    (b.mumps_events_admin >= 1 OR
                                     b.mumps_evidence_admin >= 1
                                    ) AND
                                    (b.rub_events_admin >= 1 OR
                                     b.rub_evidence_admin >= 1
                                    )
                                   )
                                  ) AND
                                  b.hib_events_admin >= 3 AND
                                  (b.hepb_events_admin >= 3 OR
                                   b.hepb_evidence_admin >= 1
                                  ) AND
                                  (b.vzv_events_admin >= 1 OR
                                   b.vzv_evidence_admin >= 1
                                  ) AND
                                  b.pneu_events_admin >= 4 AND
                                  (b.hepa_events_admin >= 1 OR
                                   b.hepa_evidence_admin >= 1
                                  ) AND
                                  (b.rota2_events_admin >= 2 OR
                                   b.rota3_events_admin >= 3 OR
                                   (b.rota2_events_admin >= 1 AND
                                    b.rota3_events_admin >= 2
                                   )
                                  ) AND
                                  b.infl_events_admin >= 2 THEN 1
                             ELSE 0
                        END,
        combo10_mr = CASE WHEN b.dtap_events_mr_supp >= 4 AND
                               b.ipv_events_mr_supp >= 3 AND
                               (b.mmr_events_mr_supp >= 1 OR
                                ((b.meas_events_mr_supp >= 1 OR
                                  b.meas_evidence_mr_supp >= 1
                                 ) AND
                                 (b.mumps_events_mr_supp >= 1 OR
                                  b.mumps_evidence_mr_supp >= 1
                                 ) AND
                                 (b.rub_events_mr_supp >= 1 OR
                                  b.rub_evidence_mr_supp >= 1
                                 )
                                )
                               ) AND
                               b.hib_events_mr_supp >= 3 AND
                               (b.hepb_events_mr_supp >= 3 OR
                                b.hepb_evidence_mr_supp >= 1
                               ) AND
                               (b.vzv_events_mr_supp >= 1 OR
                                b.vzv_evidence_mr_supp >= 1
                               ) AND
                               b.pneu_events_mr_supp >= 4 AND
                               (b.hepa_events_mr_supp >= 1 OR
                                b.hepa_evidence_mr_supp >= 1
                               ) AND
                               (b.rota2_events_mr_supp >= 2 OR
                                b.rota3_events_mr_supp >= 3 OR
                                (b.rota2_events_mr_supp >= 1 AND
                                 b.rota3_events_mr_supp >= 2
                                )
                               ) AND
                               b.infl_events_mr_supp >= 2 THEN 1
                          ELSE 0
                     END,
        combo10_hyb = CASE WHEN b.dtap_events_hyb >= 4 AND
                                b.ipv_events_hyb >= 3 AND
                                (b.mmr_events_hyb >= 1 OR
                                 ((b.meas_events_hyb >= 1 OR
                                   b.meas_evidence_hyb >= 1
                                  ) AND
                                  (b.mumps_events_hyb >= 1 OR
                                   b.mumps_evidence_hyb >= 1
                                  ) AND
                                  (b.rub_events_hyb >= 1 OR
                                   b.rub_evidence_hyb >= 1
                                  )
                                 )
                                ) AND
                                b.hib_events_hyb >= 3 AND
                                (b.hepb_events_hyb >= 3 OR
                                 b.hepb_evidence_hyb >= 1
                                ) AND
                                (b.vzv_events_hyb >= 1 OR
                                 b.vzv_evidence_hyb >= 1
                                ) AND
                                b.pneu_events_hyb >= 4 AND
                                (b.hepa_events_hyb >= 1 OR
                                 b.hepa_evidence_hyb >= 1
                                ) AND
                                (b.rota2_events_hyb >= 2 OR
                                 b.rota3_events_hyb >= 3 OR
                                 (b.rota2_events_hyb >= 1 AND
                                  b.rota3_events_hyb >= 2
                                 )
                                ) AND
                                b.infl_events_hyb >= 2 THEN 1
                           ELSE 0
                      END
FROM    #SubMetricRuleComponents a
        CROSS JOIN #SubMetricRuleComponentsTotal b
WHERE   HEDISSubMetricCode = 'CISCMB10'



UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN dtap_events_mr_supp >= 4 THEN 1
                                     WHEN hepb_events_mr_supp >= 3 THEN 1
                                     WHEN hepb_evidence_mr_supp >= 1 THEN 1
                                     WHEN vzv_events_mr_supp >= 1 THEN 1
                                     WHEN vzv_evidence_mr_supp >= 1 THEN 1
                                     WHEN pneu_events_mr_supp >= 4 THEN 1
                                     WHEN hib_events_mr_supp >= 3 THEN 1
                                     WHEN ipv_events_mr_supp >= 3 THEN 1
                                     WHEN mmr_events_mr_supp >= 1 THEN 1
                                     WHEN (meas_events_mr_supp >= 1 OR
                                           meas_evidence_mr_supp >= 1
                                          ) AND
                                          (mumps_events_mr_supp >= 1 OR
                                           mumps_evidence_mr_supp >= 1
                                          ) AND
                                          (rub_events_mr_supp >= 1 OR
                                           rub_evidence_mr_supp >= 1
                                          ) THEN 1
                                     WHEN (hepa_events_mr_supp >= 1 OR
                                           hepa_evidence_mr_supp >= 1
                                          ) THEN 1
                                     WHEN rota2_events_mr_supp >= 2 THEN 1
                                     WHEN rota3_events_mr_supp >= 3 THEN 1
                                     WHEN (rota2_events_mr_supp >= 1 AND
                                           rota3_events_mr_supp >= 2
                                          ) THEN 1
                                     WHEN infl_events_mr_supp >= 2 THEN 1
                                     WHEN combo2_mr >= 1 THEN 1
                                     WHEN combo3_mr >= 1 THEN 1
                                     WHEN combo4_mr >= 1 THEN 1
                                     WHEN combo5_mr >= 1 THEN 1
                                     WHEN combo6_mr >= 1 THEN 1
                                     WHEN combo7_mr >= 1 THEN 1
                                     WHEN combo8_mr >= 1 THEN 1
                                     WHEN combo9_mr >= 1 THEN 1
                                     WHEN combo10_mr >= 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN dtap_events_hyb >= 4 THEN 1
                              WHEN hepb_events_hyb >= 3 THEN 1
                              WHEN hepb_evidence_hyb >= 1 THEN 1
                              WHEN vzv_events_hyb >= 1 THEN 1
                              WHEN vzv_evidence_hyb >= 1 THEN 1
                              WHEN pneu_events_hyb >= 4 THEN 1
                              WHEN hib_events_hyb >= 3 THEN 1
                              WHEN ipv_events_hyb >= 3 THEN 1
                              WHEN mmr_events_hyb >= 1 THEN 1
                              WHEN (meas_events_hyb >= 1 OR
                                    meas_evidence_hyb >= 1
                                   ) AND
                                   (mumps_events_hyb >= 1 OR
                                    mumps_evidence_hyb >= 1
                                   ) AND
                                   (rub_events_hyb >= 1 OR
                                    rub_evidence_hyb >= 1
                                   ) THEN 1
                              WHEN (hepa_events_hyb >= 1 OR
                                    hepa_evidence_hyb >= 1
                                   ) THEN 1
                              WHEN rota2_events_hyb >= 2 THEN 1
                              WHEN rota3_events_hyb >= 3 THEN 1
                              WHEN (rota2_events_hyb >= 1 AND
                                    rota3_events_hyb >= 2
                                   ) THEN 1
                              WHEN infl_events_hyb >= 2 THEN 1
                              WHEN combo2_hyb >= 1 THEN 1
                              WHEN combo3_hyb >= 1 THEN 1
                              WHEN combo4_hyb >= 1 THEN 1
                              WHEN combo5_hyb >= 1 THEN 1
                              WHEN combo6_hyb >= 1 THEN 1
                              WHEN combo7_hyb >= 1 THEN 1
                              WHEN combo8_hyb >= 1 THEN 1
                              WHEN combo9_hyb >= 1 THEN 1
                              WHEN combo10_hyb >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions;

WITH ExclusionKey AS
(
	SELECT	MX.MeasureID, MX.HEDISSubMetricID, MX.HEDISSubMetricCode, MX.HEDISSubMetricDescription, 
			EvidenceKey, MRV.Description AS EvidenceDescription
	FROM	dbo.MedicalRecordEvidence AS MRV
			INNER JOIN dbo.MedicalRecordEvidenceType AS MRVT
					ON MRV.EvidenceTypeKey = MRVT.EvidenceTypeKey
			INNER JOIN dbo.HEDISSubMetric AS MX
					ON MRV.Description LIKE MX.DisplayName +'%' AND
						MX.HEDISMeasureInit = 'CIS'              
	WHERE	MRVT.EvidenceTypeKey = 1
)
SELECT DISTINCT
		MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordCIS a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
											a2.MedicalRecordEvidenceKey = XK.EvidenceKey AND                                 
											a2.ServiceDate BETWEEN d2.DateOfBirth 
                                                           AND
                                                              DATEADD(yy, 2, d2.DateOfBirth)
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200),	(SELECT TOP 1  
															XK.EvidenceDescription
												   FROM     dbo.MedicalRecordCIS a2
															INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
															INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
															INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
												   WHERE    b2.MemberID = b.MemberID AND 
															a2.MedicalRecordEvidenceKey = XK.EvidenceKey AND
															a2.ServiceDate BETWEEN d2.DateOfBirth 
																		   AND
																			  DATEADD(yy, 2, d2.DateOfBirth)))
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
		INNER JOIN ExclusionKey AS XK
				ON a.HEDISSubMetricID = XK.HEDISSubMetricID
WHERE   HEDISMeasureInit = 'CIS' AND
        MemberID = @MemberID;

--Apply Exclusions and Reapply Admin Hits, if necessary
UPDATE  a
SET     HybridHitCount = ISNULL(CASE WHEN ISNULL(AdministrativeHitCount, 0) > ISNULL(MedicalRecordHitCount,
                                                              0)
                                     THEN AdministrativeHitCount
                                     ELSE HybridHitCount
                                END, 0),
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
		INNER JOIN dbo.HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
        LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   b.MemberID = @MemberID AND
        c.HEDISMeasureInit = 'CIS';

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'CIS', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') is not null
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') is not null
    DROP TABLE #SubMetricRuleComponents

IF OBJECT_ID('tempdb..#SubMetricRuleComponentsTotal') is not null
    DROP TABLE #SubMetricRuleComponentsTotal

GO
