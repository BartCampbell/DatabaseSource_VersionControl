SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetCISMetricComponents]()
RETURNS TABLE 
AS
RETURN 
(
	WITH Components (HEDISSubMetricComponentCode, HEDISSubMetricComponentDesc, HEDISSubMetricCode, QuantityNeeded, StartDays, StartMonths, EndDays, EndMonths) AS 
	(
	SELECT  'DTP', 'DTaP', 'CISDTP', 4, 42, 0, 0, 24
	UNION ALL
	SELECT  'DIPTH', 'Diphtheria', 'CISDTP', NULL, 42, 0, 0, 24
	UNION ALL
	SELECT  'TET', 'Tetanus', 'CISDTP', NULL, 42, 0, 0, 24
	UNION ALL
	SELECT  'AP', 'Acellular Pertussis', 'CISDTP', NULL, 42, 0, 0, 24
	UNION ALL
	SELECT  'HEPB', 'Hepatitis B', 'CISHEPB', 3, 0, 0, 0, 24
	UNION ALL
	SELECT  'HEPB_Evidence', 'Hepatitis B Evidence', 'CISHEPB', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'VZV', 'VZV', 'CISVZV', 1, 0, 0, 0, 24
	UNION ALL
	SELECT  'VZV_Evidence', 'VZV Evidence', 'CISVZV', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'PNEU', 'PNEU', 'CISPNEU', 4, 42, 0, 0, 24
	UNION ALL
	SELECT  'IPV', 'IPV', 'CISOPV', 3, 42, 0, 0, 24
	UNION ALL
	SELECT  'HIB', 'HIB', 'CISHIB', 3, 42, 0, 0, 24
	UNION ALL
	SELECT  'MMR', 'MMR', 'CISMMR', 1, 0, 0, 0, 24
	UNION ALL
	SELECT  'MEAS', 'Measles', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'MEAS_Evidence', 'Measles Evidence', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'MUMPS', 'Mumps', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'MUMPS_Evidence', 'Mumps Evidence', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'RUB', 'Rubella', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'RUB_Evidence', 'Rubella Evidence', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'MMR_Evidence', 'MMR Evidence', 'CISMMR', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'HEPA', 'Hepatitis A', 'CISHEPA', 1, 0, 0, 0, 24
	UNION ALL
	SELECT  'HEPA_Evidence', 'Hepatitis A Evidence', 'CISHEPA', NULL, 0, 0, 0, 24
	UNION ALL
	SELECT  'ROTA2', 'Rotavirus, 2-Dose', 'CISROTA', 2, 42, 0, 0, 24
	UNION ALL
	SELECT  'ROTA3', 'Rotavirus, 3-Dose', 'CISROTA', 3, 42, 0, 0, 24
	UNION ALL
	SELECT  'INFL', 'Influenza', 'CISINFL', 2, 180, 0, 0, 24
	)
	SELECT * FROM Components
)
GO
