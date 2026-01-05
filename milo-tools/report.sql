SELECT
    -- t1
    t1.client_id,
    t1.start_date,
    t1.end_date,
    t1.姓名,
    t1.电话,
    t1.身份证,
    t1.性别,
    t1.所属机构,
    t1.疾病类型,
    t1.年龄,
    t1.身高,
    t1.两次测试时间差,
    t1.运动次数,
    t1.手环能耗,
    t1.设备能耗,
    t1.居家能耗,

    -- f1
    f1.体重, f1.得分, f1.标准体重, f1.标准肌肉量, f1.脂肪控制, f1.肌肉控制,
    f1.身体总水分, f1.蛋白质, f1.无机盐, f1.骨骼肌肉量, f1.去脂体重,
    f1.体脂肪量, f1.身体质量指数, f1.体脂率, f1.内脏脂肪面积, f1.腰臀比,
    f1.左上肢肌肉量, f1.左下肢肌肉量, f1.躯干肌肉量,
    f1.右上肢肌肉量, f1.右下肢肌肉量, f1.基础代谢, f1.体型,

    -- f2
    f2.推胸_测试时间, f2.推胸_设备类型, f2.推胸_档位, f2.推胸_重量,
    f2.推胸_完成次数, f2.推胸_1RM, f2.推胸_得分,
    f2.腹背_测试时间, f2.腹背_设备类型, f2.腹背_档位, f2.腹背_重量,
    f2.腹背_完成次数, f2.腹背_1RM, f2.腹背_得分,
    f2.踢勾_测试时间, f2.踢勾_设备类型, f2.踢勾_档位, f2.踢勾_重量,
    f2.踢勾_完成次数, f2.踢勾_1RM, f2.踢勾_得分,

    -- f3
    f3.检测日期, f3.得分, f3.功率, f3.静息心率, f3.运动最大心率,
    f3.安全心率, f3.最大摄氧量, f3.测试方法,
    f3.平均心率1, f3.平均心率2, f3.平均心率3, f3.平均心率4,
    f3.平均心率5, f3.平均心率6, f3.平均心率7, f3.平均心率8,
    f3.一级负荷, f3.二级负荷, f3.三级负荷, f3.四级负荷,
    f3.五级负荷, f3.六级负荷, f3.七级负荷, f3.八级负荷, f3.异常状态,

    -- s1
    s1.体重, s1.得分, s1.标准体重, s1.标准肌肉量, s1.脂肪控制, s1.肌肉控制,
    s1.身体总水分, s1.蛋白质, s1.无机盐, s1.骨骼肌肉量, s1.去脂体重,
    s1.体脂肪量, s1.身体质量指数, s1.体脂率, s1.内脏脂肪面积, s1.腰臀比,
    s1.左上肢肌肉量, s1.左下肢肌肉量, s1.躯干肌肉量,
    s1.右上肢肌肉量, s1.右下肢肌肉量, s1.基础代谢, s1.体型,

    -- s2
    s2.推胸_测试时间, s2.推胸_设备类型, s2.推胸_档位, s2.推胸_重量,
    s2.推胸_完成次数, s2.推胸_1RM, s2.推胸_得分,
    s2.腹背_测试时间, s2.腹背_设备类型, s2.腹背_档位, s2.腹背_重量,
    s2.腹背_完成次数, s2.腹背_1RM, s2.腹背_得分,
    s2.踢勾_测试时间, s2.踢勾_设备类型, s2.踢勾_档位, s2.踢勾_重量,
    s2.踢勾_完成次数, s2.踢勾_1RM, s2.踢勾_得分,

    -- s3
    s3.检测日期, s3.得分, s3.功率, s3.静息心率, s3.运动最大心率,
    s3.安全心率, s3.最大摄氧量, s3.测试方法,
    s3.平均心率1, s3.平均心率2, s3.平均心率3, s3.平均心率4,
    s3.平均心率5, s3.平均心率6, s3.平均心率7, s3.平均心率8,
    s3.一级负荷, s3.二级负荷, s3.三级负荷, s3.四级负荷,
    s3.五级负荷, s3.六级负荷, s3.七级负荷, s3.八级负荷, s3.异常状态

