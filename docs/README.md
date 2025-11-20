# Diabetes-Tracker-Project
A mobile app that helps people with Type 1/Type 2 diabetes (and pre-diabetes) manage glucose, diet, activity, and medications. It uses AI to predict short-term blood glucose trends, classify meals from photos and estimate carbs, and offer personalized nudges/coaching in plain language.

The system uses a Flutter mobile interface connected to a Python backend. Meal photos are stored in AWS S3, which triggers AWS Lambda to run AI predictions. 
Results are saved in DynamoDB, enabling real–time feedback and scalability for future deployment.

--------------------------------------
# How it works:

-User interacts with the Flutter app  > logs glucose, uploads meal photos

-App sends data to Python backend via REST API

-Meal photos are stored in S3

-Lambda runs model > classifies meal, estimate carbs, predicts short-term glucose

-Results are stored in DynamoDB

-Flutter app retrieves predictions and displays them to the user

---------------------------------------
# Features:

-Quick Meal Logging: snap a photo or scan a barcode to estimate carbs or edit if needed.

-Smart Coaching: simple, timely tips (“A 15-minute walk now could help with blood pressure”).

-Medication & Reminder Hub: track insulin/oral meds; smart reminders tied to meals/trends.

-Time-in-Range Dashboard: daily/weekly stats, streaks

-Activity & Sleep Sync: pulls steps/sleep from phone/watch to improve suggestions.

-AI Insights: Predict likely high/low blood sugar trends based on past logs.

----------------------------------------
# Requirements:


-Users must be able to create an account and log in.

-The app must allow input of blood sugar values, meals, and notes.

-The system must use AI to give simple predictions or suggestions based on logged data.

-Users must be able to view past entries in charts/tables.

-Notifications/reminders must be available for meals or blood sugar checks.

-The system must generate a simple AI weekly/monthly summary.

-The system must show the predicted blood sugar levels trends and a correlation to meals and medications the user consumes.

-------------------------------------
# How to Run:

1. Download repository by cloning it.
2. use 'cd backend' to get into the /backend folder.
3. run 'py -3.11 -m pip install -r requirements.txt' //Note: any version of python 3.11 will do, and it I had to install it to be able to download the pakages needed to run the app in the requirements.txt.
4. After that run "py -3.11 app.py". This will run the backend part of the app.
5. In another terminal, either on VS code or the CMD, navigate to the /frontend folder by 'cd .../frontend' or just 'cd frontend' if you are already on the project file path. //Note: go to the file path where the project is on.
6. Once you are in the frontend folder, run 'flutter clean'.
7. Run 'flutter pub get'.
8. Finally run 'flutter run'.
9. You will be prompted to either choose chrome, windows/mac, or edge.
10. I usually choose chrome, but it will pop up around 30 seconds to a minute and depends on each computer.
11. Optionally, you can run 'flutter run -d emulator-5564' to run in a virtual phone emulator // Note: Replace emulator-5564 with your emulator name.
12. Use 'flutter devices' to see all the devices you can run, or SEE BELOW on how to create either an ios or android emulator.

# How to create your emulator:

1. Navigate to either android studio or Xcode(IoS emulator)
2. go to device manager and add a device.
3. This will create your own virtual mobile emulator.
4. Start the emulator, and it is ready to go. This will appear in your terminal when typing 'flutter devices'.

