// AQUILA - port BeeStation/BeeStation-Hornet#12738 i #13722 (ankiety na role duchów jako alerty)

///The message sent when you sign up to a poll.
#define POLL_RESPONSE_SIGNUP "signup"
///The message sent when you've already signed up for a poll and are trying to sign up again.
#define POLL_RESPONSE_ALREADY_SIGNED "already_signed"
///The message sent when you are not signed up for a poll.
#define POLL_RESPONSE_NOT_SIGNED "not_signed"
///The message sent when you are too late to unregister from a poll.
#define POLL_RESPONSE_TOO_LATE_TO_UNREGISTER "failed_unregister"
///The message sent when you successfully unregister from a poll.
#define POLL_RESPONSE_UNREGISTERED "unregistered"

// POLL_AUTO_ADD_NONE i POLL_AUTO_ADD_GHOSTS są w code/__DEFINES/role_preferences.dm (używa ich core)