from
    (
        select t2.client_id,t2.start_date, t2.end_date, t1.name_ 姓名, t1.phone 电话, t1.identify_no 身份证,
               case when(t1.sex=1) then '男' when(t1.sex=2) then '女' else '其他' end 性别, t3.name_ 所属机构,
               t5.past_history 疾病类型, TIMESTAMPDIFF(YEAR, t1.birthday, CURDATE()) 年龄, height 身高,
               DATEDIFF(t2.end_date,t2.start_date) 两次测试时间差,
               (select sum(train_count) from ky_date_data_center t6 where t1.id=t6.client_id and t6.date_ between t2.start_date and t2.end_date) 运动次数,
               (select sum(t7.calorie) from ky_train_data_ble_bracelet t7 where t1.id=t7.client_id and substr(t7.check_time,1,10) between t2.start_date and t2.end_date) 手环能耗,
               ifnull((select sum(t8.calorie) from v_train_data_personal_muscular t8 where t1.id=t8.client_id and substr(t8.train_time,1,10) between t2.start_date and t2.end_date),0) +
               ifnull((select sum(t9.calorie) from v_train_data_personal_oxygen t9 where t1.id=t9.client_id and substr(t9.train_time,1,10) between t2.start_date and t2.end_date),0) 设备能耗,
               (select sum(t10.cal) from ky_sport_time_grand t10 where t1.id=t10.client_id and substr(t10.end_time,1,10) between t2.start_date and t2.end_date) 居家能耗
        from ky_client t1
                 LEFT JOIN (  -- 既往史保持左连接
            SELECT
                client_id,
                GROUP_CONCAT(name_) AS past_history
            FROM ky_client_past_history
            GROUP BY client_id
        ) t5 ON t1.id = t5.client_id, client_check_intervals t2, sys_department t3
        where t1.id=t2.client_id and t1.dept_id=t3.id
    ) t1,
# 第一次体成分
    (
        select t2.client_id, substr(t2.mxdate,1,10) start_date, t1.check_date, wei 体重,  score 得分,
               stdwei 标准体重, null 标准肌肉量, ctrfat 脂肪控制, ctrmus 肌肉控制, tbw 身体总水分, pro 蛋白质, min 无机盐,
               smm 骨骼肌肉量, ffm 去脂体重, fat 体脂肪量, t1.bmi 身体质量指数, pbf 体脂率, vfa 内脏脂肪面积, whr 腰臀比,
               larmm 左上肢肌肉量, llegm 左下肢肌肉量, trm 躯干肌肉量, rarmm 右上肢肌肉量, rlegm 右下肢肌肉量, bmr 基础代谢,
               case when(t1.shape=1) then '低脂低体重' when(t1.shape=2) then '低脂肌肉型' when(t1.shape=3) then '运动员型'
                    when(t1.shape=4) then '低体重' when(t1.shape=5) then '标准体型' when(t1.shape=6) then '超重肌肉型'
                    when(t1.shape=7) then '隐形肥胖' when(t1.shape=8) then '脂肪过量' when(t1.shape=9) then '肥胖' else 'etc' end 体型
        from ky_test_data_body_composition t1,
             (select t2.client_id, max(check_date) mxdate from ky_test_data_body_composition t1, client_check_intervals t2
              where t1.client_id=t2.client_id and substr(t1.check_date,1,10)=t2.start_date
              group by t2.client_id, t2.start_date) t2
        where t1.client_id=t2.client_id and t1.check_date=t2.mxdate
    ) f1,

