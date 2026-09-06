# LC-3 Assembly Authentication & Password Cipher System

An assembly-level user authentication and string manipulation program implemented in **LC-3 (Little Computer 3)** machine architecture. The program provides credential verification, dynamic input sanitization, automated memory clearing, and custom character-level password transformation.

---

## Architectural Overview

The authentication engine operates as an interactive console state machine that manages memory pointers, traps I/O calls, and verifies credentials across a multi-record embedded database.


```


 +-------------------------+
                |   User Enters Name      |
                +-------------------------+
                             |
                   [Length Check <= 16]
                             v
               +---------------------------+
               | Lookup in Credentials DB  |
               +---------------------------+
                   /                   \
            [Found]                   [Not Found]
               |                           |
               v                           v
     +-------------------+       [Increment Attempt Count]
     | Prompt Password   |                 |
     +-------------------+       [Count == 3?] ---> [Halt Program]
               |                           | (< 3)
     [In-Place Cipher]                     v
     (Case-Inversion)            [Clear Input Buffer]
               |                           |
               v                           +---> [Reprompt Name]
     +-------------------+
     | Validate Against  |
     | Stored Ciphertext |
     +-------------------+
        /             \
    [Match]        [Mismatch]
       |               |
       |               +---> [Attempt Count >= 3?] ---> [Halt Program]
       |                                   | (< 3)
       v                                   v
+---------------------+          [Clear Input Buffer]
| Concatenate & Print |                    |
|   "Hello, <User>"   |                    +---> [Reprompt Password]
+---------------------+
       |
    [Halt]

```

---

## Key Features

* **Multi-User Credential Storage**: Maintains a database of user profiles and pre-computed password strings directly in memory (`x326E` through `x3299`).
* **Input Validation & Buffer Guarding**: Enforces a strict 16-character ceiling on input strings using arithmetic boundary checks.
* **Dynamic Memory Clearing**: Includes zero-fill teardown subroutines (`CLEAR1` through `CLEAR4`) that wipe input buffers backward via decrementing pointer offsets on invalid attempts.
* **Case-Inversion Password Cipher**: Implements on-the-fly ASCII transformations before validation:
  * Uppercase letters (`0x41`–`0x5A`) are shifted down by $+32$ (`0x20`).
  * Lowercase letters (`0x61`–`0x7A`) are shifted up by $-32$ via 2's complement negation.
  * Non-alphabetic and special characters remain unchanged.
* **Brute-Force & Attempt Limiter**: Tracks sequential failed attempts with a hard-coded lockout threshold of three tries for both username and password entry stages.
* **String Construction**: Dynamically locates the null terminator of the welcome string and copies the validated username directly into adjacent memory for unified `PUTS` display.

---

## Technical Specifications

| Parameter | Specification | Memory Reference |
| :--- | :--- | :--- |
| **Target Architecture** | LC-3 (Little Computer 3) | Base `.ORIG x3000` |
| **Max String Buffer** | 16 characters (allocated 25 words) | `USER_INPUT` (`x329C`), `PASS_INPUT` (`x32B5`) |
| **Trap Routines Used** | `GETC` (`x20`), `OUT` (`x21`), `PUTS` (`x22`), `HALT` (`x25`) | Standard LC-3 Trap Vector Table |
| **Lockout Limit** | 3 attempts per credential phase | Evaluated at `x3290` / `ERROR_COUNT` |

---

## Default Credential Store

The credentials stored in data memory illustrate the required input mapping based on the cipher transformation:

| Username | Stored Expected Password | Required Console Input | Notes |
| :--- | :--- | :--- | :--- |
| `panteater` | `PETER` | `peter` | Full lower-to-upper translation |
| `qv` | `HELLOTHERE!` | `hellothere!` | Alphabetic inversion; symbol `!` preserved |
| `EECS20` | `HAPPY` / `hAPPy` | `HappY` / `hAAPy` | Mixed-case inversion |

---

## Execution & Simulation

1. **Load Environment**: Open an LC-3 simulator (such as the LC-3 Tools GUI or command-line simulator).
2. **Assemble**: Load `hello-buddy-login.asm` to generate the symbol table and binary object file (`.obj`).
3. **Execute**: Set the Program Counter (`PC`) to `x3000` and initiate execution (`Run`).
4. **Interact**: Provide inputs via the console display as prompted. End string entry using `Enter` (detected via line feed check `xFFF6`).
