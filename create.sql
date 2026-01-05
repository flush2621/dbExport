-- 创建结果表
CREATE TABLE client_check_intervals AS
SELECT
    current_row.client_id,
    current_row.check_date as start_date,
    next_row.check_date as end_date
FROM (
         -- 为每行数据添加行号
         SELECT
             client_id,
             check_date,
             @row_num := IF(@prev_client = client_id, @row_num + 1, 1) as row_num,
             @prev_client := client_id
         FROM (
             -- 获取去重并按时间排序的数据
             SELECT DISTINCT
             client_id,
             DATE(SUBSTR(check_date, 1, 10)) as check_date
             FROM ky_test_data_body_composition
             WHERE SUBSTR(check_date, 1, 10) BETWEEN '2025-01-01' AND '2025-12-31'
             ORDER BY client_id, DATE(SUBSTR(check_date, 1, 10))
             ) sorted,
             (SELECT @prev_client := NULL, @row_num := 0) vars
     ) current_row
         LEFT JOIN (
    -- 同样方法但行号+1
    SELECT
        client_id,
        check_date,
        @row_num2 := IF(@prev_client2 = client_id, @row_num2 + 1, 1) as row_num,
        @prev_client2 := client_id
    FROM (
        SELECT DISTINCT
        client_id,
        DATE(SUBSTR(check_date, 1, 10)) as check_date
        FROM ky_test_data_body_composition
        WHERE SUBSTR(check_date, 1, 10) BETWEEN '2025-01-01' AND '2025-12-31'
        ORDER BY client_id, DATE(SUBSTR(check_date, 1, 10))
        ) sorted2,
        (SELECT @prev_client2 := NULL, @row_num2 := 0) vars2
) next_row ON current_row.client_id = next_row.client_id
    AND current_row.row_num = next_row.row_num - 1
WHERE next_row.check_date IS NOT NULL
ORDER BY current_row.client_id, start_date;