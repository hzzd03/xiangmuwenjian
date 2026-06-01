-- =============================================
-- 抄告率统计（2025年）
-- 应抄告和已抄告都按检测时间统计
-- =============================================
WITH 应抄告 AS (
    SELECT COUNT(*) AS 应抄告总数
    FROM ZC_CheckData_Other o WITH (NOLOCK)
    INNER JOIN ZC_CheckData_First f WITH (NOLOCK) ON o.fMainID = f.fID
    INNER JOIN Base_Province p WITH (NOLOCK)
        ON LEFT(f.fboardtrucknew, 1) = p.fName
        AND LEFT(f.fboardtrucknew, 1) <> '冀'
    INNER JOIN Base_Station s WITH (NOLOCK)
        ON o.fStationNO = s.fNO
        AND ISNULL(s.fJJDepartment, '') <> ''
    WHERE o.fState = 3
      AND ISNULL(o.fIsUploadJTB, 0) = 1
      AND f.fTime >= '2025-01-01' AND f.fTime < '2026-01-01'
),
已抄告 AS (
    SELECT COUNT(DISTINCT u.fOtherID) AS 实际已抄告数
    FROM dbo.ZC_CheckData_UpLoadJTBI u WITH (NOLOCK)
    INNER JOIN ZC_CheckData_Other o WITH (NOLOCK) ON u.fOtherID = o.fID
    INNER JOIN ZC_CheckData_First f WITH (NOLOCK) ON o.fMainID = f.fID
    WHERE ((u.fMessage LIKE '%同一案件只可抄告同一类型同一对象一次%' AND u.fState = -1)
        OR u.fState = 1)
      AND f.fTime >= '2025-01-01' AND f.fTime < '2026-01-01'
)
SELECT
    a.应抄告总数,
    b.实际已抄告数,
    CASE
        WHEN a.应抄告总数 > 0
        THEN CAST(b.实际已抄告数 * 100.0 / a.应抄告总数 AS DECIMAL(5,2))
        ELSE 0
    END AS 抄告率_pct,
    a.应抄告总数 - b.实际已抄告数 AS 未抄告数
FROM 应抄告 a, 已抄告 b;
