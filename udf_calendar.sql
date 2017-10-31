
-- =============================================
-- Author: Cal Walsman
-- Create date: 2017-10-30
-- Description:
-- Creates a user defined table value function
-- that outputs a calendar table based on a
-- start and end date.
-- =============================================

CREATE FUNCTION dbo.udf_calendar (@datestart smalldatetime, @dateend smalldatetime)
RETURNS @calendar TABLE (
  [day] int,
  [date] smalldatetime
)
AS

BEGIN

  DECLARE @rows int
  DECLARE @i int = 1

  SET @datestart = '2015-01-01'
  SET @dateend = '2018-12-31'
  SELECT
    @rows = DATEDIFF(DAY, @datestart, @dateend)

  WHILE (@i <= @rows)
  BEGIN

    INSERT INTO @calendar ([day])
      VALUES (@i)

    SET @i = @i + 1

  END

  UPDATE a
  SET [date] = DATEADD(DAY, [day] - 1, @datestart)
  --select *, DATEADD(day,id-1,@datestart)
  FROM @calendar a

  RETURN
END
