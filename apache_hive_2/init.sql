CREATE TABLE IF NOT EXISTS utf8_test (
    id INT,
    name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

INSERT INTO utf8_test VALUES
(1, 'Tiếng Việt'),
(2, '日本語'),
(3, '中文'),
(4, '한국어');

SELECT * FROM utf8_test;
