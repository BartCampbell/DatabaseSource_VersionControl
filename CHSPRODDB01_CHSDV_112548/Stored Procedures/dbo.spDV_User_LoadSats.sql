SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/21/2016
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
--Update 09/29/2016 Adding 3 fields to User PJ
--Update adding/dropping new columns for Advance updates 02282017 PDJ
--uPDATE 20170421 Adding new columns fro USER PDJ
-- Description:	Data Vault User Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_User_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_UserDEMO LOAD
        INSERT  INTO [dbo].[S_UserDemo]
                ( [S_UserDemo_RK] ,
                  [LoadDate] ,
                  [H_User_RK] ,
                  [Username] ,
                  [sch_Name] ,
                  [FirstName] ,
                  [LastName] ,
                  [ismale] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[sch_Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(is_male AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        RTRIM(LTRIM(rw.[Username])) ,
                        RTRIM(LTRIM(rw.[sch_Name])) ,
                        RTRIM(LTRIM(rw.[Firstname])) ,
                        RTRIM(LTRIM(rw.[Lastname])) ,
                        rw.is_male ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[sch_Name], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(is_male AS VARCHAR), '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[sch_Name], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(is_male AS VARCHAR), '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_UserDemo
                        WHERE   H_User_RK = rw.UserHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[sch_Name], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(is_male AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        RTRIM(LTRIM(rw.[Username])) ,
                        RTRIM(LTRIM(rw.[sch_Name])) ,
                        RTRIM(LTRIM(rw.[Firstname])) ,
                        RTRIM(LTRIM(rw.[Lastname])) ,
                        rw.is_male ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[sch_Name], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(is_male AS VARCHAR), '')))))), 2)) ,
                        RecordSource;




        INSERT  INTO [dbo].[S_UserDemo]
                ( [S_UserDemo_RK] ,
                  [LoadDate] ,
                  [H_User_RK] ,
                  [Username] ,
                  [sch_Name] ,
                  [FirstName] ,
                  [LastName] ,
                  [ismale] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':',
                                                                       '', ':', RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        RTRIM(LTRIM(rw.[Username])) ,
                        '' ,
                        RTRIM(LTRIM(rw.[Firstname])) ,
                        RTRIM(LTRIM(rw.[Lastname])) ,
                        '' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', '', ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', ''))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserRemovedStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', '', ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', ''))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_UserDemo
                        WHERE   H_User_RK = rw.UserHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':',
                                                                        '', ':', RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        RTRIM(LTRIM(rw.[Username])) ,
                        RTRIM(LTRIM(rw.[Firstname])) ,
                        RTRIM(LTRIM(rw.[Lastname])) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Username], ''))), ':', '', ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Firstname], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[Lastname], ''))), ':', ''))), 2)) ,
                        RecordSource;







	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_UserDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_UserDemo z
                                  WHERE     z.H_User_RK = a.H_User_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_UserDemo a
        WHERE   RecordEndDate IS NULL; 
	

    


