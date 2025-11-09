# BookSwap App - Demo Video Script (7-12 minutes)

**Setup:** Split screen showing Flutter app (left) and Firebase Console (right)

---

## INTRO (30 seconds)

**[Screen: App welcome screen + Firebase Console dashboard]**

**Script:**
> "Hi, I'm demonstrating BookSwap, a Flutter app where students can exchange textbooks. This demo shows the complete user flow with real-time Firebase backend updates. Let's get started."

---

## SECTION 1: User Authentication (1.5 minutes)

**[Screen: Welcome screen + Firebase Console → Authentication tab]**

### Action 1: Sign Up
**Script:**
> "First, let's create a new account. I'll tap 'Sign in with Email', then 'Sign Up'."

**Do:**
- Tap "Sign in with Email"
- Switch to Sign Up
- Enter: Name: "Alice", Email: "alice@test.com", Password: "test123"
- Tap "Sign Up"

**Point to Firebase:**
> "Notice in Firebase Authentication, Alice's account appears immediately with email verification pending."

**[Show: Firebase Console → Authentication → Users → New user added]**

### Action 2: Email Verification
**Script:**
> "The app sent a verification email. In production, users would verify via email. For demo purposes, the app allows access while unverified."

**[Show: Profile screen showing "Email Not Verified" badge]**

---

## SECTION 2: Posting a Book (2 minutes)

**[Screen: Home screen + Firebase Console → Firestore → books collection]**

### Action 3: Create Book Listing
**Script:**
> "Now Alice will post her first book. I'll tap the plus button."

**Do:**
- Tap floating action button (+)
- Tap "Add Image" → Select book cover image
- Fill form:
  - Title: "Data Structures & Algorithms"
  - Author: "Thomas H. Cormen"
  - Swap For: "Operating Systems textbook"
  - Condition: Select "Like New"
- Tap "Post"

**Point to Firebase:**
> "Watch Firestore. The book document is created instantly with all fields including the base64 image, status set to 'available', and Alice's userId."

**[Show: Firebase Console → Firestore → books → New document with all fields]**

---

## SECTION 3: Viewing & Editing (1.5 minutes)

**[Screen: My Listings + Firebase Console → Firestore → books]**

### Action 4: Edit Book
**Script:**
> "Alice realizes she wants to change the condition. Let's edit the listing."

**Do:**
- Navigate to "My Listings"
- Tap edit icon on the book
- Change condition to "Good"
- Tap "Update"

**Point to Firebase:**
> "In Firestore, the book document updates immediately. The condition field changed from 'Like New' to 'Good'."

**[Show: Firebase Console → Firestore → books → Document updated]**

---

## SECTION 4: Second User & Swap Offer (3 minutes)

**[Screen: Sign out, create second user]**

### Action 5: Create Second User
**Script:**
> "Let's sign out and create a second user, Bob, who wants Alice's book."

**Do:**
- Settings → Sign Out
- Sign up as: Name: "Bob", Email: "bob@test.com", Password: "test123"

**[Show: Firebase Console → Authentication → Second user added]**

### Action 6: Browse & Make Swap Offer
**Script:**
> "Bob browses listings and sees Alice's book. He'll make a swap offer."

