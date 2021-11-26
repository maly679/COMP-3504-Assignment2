# Inventory Tracking System

This application is designed to view all the items currently in inventory and add an item missing from inventory. 

# How it Works

All items are displayed upon first running the application, and you can search for an item by its Name OR ID.
Also, you can add a new item to the list by manually entering the ID, Name, Quantity, Price and Supplier ID.

On the backend, it connects to an API, of which the docs for are in https://github.com/maly679/COMP-3504-Assignment3.
This is hosted on a Node Server that queries and inserts data into a GCP SQL Instance that uses mySQL.
