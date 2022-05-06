      
#packet_id, stage, user_name, updated, project_name 
SELECT 
  packet_id,
  stage,
  user_id,
  project_name,
  (
    #frm_cnt.packet_id, stage, user_name, project_name, updated,
    CASE
      WHEN frame_count = 0 
      THEN frame_count2 
      ELSE frame_count 
    END
  ) AS frame_count,
  updated
FROM
  (SELECT 
    * 
  FROM
    (SELECT 
      packet_id,
      stage,
      NAME AS user_id,
      updated 
    FROM
      `packet_history` t1 
      INNER JOIN 
        (SELECT 
          id,
          NAME 
        FROM
          `user`) t2 
        ON t1.user_id = t2.id WHERE t1.`updated`<'2022-05-06' AND t1.`updated`>='2022-04-25' AND t1.`stage`="admin_check" AND (t1.operate_type="admin_check_reject" OR t1.operate_type="admin_check_pass")) uname 
    INNER JOIN 
      (SELECT 
        packet.id AS packet_id_1,
        project.name AS project_name 
      FROM
        `packet` 
        INNER JOIN `project` 
      WHERE packet.`project_id` = project.`id`) pname 
      ON uname.packet_id = pname.packet_id_1) u_p_name 
  INNER JOIN # 取packet维度的帧数
    (SELECT 
      packet_id AS frm_cnt_packet_id,
      SUM(frame_count) AS frame_count,
      COUNT(frame_count) AS frame_count2 
    FROM
      `page` 
    GROUP BY packet_id) frm_cnt 
    ON u_p_name.packet_id = frm_cnt.frm_cnt_packet_id 
    #GROUP BY user_id
