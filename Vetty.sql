
-- Question 1

SELECT
  date_trunc('month', t.purchase_time) AS month,
  COUNT(*) AS purchases_count
FROM transactions t
WHERE t.refund_time IS NULL   -- or WHERE is_refunded = false
GROUP BY 1
ORDER BY 1;




-- Question 2

WITH oct_tx AS (
  SELECT store_id
  FROM transactions
  WHERE purchase_time >= '2020-10-01'::date
    AND purchase_time <  '2020-11-01'::date   
)
SELECT COUNT(*) AS stores_with_>=5_orders
FROM (
  SELECT store_id, COUNT(*) AS cnt
  FROM oct_tx
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) s;



-- Question 3

SELECT
  store_id,
  MIN(EXTRACT(EPOCH FROM (refund_time - purchase_time)) / 60.0) AS shortest_refund_minutes
FROM transactions
WHERE refund_time IS NOT NULL
  AND refund_time > purchase_time
GROUP BY store_id
ORDER BY store_id;





-- Question 4
SELECT store_id, transaction_id, purchase_time, gross_transaction_value
FROM (
  SELECT
    t.*,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC, transaction_id ASC) AS rn
  FROM transactions t
) x
WHERE rn = 1
ORDER BY store_id;





-- Question 5
WITH first_tx AS (
  SELECT
    transaction_id,
    buyer_id
  FROM (
    SELECT
      transaction_id,
      buyer_id,
      ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC, transaction_id ASC) AS rn
    FROM transactions
  ) t
  WHERE rn = 1
)
SELECT
  ti.item_name,
  SUM(ti.quantity) AS total_qty_ordered_on_first_purchase,
  COUNT(DISTINCT ti.transaction_id) AS num_buyers_who_ordered_item
FROM transaction_items ti
JOIN first_tx f ON ti.transaction_id = f.transaction_id
GROUP BY ti.item_name
ORDER BY total_qty_ordered_on_first_purchase DESC
LIMIT 1;




-- Question 6  (refund must happen within 72 hours of purchase, interpreted as 72 hours)

SELECT
  ti.*,
  t.purchase_time,
  t.refund_time,
  CASE
    WHEN t.refund_time IS NULL THEN false
    WHEN t.refund_time <= t.purchase_time + interval '72 hours' THEN true
    ELSE false
  END AS refund_processable
FROM transaction_items ti
JOIN transactions t ON ti.transaction_id = t.transaction_id;



-- Question 7

WITH non_refunded_tx AS (
  SELECT *
  FROM transactions
  WHERE refund_time IS NULL  
),
ranked_tx AS (
  SELECT
    transaction_id,
    buyer_id,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC, transaction_id ASC) AS buyer_tx_rank
  FROM non_refunded_tx
)
SELECT
  ti.*,
  r.buyer_id,
  r.purchase_time,
  r.buyer_tx_rank
FROM ranked_tx r
JOIN transaction_items ti ON ti.transaction_id = r.transaction_id
WHERE r.buyer_tx_rank = 2
ORDER BY r.buyer_id;




-- Question 8


SELECT buyer_id, purchase_time AS second_purchase_time, transaction_id
FROM (
  SELECT
    buyer_id,
    transaction_id,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC, transaction_id ASC) AS rn
  FROM transactions
) t
WHERE rn = 2
ORDER BY buyer_id;
