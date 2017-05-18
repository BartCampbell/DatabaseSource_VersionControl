SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_W9_remove 26
CREATE PROCEDURE [dbo].[imv_W9_remove] 
	@office bigint,
	@user int
AS
BEGIN
	UPDATE EQ SET AssignedUser_PK=@user,AssignedDate=GetDate() FROM tblExtractionQueueAttachLog EQAL WITH (NOLOCK) 
		INNER JOIN tblExtractionQueue EQ ON EQ.ExtractionQueue_PK=EQAL.ExtractionQueue_PK 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = EQAL.Suspect_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
	WHERE P.ProviderOffice_PK=@office AND EQAL.IsW9=1

	DELETE EQAL FROM tblExtractionQueueAttachLog EQAL 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = EQAL.Suspect_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
	WHERE P.ProviderOffice_PK=@office AND EQAL.IsW9=1

	DELETE FROM tblScannedDataW9 WHERE ProviderOffice_PK=@office
END
GO
