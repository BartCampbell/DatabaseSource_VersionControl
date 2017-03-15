SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCN1]
AS
select *
from [dbo].[CN1] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CN1] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
