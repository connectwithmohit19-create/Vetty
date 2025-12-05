CREATE TABLE transactions (
    transaction_id      SERIAL PRIMARY KEY,
    buyer_id            INT NOT NULL,
    store_id            INT NOT NULL,
    purchase_time       TIMESTAMP NOT NULL,
    refund_time         TIMESTAMP NULL,
    gross_transaction_value NUMERIC(10,2) NOT NULL
);

CREATE TABLE transaction_items (
    item_id            SERIAL PRIMARY KEY,
    transaction_id     INT NOT NULL REFERENCES transactions(transaction_id),
    item_name          VARCHAR(200) NOT NULL,
    quantity           INT NOT NULL,
    price              NUMERIC(10,2) NOT NULL
);

INSERT INTO transactions
(buyer_id, store_id, purchase_time, refund_time, gross_transaction_value)
VALUES
(1, 10, '2020-10-01 10:00', NULL, 250.00),
(1, 10, '2020-10-05 14:00', '2020-10-06 10:00', 120.00),
(2, 11, '2020-10-02 09:30', NULL, 300.00),
(3, 12, '2020-10-03 16:00', NULL, 180.00),
(3, 12, '2020-10-05 17:00', NULL, 200.00),
(3, 12, '2020-10-07 19:00', '2020-10-12 08:00', 150.00);


INSERT INTO transaction_items
(transaction_id, item_name, quantity, price)
VALUES
(1, 'Shampoo', 2, 50.00),
(1, 'Soap', 1, 150.00),
(2, 'Shampoo', 1, 50.00),
(3, 'Brush', 3, 100.00),
(4, 'Comb', 1, 180.00),
(5, 'Cream', 2, 100.00),
(6, 'Lotion', 1, 150.00);
