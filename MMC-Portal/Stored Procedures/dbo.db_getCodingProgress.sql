SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Modify By: Amjad Ali on 26-feb-2015
-- db_getCodingProgress 0,0,0
CREATE PROCEDURE [dbo].[db_getCodingProgress] 
	@User  INT,
	@h_id  INT,
	@isClient INT
AS
BEGIN
--	SELECT * FROM (
	if (0=@isClient)
	BEGIN
		SELECT TOP 2 COUNT(*) Encounters,MONTH(inserted_date) EncMonth,Year(inserted_date) EncYear
		FROM tblEncounter WITH (NOLOCK)
		WHERE h_id=@h_id And (@User=0 OR tblEncounter.inserted_user_pk=@User)
		GROUP BY MONTH(inserted_date),Year(inserted_date)
		ORDER BY EncYear DESC,EncMonth DESC
	END
	ELSE
	BEGIN
	SELECT TOP 1 COUNT(*) Encounters,MONTH(inserted_date) EncMonth,Year(inserted_date) EncYear
		FROM tblEncounter WITH (NOLOCK)
		WHERE h_id=@h_id And (@User=0 OR tblEncounter.inserted_user_pk=@User)
		GROUP BY MONTH(inserted_date),Year(inserted_date)
		ORDER BY EncYear DESC,EncMonth DESC
	END
--	) T ORDER BY EncYear,EncMonth
END

GO
