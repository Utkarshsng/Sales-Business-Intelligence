# Project 1 Python

The production dataset was generated with a fixed random seed so it is reproducible.
Python is intentionally used here for data generation and quality inspection; the core
analytical workflow remains Excel + SQL + Power BI as designed for this project.

Recommended notebook sequence:
1. Load raw tables
2. Profile missing values and duplicates
3. Validate business rules
4. Clean categorical fields
5. Remove/reconcile duplicate transactions
6. Validate numeric ranges
7. Export cleaned tables
8. Produce profiling report