**Do:**
- View "Browse Listings" (Alice's book appears)
- Tap "Swap" button on Alice's book
- Confirm swap offer

**Point to Firebase:**
> "Watch two things happen: First, a new document appears in swapOffers collection with status 'pending'. Second, the book's status changes from 'available' to 'pending'."

**[Show: Firebase Console → Firestore → swapOffers → New offer + books → status changed]**

---

## SECTION 5: Swap State Management (2.5 minutes)

**[Screen: Switch back to Alice's account]**

### Action 7: View & Accept Offer
**Script:**
> "Let's switch back to Alice to see the incoming offer."

**Do:**
- Sign out Bob
- Sign in as Alice
- Navigate to Settings → "Received Offers"
- Show pending offer from Bob

**Point to Firebase:**
> "Alice sees Bob's pending offer. Now she'll accept it."

**Do:**
- Tap "Accept" on Bob's offer
- Confirm acceptance

**Point to Firebase:**
> "Watch the atomic update: The offer status changes to 'accepted' AND the book status changes to 'swapped' simultaneously. This is a Firestore batch write ensuring data consistency."

**[Show: Firebase Console → Firestore → swapOffers status: 'accepted' + books status: 'swapped']**

### Action 8: Demonstrate Rejection (Optional)
**Script:**
> "Let me quickly show rejection. I'll post another book and have Bob make another offer."

**Do:**
- Post new book quickly
- Switch to Bob → Make offer
- Switch to Alice → Reject offer

**Point to Firebase:**
> "On rejection, the offer status becomes 'rejected' and the book returns to 'available'."

**[Show: Firebase Console → Status changes]**

---

## SECTION 6: Real-time Chat (1.5 minutes)

**[Screen: Chat screen + Firebase Console → Firestore → chats]**

### Action 9: Chat Between Users
**Script:**
> "Finally, let's test the chat feature. Bob will message Alice."

**Do:**
- As Bob: Tap "Chat" button on Alice's listing
- Type: "Hi, is this book still available?"
- Send message

**Point to Firebase:**
> "A new chat document is created with a deterministic chatId. The message appears in the messages subcollection."

**[Show: Firebase Console → Firestore → chats → New chat + messages subcollection]**

**Do:**
- Switch to Alice
- Navigate to Chats tab
- Open chat with Bob
- Reply: "Yes! Let's arrange the swap."

**Point to Firebase:**
> "Alice's message appears instantly in the subcollection. Both users see real-time updates via StreamBuilder."

**[Show: Firebase Console → New message in subcollection]**

---

## SECTION 7: Delete Book (45 seconds)

**[Screen: My Listings + Firebase Console]**

### Action 10: Delete Listing
**Script:**
> "Finally, let's delete a book listing."

**Do:**
- As Alice: Go to "My Listings"
- Tap delete icon on a book
- Confirm deletion

**Point to Firebase:**
> "The book document is removed from Firestore immediately."

**[Show: Firebase Console → Firestore → books → Document deleted]**

---

## CONCLUSION (30 seconds)

**[Screen: Firebase Console overview]**

**Script:**
> "To summarize: BookSwap demonstrates complete CRUD operations, real-time state management with atomic updates, user authentication with email verification, and live chat functionality. All actions sync instantly with Firebase, ensuring data consistency across users. The app uses Provider for state management, Firestore for the database, and Firebase Auth for security. Thank you for watching."

**[Show: Quick scroll through Firebase collections: users, books, swapOffers, chats]**

---

## TECHNICAL SETUP NOTES

### Before Recording:
1. Clear Firebase data (delete all test users, books, offers, chats)
2. Have two browser windows ready (or use incognito for second user)
3. Prepare 2-3 book cover images
4. Set screen recording to capture both app and Firebase Console
5. Test audio levels

### Screen Layout:
- **Left 60%:** Flutter app (web or mobile emulator)
- **Right 40%:** Firebase Console (keep relevant tab open)

### Timing Breakdown:
- Intro: 0:30
- Authentication: 1:30
- Post Book: 2:00
- Edit Book: 1:30
- Second User + Offer: 3:00
- Swap States: 2:30
- Chat: 1:30
- Delete: 0:45
- Conclusion: 0:30
- **Total: ~10 minutes**

### Pro Tips:
- Speak clearly and at moderate pace
- Pause briefly when showing Firebase updates
- Use cursor/pointer to highlight Firebase changes
- Keep Firebase Console zoomed appropriately for visibility
- If something fails, acknowledge it and retry (shows real-world testing)

---

## ALTERNATIVE: Shorter 7-Minute Version

**Cut these sections:**
- Email verification explanation (just mention it)
- Rejection demo (only show acceptance)
- Reduce chat to 1 message exchange
- Faster transitions between users

**Result:** ~7 minutes covering all required points
