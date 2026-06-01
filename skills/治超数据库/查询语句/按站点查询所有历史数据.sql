-- =============================================
-- 按站点编号查询所有历史检测数据（不分时间范围）
-- 修改 @stationNO 的值来查询不同站点
-- =============================================
DECLARE @stationNO VARCHAR(50) = '13082301'  -- ← 改成你要查的站点编号

SELECT
    bs.fName AS 检测点名称,
    c.fName AS 城市名称,
    cc.fCountyName AS 区县名称,
    t.车牌号,
    t.车轴数,
    t.车货总重_kg,
    t.车货限重_kg,
    t.超限重量_kg,
    t.超限率,
    t.是否超限,
    t.检测时间,
    t.数据来源
FROM
    dbo.Base_Station bs
INNER JOIN Base_City c ON bs.fCityID = c.fID
INNER JOIN Base_County cc ON cc.fID = bs.fCountyID
INNER JOIN (
    SELECT
        fCheckStation AS 检测站编号,
        fboardtrucknew AS 车牌号,
        fVehicleAxleNew AS 车轴数,
        fWeightCheck AS 车货总重_kg,
        fWeightTruck AS 车货限重_kg,
        fWeightOverLoad AS 超限重量_kg,
        fWeightOverLoadRate AS 超限率,
        CASE WHEN fWeightOverLoad > 0 THEN '是' ELSE '否' END AS 是否超限,
        CONVERT(varchar(50), fTime, 121) AS 检测时间,
        '首检（精简）数据' AS 数据来源
    FROM vw_ZC_CheckData_FirstAll
    WHERE fCheckStation = @stationNO

    UNION ALL

    SELECT
        fCheckStation AS 检测站编号,
        fBoardTruck AS 车牌号,
        fVehicleAxle AS 车轴数,
        fWeightCheck AS 车货总重_kg,
        fWeightTruck AS 车货限重_kg,
        fWeightOverLoad AS 超限重量_kg,
        fWeightOverLoadRate AS 超限率,
        CASE WHEN fWeightOverLoad > 0 THEN '是' ELSE '否' END AS 是否超限,
        CONVERT(varchar(50), fTime, 121) AS 检测时间,
        '预检数据' AS 数据来源
    FROM CP.ERoad_ZC_BD.dbo.ZC_CheckData_Preview
    WHERE fCheckStation = @stationNO
) t ON bs.fNO = t.检测站编号
WHERE
    bs.fType = 0
    AND bs.fNoUsed = 0
ORDER BY
    t.检测时间 DESC;