--**** S_UserDetails LOAD
        INSERT  INTO [dbo].[S_UserDetails]
                ( [S_UserDetails_RK] ,
                  [LoadDate] ,
                  [H_User_RK] ,
                  [Password] ,
                  [IsAdmin] ,
                  [IsScanTech] ,
                  [IsScheduler] ,
                  [IsReviewer] ,
                  [IsQA] ,
                  [IsHRA] ,
                  [IsActive] ,
                  [only_work_selected_hours] ,
                  [only_work_selected_zipcodes] ,
                  [deactivate_after] ,
                  [linked_provider_id] ,
                  [linked_provider_pk] ,
                  [IsClient] ,
                  [IsSchedulerSV] ,
                  [IsScanTechSV] ,
                  [IsChangePasswordOnFirstLogin] ,
                  [Location_PK] ,
                  [isQCC] ,
                  [willing2travell] ,
                  [Latitude] ,
                  [Longitude] ,
                  [linked_scheduler_user_pk] ,
                  [EmploymentStatus] ,
                  [EmploymentAgency] ,
                  [isAllowDownload] ,
                  [CoderLevel] ,
                  [IsSchedulerManager] ,
                  [IsInvoiceAccountant] ,
                  [IsBillingAccountant] ,
                  [IsManagementUser] ,
				  [IsCoderOnsite],
				  IsCoderOffsite,
				  ISQACoder,
				  IsQAManager,
				  IsCodingManager,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsHRA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.linked_provider_id, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_provider_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsClient AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSchedulerSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTechSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsChangePasswordOnFirstLogin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Location_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isQCC AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.willing2travell AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Latitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Longitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_scheduler_user_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentStatus AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentAgency AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isAllowDownload AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[CoderLevel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.[IsSchedulerManager] AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsInvoiceAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsBillingAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsManagementUser], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOnsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOffsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[ISQACoder], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsQAManager], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCodingManager], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        [Password] ,
                        [IsAdmin] ,
                        [IsScanTech] ,
                        [IsScheduler] ,
                        [IsReviewer] ,
                        [IsQA] ,
                        [IsHRA] ,
                        [IsActive] ,
                        [only_work_selected_hours] ,
                        [only_work_selected_zipcodes] ,
                        [deactivate_after] ,
                        RTRIM(LTRIM([linked_provider_id])) ,
                        [linked_provider_pk] ,
                        [IsClient] ,
                        [IsSchedulerSV] ,
                        [IsScanTechSV] ,
                        [IsChangePasswordOnFirstLogin] ,
                        [Location_PK] ,
                        [isQCC] ,
                        [willing2travell] ,
                        [Latitude] ,
                        [Longitude] ,
                        [linked_scheduler_user_pk] ,
                        [EmploymentStatus] ,
                        [EmploymentAgency] ,
                        [isAllowDownload] ,
                        [CoderLevel] ,
                        [IsSchedulerManager] ,
                        [IsInvoiceAccountant] ,
                        [IsBillingAccountant] ,
                        [IsManagementUser] ,
						[IsCoderOnsite],
						IsCoderOffsite,
						ISQACoder,
						IsQAManager,
						IsCodingManager,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsHRA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.linked_provider_id, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_provider_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsClient AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSchedulerSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTechSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsChangePasswordOnFirstLogin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Location_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isQCC AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.willing2travell AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Latitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Longitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_scheduler_user_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentStatus AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentAgency AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isAllowDownload AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[CoderLevel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.[IsSchedulerManager] AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsInvoiceAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsBillingAccountant], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOnsite], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsManagementUser], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOffsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[ISQACoder], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsQAManager], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCodingManager], '')))
																	   ))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserWCStage rw WITH ( NOLOCK )
                WHERE  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsHRA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.linked_provider_id, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_provider_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsClient AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSchedulerSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTechSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsChangePasswordOnFirstLogin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Location_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isQCC AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.willing2travell AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Latitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Longitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_scheduler_user_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentStatus AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentAgency AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isAllowDownload AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[CoderLevel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.[IsSchedulerManager] AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsInvoiceAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsBillingAccountant], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOnsite], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsManagementUser], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOffsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[ISQACoder], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsQAManager], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCodingManager], '')))
																	   ))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_UserDetails
                        WHERE   H_User_RK = rw.UserHashKey
                                AND RecordEndDate IS NULL )
							    AND rw.CCI = @CCI
                GROUP BY  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsHRA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.linked_provider_id, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_provider_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsClient AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSchedulerSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTechSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsChangePasswordOnFirstLogin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Location_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isQCC AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.willing2travell AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Latitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Longitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_scheduler_user_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentStatus AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentAgency AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isAllowDownload AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[CoderLevel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.[IsSchedulerManager] AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsInvoiceAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsBillingAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsManagementUser], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOnsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOffsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[ISQACoder], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsQAManager], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCodingManager], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        [Password] ,
                        [IsAdmin] ,
                        [IsScanTech] ,
                        [IsScheduler] ,
                        [IsReviewer] ,
                        [IsQA] ,
                        [IsHRA] ,
                        [IsActive] ,
                        [only_work_selected_hours] ,
                        [only_work_selected_zipcodes] ,
                        [deactivate_after] ,
                        RTRIM(LTRIM([linked_provider_id])) ,
                        [linked_provider_pk] ,
                        [IsClient] ,
                        [IsSchedulerSV] ,
                        [IsScanTechSV] ,
                        [IsChangePasswordOnFirstLogin] ,
                        [Location_PK] ,
                        [isQCC] ,
                        [willing2travell] ,
                        [Latitude] ,
                        [Longitude] ,
                        [linked_scheduler_user_pk] ,
                        [EmploymentStatus] ,
                        [EmploymentAgency] ,
                        [isAllowDownload] ,
                        [CoderLevel] ,
                        [IsSchedulerManager] ,
                        [IsInvoiceAccountant] ,
                        [IsBillingAccountant] ,
                        [IsManagementUser] ,
						[IsCoderOnsite],
						IsCoderOffsite,
						ISQACoder,
						IsQAManager,
						IsCodingManager,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsHRA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.linked_provider_id, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_provider_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsClient AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSchedulerSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTechSV AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsChangePasswordOnFirstLogin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Location_PK AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isQCC AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.willing2travell AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Latitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Longitude AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.linked_scheduler_user_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentStatus AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.EmploymentAgency AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.isAllowDownload AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[CoderLevel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.[IsSchedulerManager] AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsInvoiceAccountant], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsBillingAccountant], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOnsite], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsManagementUser], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCoderOffsite], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[ISQACoder], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsQAManager], ''))), ':',
																	   RTRIM(LTRIM(COALESCE(rw.[IsCodingManager], '')))
																	   ))), 2)) ,
                        RecordSource;


						

        INSERT  INTO [dbo].[S_UserDetails]
                ( [S_UserDetails_RK] ,
                  [LoadDate] ,
                  [H_User_RK] ,
                  [Password] ,
                  RemovedDate ,
                  [IsSuperUser] ,
                  [IsAdmin] ,
                  [IsScanTech] ,
                  [IsScheduler] ,
                  [IsReviewer] ,
                  [IsQA] ,
                  [IsActive] ,
                  [only_work_selected_hours] ,
                  [only_work_selected_zipcodes] ,
                  [deactivate_after] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Removed_date AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSuperUser AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        [Password] ,
                        Removed_date ,
                        [IsSuperUser] ,
                        [IsAdmin] ,
                        [IsScanTech] ,
                        [IsScheduler] ,
                        [IsReviewer] ,
                        [IsQA] ,
                        [IsActive] ,
                        [only_work_selected_hours] ,
                        [only_work_selected_zipcodes] ,
                        [deactivate_after] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Removed_date AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSuperUser AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserRemovedStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Removed_date AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSuperUser AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_UserDetails
                        WHERE   H_User_RK = rw.UserHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.Removed_date AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsSuperUser AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UserHashKey ,
                        [Password] ,
                        Removed_date ,
                        [IsSuperUser] ,
                        [IsAdmin] ,
                        [IsScanTech] ,
                        [IsScheduler] ,
                        [IsReviewer] ,
                        [IsQA] ,
                        [IsActive] ,
                        [only_work_selected_hours] ,
                        [only_work_selected_zipcodes] ,
                        [deactivate_after] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.Password, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.Removed_date AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsSuperUser AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsAdmin AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScanTech AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsScheduler AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsReviewer AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsQA AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.IsActive AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_hours AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.only_work_selected_zipcodes AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(rw.deactivate_after AS VARCHAR), '')))))), 2)) ,
                        RecordSource;




	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_UserDetails
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_UserDetails z
                                  WHERE     z.H_User_RK = a.H_User_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_UserDetails a
        WHERE   RecordEndDate IS NULL; 



