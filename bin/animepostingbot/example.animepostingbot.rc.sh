# animepostingbot.rc.sh
#
# Config file for animepostingbot.sh
# The syntax of this file is bash.


username='username'
password='password'
proto='https://'
server='gs.domain.com'
# URL to which file upload must go
media_upload_url='/api/statusnet/media/upload'
# URL at which we post status message
making_post_url='/api/statuses/update.xml'
# Part of the URL between $server and /$media_id to mention
#   attachments in the status message.
attachment_url='/attachment'
# Number of files to remember in used_files
remember_files=30000
# Comment pause_secs to always run once.
# Leave uncommented to run in cycle.
pause_secs=$((130*83))
# Found files must be older than this number of days
older_than=40
# Qvitter doesn’t make previews for videos, so it’s better
# to attach some picture along with the video.
# Only the filename. Must be in the same directory as the script.
pic_to_attach_with_video=''


 # Say you’d want to post a hundred or two of smug faces at somebody…
#  then you’d probably want to
#  1. Uncomment the line below and edit it.
#     Special message doesn’t print file name, tags and message_additional_text
#  2. Also pass REP variable to the script with the post id, like
#     REP=12345 ./animepostingbot.sh
#     All the following messages should follow in a chain of replies
#     to the last posts.
#  3. Decrease pause_secs above to 5 or pass it as a debug parameter
#     D_pause_secs=5 ./animepostingbot.sh
#  4. Leave only the directory with smug faces in the dir array below.
#
#special_message='@faggot '$'\n'

 # Text to put at the end of the message.
#
#message_additional_text=$'\n'$'\n''!anipics'

# Exclude patterns for `grep -E`
# '*/.Trash-*' and '*/lost+found*' are added automatically.
blacklist=(
	'*pattern1*'
	'*pattern2*'
	'*/exclude_this_directory_completely/*'
	)

# Absolute paths
dirs=(
	'/home/picts/manga'
	'/home/picts/animu'
	)

 # Subfolders, which bear the show name, would look better
#    capitalised – while auxiliary ones like #screens #misc #art
#    should not be capitalised, because they are common and shared
#    between unique tags.
#  This array tells which hastags serve as markers for the ones,
#    that should be capitalised. For example, /home/pictures/animu/
#    is a folder in the $dirs array, and there are ./screens/toradora/
#    inside it. We want to capitalise ‘toradora’, and we know, that
#    it appears before ‘screens’.
#  Capitalised tags will be put each on a separate line.
#
hashtags_capitalise_after=( 'screens' )

 # To avoid the default behaviour
#
#dont_put_each_capitalised_tag_on_a_separate_line=t

 # As subfolders under $dirs will become hashtags, you may want
#  to specify, which should go to the back of the hashtag line
#  Thus,
#    #creens #Mikakunin_de_shinkoukei #art
#  would become
#    #Mikakunin_de_shinkoukei #screens #art
#
hashtags_to_the_back=(
	'art'
	'misc'
	'subs'
	'screens'
	)

 # Some hashtags are undesireable and should be ignored
#
hashtags_to_remove=()

 # If a subfolder has a prefix for convenience,
#  and you would like to not have it in the tag.
#  For example, if some subdirectories have a common prefix
#  ‘meme’, to avoid nesting of 878th directory level.
#
hashtags_prefixes_to_strip=()

 # Make each Nth post contain an image (or a video)
#  with path matching a pattern.
#  Syntax: [index]="pattern", e.g. [20]="Azumanga"
#  will make each 20th post be a picture from Azumanga.
#
post_each_nth_time=()