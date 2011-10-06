; I like this way of exiting better. :-)
((ViMap insertMap) map:"jf" to:"<esc>")

; easier movement. Who needs top of screen, and bottom of screen??
((ViMap normalMap) map:"L" to:"$")
((ViMap normalMap) map:"H" to:"^")

; ugh... fucking semicolon
((ViMap normalMap) map:";" to:":")


; text hard-wrapping ftw
(global NSMaxRange (do (range) (+ (range first) (range second))))
(global NSBackwardsSearch 4)
(set $textwidth 72) ; set to zero to disable
(if (defined $autoTextWrapEventId)
  (eventManager remove:$autoTextWrapEventId))
(set $autoTextWrapEventId (eventManager on:"didModifyDocument" do:(do (doc range delta)
  ; Only wrap lines when inserting, and only in text documents, not in source code.
  (if (and (gt $textwidth 0) (gt delta 0) (((doc language) name) hasPrefix:"text."))
    ; The range parameter is wrapped in an NSValue object.
    (set range (range rangeValue))
    (set location (range first))
    (set textStorage (doc textStorage))
    (set lineRange (textStorage rangeOfLineAtLocation:location))
    ; Insert a newline if inserting at column > $textwidth.
    (set column (- location (lineRange first)))
    (if (gt column $textwidth)
      ; Find first space before the wrapping column.
      (set preRange `(,(lineRange first) ,$textwidth))
      (set wrapRange ((textStorage string) rangeOfCharacterFromSet:(NSCharacterSet whitespaceCharacterSet)
                                                           options:NSBackwardsSearch
                                                             range:preRange))
      (if (eq (wrapRange first) NSNotFound)
        ; If no space found before, look after.
        (set postRange `(,$textwidth ,(- (NSMaxRange lineRange) $textwidth)))
        (set wrapRange ((textStorage string) rangeOfCharacterFromSet:(NSCharacterSet whitespaceCharacterSet)
                                                             options:0
                                                               range:postRange)))
      ; Replace the whitespace with a newline, if found.
      (unless (eq (wrapRange first) NSNotFound)
        ((doc text) replaceRange:wrapRange withString:"\n")) )))))