# 第一次力量测试
    (
        SELECT
            ci.client_id,
            ci.start_date,

            /* ================= 推胸划船（device_type_id = 5） ================= */
            tx.check_date AS `推胸_测试时间`,
            CASE WHEN tx.check_date IS NULL THEN NULL ELSE '推胸划船' END AS `推胸_设备类型`,
            tx.gear  AS `推胸_档位`,
            tx.power AS `推胸_重量`,
            tx.num   AS `推胸_完成次数`,
            CASE
                WHEN tx.power IS NULL OR tx.num IS NULL THEN NULL
                WHEN tx.power = 0 OR tx.num = 0 THEN 0
                WHEN tx.num < 10 THEN tx.power / (1.0278 - 0.0278 * tx.num)
                ELSE tx.power / (30 / (30 + tx.num))
                END AS `推胸_1RM`,
            tx.score AS `推胸_得分`,

            /* ================= 腹肌背肌（device_type_id = 6） ================= */
            fb.check_date AS `腹背_测试时间`,
            CASE WHEN fb.check_date IS NULL THEN NULL ELSE '腹肌背肌' END AS `腹背_设备类型`,
            fb.gear  AS `腹背_档位`,
            fb.power AS `腹背_重量`,
            fb.num   AS `腹背_完成次数`,
            CASE
                WHEN fb.power IS NULL OR fb.num IS NULL THEN NULL
                WHEN fb.power = 0 OR fb.num = 0 THEN 0
                WHEN fb.num < 10 THEN fb.power / (1.0278 - 0.0278 * fb.num)
                ELSE fb.power / (30 / (30 + fb.num))
                END AS `腹背_1RM`,
            fb.score AS `腹背_得分`,

            /* ================= 踢腿勾腿（device_type_id = 8） ================= */
            tg.check_date AS `踢勾_测试时间`,
            CASE WHEN tg.check_date IS NULL THEN NULL ELSE '踢腿勾腿' END AS `踢勾_设备类型`,
            tg.gear  AS `踢勾_档位`,
            tg.power AS `踢勾_重量`,
            tg.num   AS `踢勾_完成次数`,
            CASE
                WHEN tg.power IS NULL OR tg.num IS NULL THEN NULL
                WHEN tg.power = 0 OR tg.num = 0 THEN 0
                WHEN tg.num < 10 THEN tg.power / (1.0278 - 0.0278 * tg.num)
                ELSE tg.power / (30 / (30 + tg.num))
                END AS `踢勾_1RM`,
            tg.score AS `踢勾_得分`

        FROM client_check_intervals ci

/* ================= 推胸：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength tx
                           ON tx.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 5
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.start_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

/* ================= 腹背：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength fb
                           ON fb.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 6
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.start_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

/* ================= 踢勾：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength tg
                           ON tg.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 8
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.start_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

        ORDER BY ci.client_id, ci.start_date
    ) f2,

# 第一次心肺测试
    (
        select
            t1.client_id, t1.start_date,
            t2.check_date 检测日期,
            t2.score 得分,
            t2.power 功率,
            t2.static_heart_rate 静息心率,
            t2.exercise_heart_rate 运动最大心率,
            t2.safe_heart_rate 安全心率,
            t2.vo2max 最大摄氧量,
            case
                when(t2.test_method=0) then '2级递增负荷台阶'
                when(t2.test_method=1) then '国民体质台阶'
                when(t2.test_method=2) then '8级递增负荷功率车'
                when(t2.test_method=3) then 'YMCA功率车'
                when(t2.test_method=6) then '6分钟步行'
                when(t2.test_method=7) then '6分钟踏步'
                else null end 测试方法,
            t2.avg_heart1 "平均心率1", t2.avg_heart2 "平均心率2", t2.avg_heart3 "平均心率3", t2.avg_heart4 "平均心率4",
            t2.avg_heart5 "平均心率5", t2.avg_heart6 "平均心率6", t2.avg_heart7 "平均心率7", t2.avg_heart8 "平均心率8",
            t2.power1 一级负荷, t2.power2 二级负荷, t2.power3 三级负荷, t2.power4 四级负荷,
            t2.power5 五级负荷, t2.power6 六级负荷, t2.power7 七级负荷, t2.power8 八级负荷,
            case
                when(t2.project_status=0) then '异常'
                when(t2.project_status=1) then '正常'
                else null
                end 异常状态
        from client_check_intervals t1
                 left join ky_test_data_cardiopulmonary t2
                           on t1.client_id = t2.client_id
                               and substr(t2.check_date, 1, 10) = t1.start_date
                               and t2.check_date = (
                                   select max(check_date)
                                   from ky_test_data_cardiopulmonary t3
                                   where t3.client_id = t1.client_id
                                     and substr(t3.check_date, 1, 10) = t1.start_date
                               )
        order by t1.client_id, t1.start_date
    ) f3,

# 第二次体成分
    (
        select t2.client_id, substr(t2.mxdate,1,10) end_date, t1.check_date, wei 体重,  score 得分,
               stdwei 标准体重, null 标准肌肉量, ctrfat 脂肪控制, ctrmus 肌肉控制, tbw 身体总水分, pro 蛋白质, min 无机盐,
               smm 骨骼肌肉量, ffm 去脂体重, fat 体脂肪量, t1.bmi 身体质量指数, pbf 体脂率, vfa 内脏脂肪面积, whr 腰臀比,
               larmm 左上肢肌肉量, llegm 左下肢肌肉量, trm 躯干肌肉量, rarmm 右上肢肌肉量, rlegm 右下肢肌肉量, bmr 基础代谢,
               case when(t1.shape=1) then '低脂低体重' when(t1.shape=2) then '低脂肌肉型' when(t1.shape=3) then '运动员型'
                    when(t1.shape=4) then '低体重' when(t1.shape=5) then '标准体型' when(t1.shape=6) then '超重肌肉型'
                    when(t1.shape=7) then '隐形肥胖' when(t1.shape=8) then '脂肪过量' when(t1.shape=9) then '肥胖' else 'etc' end 体型
        from ky_test_data_body_composition t1,
             (select t2.client_id, max(check_date) mxdate from ky_test_data_body_composition t1, client_check_intervals t2
              where t1.client_id=t2.client_id and substr(t1.check_date,1,10)=t2.end_date
              group by t2.client_id, t2.end_date) t2
        where t1.client_id=t2.client_id and t1.check_date=t2.mxdate
    ) s1,

# 第二次力量测试
    (
        SELECT
            ci.client_id,
            ci.end_date,

            /* ================= 推胸划船（device_type_id = 5） ================= */
            tx.check_date AS `推胸_测试时间`,
            CASE WHEN tx.check_date IS NULL THEN NULL ELSE '推胸划船' END AS `推胸_设备类型`,
            tx.gear  AS `推胸_档位`,
            tx.power AS `推胸_重量`,
            tx.num   AS `推胸_完成次数`,
            CASE
                WHEN tx.power IS NULL OR tx.num IS NULL THEN NULL
                WHEN tx.power = 0 OR tx.num = 0 THEN 0
                WHEN tx.num < 10 THEN tx.power / (1.0278 - 0.0278 * tx.num)
                ELSE tx.power / (30 / (30 + tx.num))
                END AS `推胸_1RM`,
            tx.score AS `推胸_得分`,

            /* ================= 腹肌背肌（device_type_id = 6） ================= */
            fb.check_date AS `腹背_测试时间`,
            CASE WHEN fb.check_date IS NULL THEN NULL ELSE '腹肌背肌' END AS `腹背_设备类型`,
            fb.gear  AS `腹背_档位`,
            fb.power AS `腹背_重量`,
            fb.num   AS `腹背_完成次数`,
            CASE
                WHEN fb.power IS NULL OR fb.num IS NULL THEN NULL
                WHEN fb.power = 0 OR fb.num = 0 THEN 0
                WHEN fb.num < 10 THEN fb.power / (1.0278 - 0.0278 * fb.num)
                ELSE fb.power / (30 / (30 + fb.num))
                END AS `腹背_1RM`,
            fb.score AS `腹背_得分`,

            /* ================= 踢腿勾腿（device_type_id = 8） ================= */
            tg.check_date AS `踢勾_测试时间`,
            CASE WHEN tg.check_date IS NULL THEN NULL ELSE '踢腿勾腿' END AS `踢勾_设备类型`,
            tg.gear  AS `踢勾_档位`,
            tg.power AS `踢勾_重量`,
            tg.num   AS `踢勾_完成次数`,
            CASE
                WHEN tg.power IS NULL OR tg.num IS NULL THEN NULL
                WHEN tg.power = 0 OR tg.num = 0 THEN 0
                WHEN tg.num < 10 THEN tg.power / (1.0278 - 0.0278 * tg.num)
                ELSE tg.power / (30 / (30 + tg.num))
                END AS `踢勾_1RM`,
            tg.score AS `踢勾_得分`

        FROM client_check_intervals ci

/* ================= 推胸：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength tx
                           ON tx.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 5
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.end_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

/* ================= 腹背：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength fb
                           ON fb.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 6
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.end_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

/* ================= 踢勾：当天最大时间的一条 ================= */
                 LEFT JOIN ky_test_data_strength tg
                           ON tg.id = (
                               SELECT ts.id
                               FROM ky_test_data_strength ts
                                        JOIN ky_device d ON ts.device_id = d.id
                               WHERE d.device_type_id = 8
                                 AND ts.client_id = ci.client_id
                                 AND DATE(ts.check_date) = ci.end_date
                               ORDER BY ts.check_date DESC
                               LIMIT 1
                           )

        ORDER BY ci.client_id, ci.end_date
    ) s2,

