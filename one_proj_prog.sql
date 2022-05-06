SELECT
	project_id
	,project_name
	,STATUS
	,stage
	,SUM(frame_count)
	,SUM(rect)
	,SUM(parallelogram)
	,SUM(segment)
	,SUM(POINT)
	,SUM(line)
	,SUM(AREA)
	,SUM(box)
	,SUM(pointattr)
	,SUM(POLYGON)
FROM
	(SELECT # 题包维度的最后标注结果统计
		t_page_answer.project_name
		,t_page_answer.project_id
		,t_page_answer.packet_id
		,STATUS
		,stage
		,(CASE WHEN frame_count = 0 THEN frame_count2 ELSE frame_count END) AS frame_count
		,rect
		,parallelogram
		,segment
		,POINT
		,line
		,AREA
		,box
		,pointattr
		,POLYGON
		#,t_page_answer.updated
	FROM
		(SELECT # 题包维度的最后标注结果统计
			t2.project_name
			,t2.project_id
			,t1.packet_id
			,SUM(rect) AS rect
			,SUM(parallelogram) AS parallelogram
			,SUM(segment) AS segment
			,SUM(POINT) AS POINT
			,SUM(line) AS line
			,SUM(AREA) AS AREA
			,SUM(box) AS box
			,SUM(pointattr) AS pointattr
			,SUM(POLYGON) AS POLYGON
			#,t2.updated
		FROM
			(SELECT 
				t11.packet_id
				,t11.page_id
				,t11.max_id AS round_id
				,t12.answer
				,t12.round
				,t12.elements
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',1) ,":",-1) AS SIGNED) AS rect
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',2) ,":",-1) AS SIGNED) AS parallelogram
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',3) ,":",-1) AS SIGNED) AS segment
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',4) ,":",-1) AS SIGNED) AS POINT
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',5) ,":",-1) AS SIGNED) AS line
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',6) ,":",-1) AS SIGNED) AS AREA
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',7) ,":",-1) AS SIGNED) AS box
				,CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',8) ,":",-1) AS SIGNED) AS pointattr
				,CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(CAST(t12.elements AS CHAR),',',9) ,":",-1),"}","") AS SIGNED) AS POLYGON 
			FROM
				(SELECT # 找出每个题包里面每个题目的最大id与最大轮次
					packet_id,
					page_id,
					MIN(ROUND) max_round,
					MIN(id) max_id 
				FROM
					(SELECT 
						id,
						packet_id,
						page_id,
						ROUND,
						elements 
					FROM
						`mark_response_answer`
					)t111 
				GROUP BY
					packet_id,
					page_id
				) t11
				INNER JOIN
				(SELECT
					*
				FROM 
					`mark_response_answer`
				)t12
				ON t11.max_id = t12.id
			)t1
			INNER JOIN
			#  这里找到项目名称 
			(SELECT 
				t21.id AS packet_id
				,t21.project_id
				,t22.name AS project_name
				,t21.updated
			FROM
				packet t21 
				INNER JOIN 
				project t22
				ON t21.project_id = t22.id
			#筛选时间区间
			# ·where t21.`updated`>'2021/12/01' and t21.`updated`<'2022/02/28'
			)t2
			ON t1.packet_id = t2.packet_id
		GROUP BY
			t2.project_name
			,t2.project_id
			,t1.packet_id
		)t_page_answer
		LEFT JOIN 
		(SELECT # 取packet维度的帧数
			packet_id
			,SUM(frame_count) AS frame_count
			,COUNT(frame_count) AS frame_count2
		FROM
			`page`
		GROUP BY
			packet_id
		)t_page_frame
		ON t_page_answer.packet_id = t_page_frame.packet_id
		LEFT JOIN
		(SELECT # 取packet维度的状态
			id AS packet_id
			,STATUS
			,stage 
		FROM
			`packet`
		)t_packet
		ON t_page_answer.packet_id = t_packet.packet_id
	)t_answer_final
WHERE project_name LIKE "%百度-环视IPM停车位检测--17517-220415%"
GROUP BY
	project_id
	,project_name
	,STATUS
	,stage
	
