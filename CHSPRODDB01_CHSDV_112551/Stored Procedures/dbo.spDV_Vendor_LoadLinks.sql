SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load all Link Tables from the tblVendorStage table.  
-- =============================================
create PROCEDURE [dbo].[spDV_Vendor_LoadLinks]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** Load L_VendorCLIENT
	Insert into L_VendorClient
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.VendorHashKey,
		rw.ClientHashKey,		
	rw.LoadDate , 
	 rw.RecordSource,
	 null
	 from CHSStaging.adv.tblVendorStage rw with(nolock)
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_VendorClient_RK from L_VendorClient where RecordEndDate is null)
			AND rw.CCI = @CCI
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
						))
			),2)),
		rw.VendorHashKey,
		rw.ClientHashKey,
		 rw.LoadDate  ,		
		rw.RecordSource


		--*** INSERT INTO L_VendorCONTACT

		INSERT INTO L_VendorContact
		SELECT
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE([FaxNumber],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			VendorHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE([FaxNumber],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate ,
			RecordSource,
			Null
		From CHSStaging.adv.tblVendorStage rw
		Where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE([FaxNumber],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2))
		 not in(Select L_VendorContact_RK from L_VendorContact where RecordEndDate is null)
		 AND rw.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CVI,''))),':',
			RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE([FaxNumber],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
				))
				),2)),
			VendorHashKey,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE([FaxNumber],''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(Null,'')))
			))
			),2)),
			 rw.LoadDate  ,
			RecordSource

---**** INSERT INTO L_PROVIDERLOCATION
 
		INSERT INTO L_VendorLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CVI,''))),':',					
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
				rw.VendorHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource,
				Null
			FROM CHSStaging.adv.tblVendorStage rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CVI,''))),':',
										RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)) not in (Select L_VendorLocation_RK from L_VendorLocation where RecordEndDate is null)
				AND rw.CCI = @CCI
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CVI,''))),':',					
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
				rw.VendorHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
				 rw.LoadDate ,
				RecordSource

			

END
GO