# 第二次心肺测试
    (
        select
            t1.client_id, t1.end_date,
            t2.check_date 检测日期,
            t2.score 得分,
            t2.power 功率,
            t2.static_heart_rate 静息心率,
            t2.exercise_heart_rate 运动最大心率,
            t2.safe_heart_rate 安全心率,
            t2.vo2max 最大摄氧量,
            case
                when(t2.test_method=0) then '2级递增负荷台阶'
                when(t2.test_method=1) then '国民体质台阶'
                when(t2.test_method=2) then '8级递增负荷功率车'
                when(t2.test_method=3) then 'YMCA功率车'
                when(t2.test_method=6) then '6分钟步行'
                when(t2.test_method=7) then '6分钟踏步'
                else null end 测试方法,
            t2.avg_heart1 "平均心率1", t2.avg_heart2 "平均心率2", t2.avg_heart3 "平均心率3", t2.avg_heart4 "平均心率4",
            t2.avg_heart5 "平均心率5", t2.avg_heart6 "平均心率6", t2.avg_heart7 "平均心率7", t2.avg_heart8 "平均心率8",
            t2.power1 一级负荷, t2.power2 二级负荷, t2.power3 三级负荷, t2.power4 四级负荷,
            t2.power5 五级负荷, t2.power6 六级负荷, t2.power7 七级负荷, t2.power8 八级负荷,
            case
                when(t2.project_status=0) then "异常"
                when(t2.project_status=1) then "正常"
                else null
                end 异常状态
        from client_check_intervals t1
                 left join ky_test_data_cardiopulmonary t2
                           on t1.client_id = t2.client_id
                               and substr(t2.check_date, 1, 10) = t1.end_date
                               and t2.check_date = (
                                   select max(check_date)
                                   from ky_test_data_cardiopulmonary t3
                                   where t3.client_id = t1.client_id
                                     and substr(t3.check_date, 1, 10) = t1.end_date
                               )
        order by t1.client_id, t1.end_date
    ) s3
where t1.client_id=f1.client_id and t1.start_date=f1.start_date
  and t1.client_id=f2.client_id and t1.start_date=f2.start_date
  and t1.client_id=f3.client_id and t1.start_date=f3.start_date
  and t1.client_id=s1.client_id and t1.end_date=s1.end_date
  and t1.client_id=s2.client_id and t1.end_date=s2.end_date
  and t1.client_id=s3.client_id and t1.end_date=s3.end_date