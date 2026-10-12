GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)

/datum/admins/proc/MentorLogSecret()
    var/dat = "<B>Mentor Log<HR></B>"
    for(var/l in GLOB.mentorlog)
        dat += "<li>[l]</li>"

    if(!GLOB.mentorlog.len)
        dat += "Żaden mentor nic w tej rundzie nie zrobił!"
    usr << browse(HTML_SKELETON(dat), "window=mentor_log")
