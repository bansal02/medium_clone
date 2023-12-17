# README

Get the demo videos here : 

https://drive.google.com/file/d/1jqtsAzYeCCpPD9XdOFxJmx9Cy3u82apV/view?usp=drive_link

Get the schema explaination video here : 

https://drive.google.com/file/d/10DtrSTE4Cd8e4JhXEz7kJin_VGIX9im5/view?usp=drive_link


Get the video explaining likes and comments here :

https://drive.google.com/file/d/1892IkA5uIQH_Zk-1epnBJPUguD-0lNJs/view?usp=drive_link


## All five levels are complete

Additions made since last submission : 

1. Added name for lists
2. Fixed bugs for update operation (articles, drafts and profile)
3. Added revision history for articles (earlier it was only for drafts). Created seperate endpoints to view history of articles and drafts.
4. Implemented unfollow
5. Implemented logic to expire subscription after 28 days, similar to real world.
6. Created Razorpay skeleton of creating payment order and handling payment callback which can be activated once frontend is ready. The order object is being created with the order ID and amount. Using this, payment will be done from the frontend. After that we have the handle_payment_callback, which will handle the logics for if payment is successful or failed.

A note on speciality and interests : 

Currently, speciality and interests can be set by users themselves. Later on, we can use AI and ML to give suggestions to users for speciality and interests based on the topic of articles they view or the type of articles they write. It would be a clustering problem in ML.