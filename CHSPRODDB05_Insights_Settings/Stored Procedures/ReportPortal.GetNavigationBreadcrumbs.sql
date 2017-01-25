SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/15/2015
-- Description:	Retrieves the URL segments in order form left-to-right for the breadcrumb in Report Portal screen for the Reports module.
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetNavigationBreadcrumbs]
(
	@RptCustGuid uniqueidentifier = NULL,
	@RptCustID smallint = NULL,
	@RptNavID int = NULL,
	@RptObjGuid uniqueidentifier = NULL,
	@RptObjID smallint = NULL,
	@UrlSeg varchar(512) = NULL,
	@UserName varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @CustUrlSeg varchar(512);
	DECLARE @RptObjTypeID tinyint;

	--Attempt to identify the Object by its Navigation ID, if the ID is unknown
	IF @RptObjID IS NULL AND
		@RptNavID IS NOT NULL
	SELECT	@RptObjID = RN.ChildID
	FROM	ReportPortal.Navigation AS RN WITH(NOLOCK)
	WHERE	(RN.RptNavID = @RptNavID);

	--Attempt to identify the Object by its GUID, if the ID is unknown
	IF @RptObjID IS NULL AND 
		@RptObjGuid IS NOT NULL
	SELECT	@RptObjID = RptObjID
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.RptObjGuid = @RptObjGuid);

	--Attempt to identify the Customer by its GUID, if the ID is unknown
	IF @RptCustID IS NULL AND
		@RptCustGuid IS NOT NULL
	SELECT	@RptCustID = RC.RptCustID
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
	WHERE	(RC.RptCustGuid = @RptCustGuid);

	--Attempt to identify the Customer and Object by the potentially supplied combined URL segment.
	IF @RptCustID IS NULL OR
		@RptObjID IS NULL
	SELECT	@RptCustID = ISNULL(@RptCustID, RCOUS.RptCustID),
			@RptObjID = ISNULL(@RptObjID, RCOUS.RptObjID)
	FROM	ReportPortal.CustomerObjectUrlSegments AS RCOUS WITH(NOLOCK)
	WHERE	(RCOUS.UrlSeg = @UrlSeg);

	--Attempt to identify the Object by its URL segment, if still unknown
	IF @RptObjID IS NULL AND 
		@UrlSeg IS NOT NULL
	SELECT	@RptObjID = RptObjID
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.UrlSeg = @UrlSeg);

	--Attempt to identify the Customer by its URL segment, if still unknown
	IF @RptCustID IS NULL AND 
		@UrlSeg IS NOT NULL
	SELECT	@RptCustID = RC.RptCustID,
			@CustUrlSeg = RC.UrlSeg
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
	WHERE	(RC.UrlSeg = @UrlSeg);

	--Determine Customer's URL segment, if still unknown...
	IF @CustUrlSeg IS NULL
		SELECT	@CustUrlSeg = UrlSeg 
		FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
		WHERE	(RptCustID = @RptCustID);

	--Determine Object's Type...
	SELECT	@RptObjTypeID = RptObjTypeID 
	FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
	WHERE	(RO.RptObjID = @RptObjID);

	WITH Results AS
	(
		SELECT	CONVERT(smallint, NULL) AS ChildID,
				RO.RptObjID,
				CONVERT(int, 0) AS Tier
		FROM	ReportPortal.[Objects] AS RO WITH(NOLOCK)
				LEFT OUTER JOIN ReportPortal.Navigation AS RN WITH(NOLOCK)
						ON RN.ChildID = RO.RptObjID
		WHERE	(RO.RptObjID = @RptObjID) AND
				((@RptNavID IS NULL) OR (RN.RptNavID IS NULL) OR (RN.RptNavID = @RptNavID))
		UNION ALL
		SELECT	RN.ChildID,
				RN.RptObjID,
                t.Tier + 1 AS Tier
		FROM	Results t --Recursive CTE
				INNER JOIN ReportPortal.Navigation AS RN WITH(NOLOCK)
						ON RN.ChildID = t.RptObjID

	)
	SELECT	RO.DisplayName,
			RO.ObjectName,
			RCOUS.RptCustGuid,
            RCOUS.RptCustID,
            RCOUS.RptObjGuid,
            RCOUS.RptObjID,
            RCOUS.RptObjTypeID,
			ROW_NUMBER() OVER (ORDER BY t.Tier DESC) AS SortOrder,
            RCOUS.UrlSeg
	FROM	Results AS t
			INNER JOIN ReportPortal.CustomerObjectUrlSegments AS RCOUS WITH(NOLOCK)
					ON RCOUS.RptObjID = t.RptObjID
			INNER JOIN ReportPortal.[Objects] AS RO WITH(NOLOCK)
					ON RO.RptObjID = t.RptObjID 
	WHERE	RCOUS.RptCustID = @RptCustID
	UNION 
	SELECT	RC.Name,
			RC.Name,
			RC.RptCustGuid,
			RC.RptCustID,
			CONVERT(uniqueidentifier, CONVERT(binary(16), 0)),
			0,
			0,
			0,
			RC.UrlSeg
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK)
	WHERE	RC.RptCustID = @RptCustID
	ORDER BY SortOrder;
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetNavigationBreadcrumbs] TO [PortalApp]
GO
