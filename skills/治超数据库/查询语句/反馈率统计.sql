-- =============================================
-- 外省抄告反馈率统计
-- 应反馈：InterprovincialCopy 中的数据（外省抄告过来的）
-- 已反馈：InterprovincialCopy 中已在 UpLoadJTBIFeedback 有记录的
--         fState=1 或 fState=-1(已确认接收) 都算成功
-- =============================================
SELECT
    COUNT(*) AS 应反馈总数,
    SUM(CASE WHEN fb.fID IS NOT NULL
                  AND (fb.fState = 1 OR (fb.fState = -1 AND fb.fMessage LIKE '%已确认接收%'))
             THEN 1 ELSE 0 END) AS 反馈成功数,
    -- 已反馈总数（有反馈记录的条数，目前跟应反馈总数一致，暂不展示）
    CASE WHEN COUNT(*) > 0
         THEN CAST(
              SUM(CASE WHEN fb.fID IS NOT NULL
                            AND (fb.fState = 1 OR (fb.fState = -1 AND fb.fMessage LIKE '%已确认接收%'))
                       THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
              AS DECIMAL(5, 2))
         ELSE 0
    END AS 反馈成功率_pct,
    COUNT(*) - SUM(CASE WHEN fb.fID IS NOT NULL
                             AND (fb.fState = 1 OR (fb.fState = -1 AND fb.fMessage LIKE '%已确认接收%'))
                        THEN 1 ELSE 0 END) AS 待反馈数
FROM dbo.ZC_CheckData_InterprovincialCopy ic WITH (NOLOCK)
LEFT JOIN dbo.ZC_CheckData_UpLoadJTBIFeedback fb WITH (NOLOCK)
    ON ic.fID = fb.fCaseID
WHERE ic.fTime >= '2025-01-01';
