-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Review crime scene reports from day of incident
SELECT *
FROM crime_scene_reports
WHERE year = 2021
AND month = 7
AND day = 28
;

-- Examine interviews table
SELECT *
FROM interviews
WHERE year = 2021
AND month = 7
AND day >= 28
;

-- Review ATM Transactions from day of crime
SELECT *
FROM atm_transactions
WHERE year = 2021
AND month = 7
AND day = 28
AND atm_location = "Leggett Street"
AND transaction_type = "withdraw"
;

-- UPGRADED with names added
SELECT p.name, a.*
FROM atm_transactions a
JOIN bank_accounts b
ON b.account_number = a.account_number
JOIN people p
ON p.id = b.person_id
WHERE year = 2021
AND month = 7
AND day = 28
AND atm_location = "Leggett Street"
AND transaction_type = "withdraw"
;

-- Check bakery security logs
SELECT *
FROM bakery_security_logs
WHERE year = 2021
AND month = 7
AND day = 28
AND hour < 11
AND hour > 9
AND minute < 25
;

-- Check phone calls on day of incident, lasting less than 1 minute
SELECT pc.*, p.name
FROM phone_calls pc
JOIN people p1
ON p1.phone_number = pc.caller
JOIN people p2
ON p2.phone_number = pc.receiver
WHERE year = 2021
AND month = 7
AND day = 28
AND duration < 60
;

-- UPGRADED with names
SELECT p1.name AS caller_name, pc.caller AS caller_num, p2.name AS receiver_name, pc.receiver AS receiver_num, pc.duration
FROM phone_calls pc
JOIN people p1
ON p1.phone_number = pc.caller
JOIN people p2
ON p2.phone_number = pc.receiver
WHERE year = 2021
AND month = 7
AND day = 28
AND duration < 60
;


-- Check for earliest flight out of Fiftyville on subsequent day
SELECT *
FROM flights f
JOIN airports a1
ON a1.id = f.origin_airport_id
JOIN airports a2
ON a2.id = f.destination_airport_id
WHERE year = 2021
AND month = 7
AND day = 29
ORDER BY hour ASC
LIMIT 1
;

-- Review bank accounts
SELECT *
FROM bank_accounts b
JOIN people p
ON p.id = b.person_id
;

-- Review flight passengers on identified flight
SELECT people.name, p.passport_number, p.seat, people.phone_number
FROM passengers p
JOIN flights f
ON f.id = p.flight_id
JOIN people
ON people.passport_number = p.passport_number
WHERE year = 2021
AND month = 7
AND day = 29
AND flight_id = (
    SELECT f.id
    FROM flights f
    JOIN airports a1
    ON a1.id = f.origin_airport_id
    JOIN airports a2
    ON a2.id = f.destination_airport_id
    WHERE year = 2021
    AND month = 7
    AND day = 29
    ORDER BY hour ASC
    LIMIT 1
    )
-- AND people.phone_number = (
--     SELECT pc.caller
--     FROM phone_calls pc
-- )
ORDER BY f.hour ASC
;



-- FINAL CODE BLOCK
SELECT people.name, p.passport_number, p.seat, people.phone_number
FROM passengers p
JOIN flights f
ON f.id = p.flight_id
JOIN people
ON people.passport_number = p.passport_number
WHERE year = 2021
AND month = 7
AND day = 29
-- xReference w/ Earliest flight out
AND flight_id = (
    SELECT f.id
    FROM flights f
    JOIN airports a1
    ON a1.id = f.origin_airport_id
    JOIN airports a2
    ON a2.id = f.destination_airport_id
    WHERE year = 2021
    AND month = 7
    AND day = 29
    ORDER BY hour ASC
    LIMIT 1
    )
-- xReference w/ Bakery Security Logs (vehicles exiting lot)
AND people.name IN (
    SELECT p.name
    FROM bakery_security_logs b
    JOIN people p
    ON p.license_plate = b.license_plate
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND hour < 11
    AND hour > 9
    AND minute < 25
    AND activity = "exit"
    )
-- xReference w/ Callers
AND people.name IN (
    SELECT p1.name AS caller_name
    FROM phone_calls pc
    JOIN people p1
    ON p1.phone_number = pc.caller
    JOIN people p2
    ON p2.phone_number = pc.receiver
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND duration < 60
    )
-- xReference w/ ATM withdrawal
AND people.name IN (
    SELECT p.name
    FROM atm_transactions a
    JOIN bank_accounts b
    ON b.account_number = a.account_number
    JOIN people p
    ON p.id = b.person_id
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND atm_location = "Leggett Street"
    AND transaction_type = "withdraw"
    )
ORDER BY f.hour ASC
;



-- NOTES
-- DATE: 2021-07-28
-- 280 - Burglary took place at 10:15 AM; 3 witnesses
-- Within 10 minutes of theft, thief into car at (Emma's) bakery parking lot. (check security footage) - Ruth
-- Thief was someone Eugene recognized from ATM on Leggett St, withdrawing money before incident - Eugene
-- Call of less than a minute from thief as leaving bakery. Planning to take earliest flight out of Fiftyville tomorrow (July 29th)
-- First flight on the 29th goes from Fiftyville to LGA in NYC
-- BRUCE is the culprit; Robin the accomplice (Bruce Wayne? Batman and Robin?)




-- REFERENCE
-- | 161 | Ruth | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.                                                                                                                                                                                                                                                                                                                                      |
-- | 162 | Eugene | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.                                                                                                                                                                                                                                                                                                                                                                             |
-- | 163 | Raymond | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.


cat test.sql | sqlite3 fiftyville.db > output.txt