--*** Insert into S_LOCATION

        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  [Zip] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        RTRIM(LTRIM(address)) ,
                        zipcode_pk ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        RTRIM(LTRIM(address)) ,
                        zipcode_pk ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        RecordSource;

--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Location
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Location z
                                  WHERE     z.H_Location_RK = a.H_Location_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Location a
        WHERE   RecordEndDate IS NULL; 

	

	--*** INSERT INTO S_CONTACT
        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RTRIM(LTRIM(ISNULL(Email_Address,''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserRemovedStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RTRIM(LTRIM(ISNULL(Email_Address,''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;



        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  [H_Contact_RK] ,
                  [Phone] ,
                  [Fax] ,
                  [EmailAddress] ,
                  [HashDiff] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RTRIM(LTRIM(ISNULL([sch_Tel],''))) ,
                        RTRIM(LTRIM(ISNULL([sch_Fax],''))) ,
                        RTRIM(LTRIM(ISNULL(Email_Address,''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RTRIM(LTRIM(ISNULL([sch_Tel],''))) ,
                        RTRIM(LTRIM(ISNULL([sch_Fax],''))) ,
                        RTRIM(LTRIM(ISNULL(Email_Address,''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        RecordSource;

		--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Contact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Contact z
                                  WHERE     z.H_Contact_RK = a.H_Contact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Contact a
        WHERE   RecordEndDate IS NULL; 



    END;
    
GO
