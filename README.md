# Diabetes-Tracker-Project
A mobile app that helps people with Type 1/Type 2 diabetes (and pre-diabetes) manage glucose, diet, activity, and medications. It uses AI to predict short-term blood glucose trends, classify meals from photos and estimate carbs, and offer personalized nudges/coaching in plain language.

The system uses a Flutter mobile interface connected to a Python backend. Meal photos are stored in AWS S3, which triggers AWS Lambda to run AI predictions. 
Results are saved in DynamoDB, enabling real–time feedback and scalability for future deployment.

#How it works:
-User interacts with the Flutter app  > logs glucose, uploads meal photos
-App sends data to Python backend via REST API
-Meal photos are stored in S3
-Lambda runs model > classifies meal, estimate carbs, predicts short-term glucose
-Results are stored in DynamoDB
-Flutter app retrieves predictions and displays them to the user

#Features:
-Quick Meal Logging: snap a photo or scan a barcode to estimate carbs or edit if needed.
-Smart Coaching: simple, timely tips (“A 15-minute walk now could help with blood pressure”).
-Medication & Reminder Hub: track insulin/oral meds; smart reminders tied to meals/trends.
-Time-in-Range Dashboard: daily/weekly stats, streaks
-Activity & Sleep Sync: pulls steps/sleep from phone/watch to improve suggestions.
-AI Insights: Predict likely high/low blood sugar trends based on past logs.



#Requirements:

-Users must be able to create an account and log in.
-The app must allow input of blood sugar values, meals, and notes.
-The system must use AI to give simple predictions or suggestions based on logged data.
-Users must be able to view past entries in charts/tables.
-Notifications/reminders must be available for meals or blood sugar checks.
-The system must generate a simple AI weekly/monthly summary.
-The system must show the predicted blood sugar levels trends and a correlation to meals and medications the user consumes.

