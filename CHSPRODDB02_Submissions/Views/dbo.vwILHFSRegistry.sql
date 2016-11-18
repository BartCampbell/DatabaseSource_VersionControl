SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwILHFSRegistry]
AS

SELECT  r.Provider_Number					AS 'ProviderNumber'
		,r.Provider_Name					AS 'ProviderName'
		,r.Provider_StreetAddress			AS 'ProviderStreetAddress'
		,r.Provider_StreetAddress2			AS 'ProviderStreetAddress2'
		,r.Provider_City					AS 'ProviderCity'
		,r.Provider_State					AS 'ProviderState'
		,r.Provider_ZipCode					AS 'ProviderZipCode'
		,r.Provider_LicenseNum				AS 'ProviderLicenseNumber'
		,r.Provider_Type					AS 'ProviderType'
		,p.ProviderTypeDescription			
		,r.Enrollent_Status					AS 'EnrollmentStatus'
		,e.EnrollmentStatusCodeDescription
		,r.[Maternal-Child_Provider]		AS 'MaternalChildProvider'
		,r.CategoryofService1				AS 'CategoryOfService1'
		,c1.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription1'
		,r.CategoryofService2				AS 'CategoryOfService2'
		,c2.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription2'
		,r.CategoryofService3				AS 'CategoryOfService3'
		,c3.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription3'
		,r.CategoryofService4				AS 'CategoryOfService4'
		,c4.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription4'
		,r.CategoryofService5				AS 'CategoryOfService5'
		,c5.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription5'
		,r.CategoryofService6				AS 'CategoryOfService6'
		,c6.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription6'
		,r.CategoryofService7				AS 'CategoryOfService7'
		,c7.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription7'
		,r.CategoryofService8				AS 'CategoryOfService8'
		,c8.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription8'
		,r.CategoryofService9				AS 'CategoryOfService9'
		,c9.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription9'
		,r.CategoryofService10				AS 'CategoryOfService10'
		,c10.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription10'
		,r.CategoryofService11				AS 'CategoryOfService11'
		,c11.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription11'
		,r.CategoryofService12				AS 'CategoryOfService12'
		,c12.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription12'
		,r.CategoryofService13				AS 'CategoryOfService13'
		,c13.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription13'
		,r.CategoryofService14				AS 'CategoryOfService14'
		,c14.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription14'
		,r.CategoryofService15				AS 'CategoryOfService15'
		,c15.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription15'
		,r.CategoryofService16				AS 'CategoryOfService16'
		,c16.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription16'
		,r.CategoryofService17				AS 'CategoryOfService17'
		,c17.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription17'
		,r.CategoryofService18				AS 'CategoryOfService18'
		,c18.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription18'
		,r.CategoryofService19				AS 'CategoryOfService19'
		,c19.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription19'
		,r.CategoryofService20				AS 'CategoryOfService20'
		,c20.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription20'
		,r.CategoryofService21				AS 'CategoryOfService21'
		,c21.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription21'
		,r.CategoryofService22				AS 'CategoryOfService22'
		,c22.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription22'
		,r.CategoryofService23				AS 'CategoryOfService23'
		,c23.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription23'
		,r.CategoryofService24				AS 'CategoryOfService24'
		,c24.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription24'
		,r.CategoryofService25				AS 'CategoryOfService25'
		,c25.CategoryOfServiceCodeDescription	AS 'CategoryOfServiceDescription25'
		,r.EligBeginForCategoryofService
		,r.EligEndForCategoryofService
		,r.Provider_FaxNumber				AS 'ProviderFaxNumber'
		,r.Provider_MedicarePartANumber		AS 'ProviderMedicarePartANumber'
		,r.Provider_DEA_Num					AS 'ProviderDEANumber'
		,r.UniquePhysicianID				AS 'UniquePhysicianID'
		,r.ProviderAMAorADANum				AS 'ProviderAMAorADANumber'
		,r.EnrollmentBeginDate				
		,r.EnrollmentEndDate
		,r.NPI
		,r.Filler
		,r.[Stuff]
		,r.[MoreStuff]
		,RecID
FROM	chsstaging.dbo.FHN_HFS_RegistryFile_20160707 r
		LEFT JOIN chsstaging.dbo.ILHFSRegistryProviderType p
			ON r.Provider_Type = p.ProviderTypeCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryEnrollmentStatus e
			ON r.Enrollent_Status = e.EnrollmentStatusCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c1
			ON r.CategoryofService1 = c1.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c2
			ON r.CategoryofService2 = c2.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c3
			ON r.CategoryofService3 = c3.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c4
			ON r.CategoryofService4 = c4.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c5
			ON r.CategoryofService5 = c5.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c6
			ON r.CategoryofService6 = c6.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c7
			ON r.CategoryofService7 = c7.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c8
			ON r.CategoryofService8 = c8.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c9
			ON r.CategoryofService9 = c9.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c10
			ON r.CategoryofService10 = c10.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c11
			ON r.CategoryofService11 = c11.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c12
			ON r.CategoryofService12 = c12.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c13
			ON r.CategoryofService13 = c13.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c14
			ON r.CategoryofService14 = c14.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c15
			ON r.CategoryofService15 = c15.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c16
			ON r.CategoryofService16 = c16.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c17
			ON r.CategoryofService17 = c17.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c18
			ON r.CategoryofService18 = c18.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c19
			ON r.CategoryofService19 = c19.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c20
			ON r.CategoryofService20 = c20.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c21
			ON r.CategoryofService21 = c21.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c22
			ON r.CategoryofService22 = c22.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c23
			ON r.CategoryofService23 = c23.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c24
			ON r.CategoryofService24 = c24.CategoryOfServiceCode
		LEFT JOIN chsstaging.dbo.ILHFSRegistryCategoryOfService c25
			ON r.CategoryofService25 = c25.CategoryOfServiceCode
GO
