SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull provider for auto complete
-- =============================================
--	dc_searchProvider 'aa'
CREATE PROCEDURE [dbo].[dc_searchProvider] 
	@Provider varchar(100)
AS
BEGIN
	SELECT TOP 10 Lastname+IsNull(', '+Firstname,'')+' ('+Provider_ID+')' Provider, Provider_PK
		FROM tblProvider P WITH (NOLOCK)	
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
	WHERE Lastname+IsNull(', '+Firstname,'')+' ('+Provider_ID+')' Like '%'+@Provider+'%'
	ORDER BY Provider
END



GO
