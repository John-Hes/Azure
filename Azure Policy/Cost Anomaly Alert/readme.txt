I created this cost anomaly policy because there was no built in policy to create this across all subscriptions.  As of August 2025 this does not seem to be a built in policy.
The cost anomaly alerts are not great but they do provide some value in making sure the necessary people are keeping an eye on spend.  

Difficulties:
I believe the viewId and the appropriate syntax caused some trouble with this working exactly as I wanted.


Future updates:
  - I could not get the syntax for the utcNow command to work out with the start and end date so that would be an improvement to make the expiration more future proof.
  - Some subscriptions have additional owners/managers for the subscription and they should also receive these alerts.  Right now I manually add these users after the policy makes the notification.  An improvement would leveraging a tag with that information and including that in the recipients.


