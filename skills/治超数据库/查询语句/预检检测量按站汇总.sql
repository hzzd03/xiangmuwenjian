-- =============================================
-- 预检/首检检测量 — 按检测站 + 数据来源汇总
-- =============================================
SELECT
    bs.fName AS 检测点名称,
    c.fName AS 城市名称,
    cc.fCountyName AS 区县名称,
    t.数据来源,
    COUNT(*) AS 检测车辆数,
    SUM(CASE WHEN t.是否超限 = '是' THEN 1 ELSE 0 END) AS 超限车辆数
FROM
    dbo.Base_Station bs
INNER JOIN Base_City c ON bs.fCityID = c.fID
INNER JOIN Base_County cc ON cc.fID = bs.fCountyID
INNER JOIN (
    SELECT
        fCheckStation AS 检测站编号,
        '首检（精简）数据' AS 数据来源,
        CASE WHEN fWeightOverLoad > 0 THEN '是' ELSE '否' END AS 是否超限
    FROM vw_ZC_CheckData_FirstAll
    WHERE fTime BETWEEN '2025-09-01 00:00:00' AND '2025-09-30 23:59:59'

    UNION ALL

    SELECT
        fCheckStation AS 检测站编号,
        '预检数据' AS 数据来源,
        CASE WHEN fWeightOverLoad > 0 THEN '是' ELSE '否' END AS 是否超限
    FROM CP.ERoad_ZC_BD.dbo.ZC_CheckData_Preview
    WHERE fTime BETWEEN '2025-09-01 00:00:00' AND '2025-09-30 23:59:59'
) t ON bs.fNO = t.检测站编号
WHERE
    bs.fType = 0
    AND bs.fNoUsed = 0
GROUP BY
    bs.fName,
    c.fName,
    cc.fCountyName,
    t.数据来源
ORDER BY
    检测点名称,
    数据来源;
