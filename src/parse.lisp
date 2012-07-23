;; command: privmsg,join,part,kick,invite,mode,nick,quit,kill,topic,notice

(clack.util:namespace lircog.parse
  (:use :cl
        :cl-ppcre
        :cl-who
        :alexandria)
  (:import-from :cl-ppcre)
  (:import-from :cl-who)
  (:import-from :alexandria
                :with-gensyms))

(cl-syntax:use-syntax :annot)

(defmacro register-command (name elems regex &rest html)
  (with-gensyms (stream line)
    `(defun ,name (,stream ,line)
       (register-groups-bind ,elems
           (,regex ,line)
         (with-html-output (,stream)
           ,@html)))))

;; 13:38:06 <#ku2010@ircnet:*.jp:issss> まかない食ってんすけど
;; 13:08:00 >#ku2010@ircnet:killi< ahihi
;; 03:03:51 <#kmc-active@kmc:*.jp:_kmc_> <tuda> 別に見るの忘れていて眠れなくて今思い出して見たとかではないぞ！！！！111(寝言
(register-command privmsg (time channel _ nick message)
 "^(\\d{2}:\\d{2}:\\d{2}) [<>]([^:]+):(\\*\\.jp:)?([^<>]+)[<>] (.*)$"
 (:tr
  (:td (str time))
  (:td (str nick))
  (:td (esc message))))

;; 13:38:06 (#ku2010@ircnet:issss) まかない食ってんすけど
;; 13:38:06 )#ku2010@ircnet:killi( pepo-
(register-command notice (time channel _ nick message)
  "^(\\d{2}:\\d{2}:\\d{2}) [()]([^:]+):(\\*\\.jp:)?([^()]+)[()] (.*)$"
  (:tr
   (:td (str time))
   (:td (str nick))
   (:td (esc message))))

;; 10:10:29 + natsugiri (natsugiri!~natsugiri@218-228-195-11f2.kns1.eonet.ne.jp) to #ku2010@ircnet
(register-command join (time nick info channel)
  "^(\\d{2}:\\d{2}:\\d{2}) \\+ ([^\\s]+) \\(([^)]+)\\) to (.+)$"
  (:tr
   (:td (str time))
   (:td :colspan 2
        (esc (format nil "+ ~A (~A)" nick info)))))

;; 02:15:14 - chandos from #kmc-nf@kmc:*.jp (part)
(register-command part (time nick channel reason)
  "^(\\d{2}:\\d{2}:\\d{2}) \\- ([^\\s]+) from ([^\\s]+) (.*)$"
  (:tr
   (:td (str time))
   (:td :colspan 2
        (esc (format nil "- ~A ~A" nick reason)))))

;; 07:15:59 - a by killi from #kmc-cannibalism@kmc:*.jp (no reason)
(register-command kick (time nick by channel reason)
  "^(\\d{2}:\\d{2}:\\d{2}) \\- ([^\\s]+) by ([^\\s]+) from ([^\\s]+) (.*)$"
  (:tr (:td (str time))
       (:td :colspan 2
            (esc (format nil "~A kicked by ~A ~A" nick by reason)))))

;; 03:03:46 Mode by hideya: #ku2010@ircnet +ooo ehaaaaaa isida killi
(register-command mode (time nick channel detail nicks)
  "^(\\d{2}:\\d{2}:\\d{2}) Mode by ([^:]+): ([^\\s]+) ([^\\s]+) (.*)$"
  (:tr (:td (str time))
       (:td :colspan 2
            (esc (format nil "~A ~A ~A" nick detail nicks)))))

;; 11:59:47 wacky_lost -> wacky__
;; 13:20:48 My nick is changed (o -> killi)
(register-command nick (time _ nick new-nick)
  "^(\\d{2}:\\d{2}:\\d{2}) (My nick is changed )?([^\\s]+) \\-\\> ([^\\s]+)$"
  (:tr (:td (str time))
       (:td :colspan 2 (esc (format nil "~A -> ~A" nick new-nick)))))

;; 20:38:35 ! chandos ("Quit")
(register-command quit (time nick reason)
  "^(\\d{2}:\\d{2}:\\d{2}) ! ([^\\s]+) (.*)$"
  (:tr (:td (str time))
       (:td :colspan 2 (esc (format nil "! ~A ~A" nick reason)))))

;; 23:29:48 Topic of channel #ku2010@ircnet by isida: 数理のゴミカスども
(register-command topic (time channel nick topic)
  "^(\\d{2}:\\d{2}:\\d{2}) Topic of channel ([^\\s]+) by ([^:]+): (.*)$"
  (:tr (:td (str time))
       (:td :colspan 2 (esc (format nil "~A set topic ~A" nick topic)))))

@export
(defun parse-one-line (stream str)
  (or
   (loop for command in
         '(privmsg notice join part
           kick mode nick
           quit topic notice)
         for it = (funcall command stream str)
         when it return it)
   (format stream "<font color=\"red\">--PARSE FAILED-- ~A</font>" str)))
