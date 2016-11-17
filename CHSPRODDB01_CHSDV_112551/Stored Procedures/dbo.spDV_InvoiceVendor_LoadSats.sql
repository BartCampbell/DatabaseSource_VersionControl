SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Data Vault InvoiceVendor Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_InvoiceVendor_LoadSats]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_InvoiceVendorD LOAD
INSERT INTO [dbo].[S_InvoiceVendorDetail]
           ([S_InvoiceVendorDetail_RK]
           ,[LoadDate]
           ,[H_InvoiceVendor_RK]
           ,[InvoiceVendor]
           ,[LastUpdated]
           ,[HashDiff]
           ,[RecordSource]
   )
   

    SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.InvoiceVendor,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
						))
			),2)),
	 LoadDate, 
	 InvoiceVendorHashKey,
	 RTRIM(LTRIM(rw.InvoiceVendor)),
			rw.[LastUpdated],

	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
		RTRIM(LTRIM(COALESCE(rw.InvoiceVendor,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
			))
			),2)),
	RecordSource
	FROM CHSStaging.adv.tblInvoiceVendorStage rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.InvoiceVendor,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_InvoiceVendorDetail WHERE 
					H_InvoiceVendor_RK = rw.InvoiceVendorHashKey and RecordEndDate is null )
					AND rw.cci = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.InvoiceVendor,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
						))
			),2)),
	 LoadDate, 
	 InvoiceVendorHashKey,
	 RTRIM(LTRIM(rw.InvoiceVendor)),
			rw.[LastUpdated],

	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
		RTRIM(LTRIM(COALESCE(rw.InvoiceVendor,''))),':',
			RTRIM(LTRIM(COALESCE(rw.[LastUpdated],'')))
			))
			),2)),
	RecordSource;

	--RECORD END DATE CLEANUP
		UPDATE dbo.S_InvoiceVendorDetail set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_InvoiceVendorDetail z
			 Where
			  z.H_InvoiceVendor_RK = a.H_InvoiceVendor_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_InvoiceVendorDetail a
			Where a.RecordEndDate Is Null 



END



GO
