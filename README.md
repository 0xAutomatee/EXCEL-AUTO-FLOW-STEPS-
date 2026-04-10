# Data Matching Result

| A Retail Order # | B SOFS Order # | A | B | CHECK              | STATUS  |
|------------------|----------------|---|---|--------------------|---------|
| 113139086-1      | 113139086-1    | 1 | 1 | MATCH              | YES     |
| 113139086-10     | 113139086-1    | 2 | 2 | MATCH              | YES     |
| 114217728-1      | 113139086-10   | 3 | 9 | NOT MATCH          | NO      |
| 113139086-1      | 113139086-100  | 4 | 7 | NOT MATCH          | NO      |
| 114207529-1      | 113139086-101  | - | 3 | MATCHED AT LINE 04 | INFO    |
| 114198880-1      | 113139086-102  | 2 | 2 | DUPLICATE          | DUP.    |
| 114196103-1      | 113139086-103  | 0 |10 | UNFOUND            | ERROR   |
| 114185011-1      | 113139086-104  |11 | 0 | UNPAID             | ERROR   |



# Matching Logic

IF A = B AND row aligned
    → MATCH

IF A ≠ B AND both > 0
    → NOT MATCH

IF value exists but different row
    → MATCHED AT LINE XX

IF same value appears multiple times
    → DUPLICATE

IF A = 0 AND B > 0
    → UNFOUND

IF B = 0 AND A > 0
    → UNPAID

IF A IS NULL AND B IS NULL
    → UNKNOWN




# Data Matching Result

| A Retail Order # | B SOFS Order # | CHECK                                 | STATUS |
| ---------------- | -------------- | ------------------------------------- | ------ |
| 113139086-1      | 113139086-1    | MATCH                                 | YES    |
| 113139086-2      | 113139086-2    | MATCH                                 | YES    |
| 114217728-1      | 113139086-10   | NOT MATCH                             | NO     |
| 113139086-101    | 113139086-100  | NOT MATCH                             | NO     |
| 114207529-1      | 113139086-101  | MATCHED AT LINE 04                    | INFO   |
| 114198880-1      | 113139086-102  | DUPLICATE AT LINE 07                  | DUP.   |
| 114196103-1      | 113139086-103  | UNFOUND (Exists in B, not found in A) | ERROR  |
| 114185011-1      | 113139086-104  | UNPAID (Exists in A, not found in B)  | ERROR  |

## Notes

* Matching is based on **Retail Order # (A)** vs **SOFS Order # (B)**
* **MATCH** → Same value in both A and B (same row)
* **NOT MATCH** → Values differ in the same row
* **MATCHED AT LINE XX** → Value exists in another row
* **DUPLICATE AT LINE XX** → Same value appears multiple times
* **UNFOUND** → Exists in B but not in A
* **UNPAID** → Exists in A but not in B
