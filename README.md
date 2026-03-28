## SQL Murder Mystery Project 

### Project Overview
**Project Title:** SQL Murder Mystery — TechNova: The CEO Office Murder  
**Level:** Beginner  
**Database:** TechNova  
**Dataset / Challenge Source:** Indian Data Club — SQL Murder Mystery Challenge  

This project is based on the **Indian Data Club SQL Murder Mystery Challenge**, where the goal is to solve a case using SQL by following digital clues stored in multiple tables. I approached this challenge like a real investigation: instead of guessing a suspect, I used SQL queries to verify every claim and connect evidence across different data sources until the patterns clearly pointed to one person.

In this project, I created a dedicated database named **TechNova** and built the case environment by setting up multiple related tables:  
- **employees** (who the people are, department, role)  
- **keycard_logs** (who entered which room, and exactly when they entered/exited)  
- **calls** (who called whom, call time, and duration)  
- **alibis** (what location people claimed at a specific time)  
- **evidence** (what was found, where it was found, and when it was recorded)  

After inserting the dataset into these tables, I began the investigation with basic checks to confirm that the tables contain the expected records and that all entities connect properly using employee IDs and time fields. Then the investigation moved step-by-step using SQL queries that narrowed the suspect list logically.

The core of the case revolves around the **CEO Office** incident on **2025-10-15**, especially the critical time window around **20:50–21:00**, and key evidence such as a **fingerprint found at 21:05** and notes about **keycard log mismatch**. I used time-based filtering on keycard logs to find who was present in the CEO Office during the suspected incident window. After identifying entries/exits near the crime timing, I validated statements by comparing **alibi claims** with **actual keycard access logs** to detect inconsistencies.

To strengthen the investigation, I also analyzed phone call activity within the same critical time window (20:40–21:00). The call patterns helped provide additional behavioral evidence (who was active, how many calls were made, who made the longest call), which supported the timeline-based findings from keycard swipes.  

Next, I connected the evidence table to keycard logs by matching the **evidence found_time** with the closest access record in the same room. This helped identify who was most closely associated with the evidence timing. I also checked for anyone who had keycard access to the CEO Office but did not mention that location in their alibi, which is another classic red flag in investigations.

To make the analysis more complete and “case study” style, I included multiple supporting investigation queries such as:  
- who entered CEO Office after 8 PM  
- who recorded an alibi exactly at 20:50  
- whether the “Server Room” alibi is supported by logs  
- who accessed evidence-linked rooms (CEO Office / Server Room)  
- who made multiple calls in the call logs  
- whether anyone who entered CEO Office also made a call that day  

Overall, this project demonstrates how SQL can be used not only for reporting, but also for investigation-style reasoning: **filtering by time windows, joining multiple tables, validating claims vs logs, and building a conclusion based on data**. This beginner case study helped me practice SQL concepts like joins, filtering with timestamps, conditional checks, identifying mismatches, and deriving a final suspect through structured reasoning rather than assumptions.
