CACIO
=====

Chess Access ComputerIzed Opponent.

A chess engine by Shawn Chidester <zd3nik@gmail.com>

History
-------

Not only was this my first chess engine, it was how I learned to program.  It was the early 90's.  I was a fan of chess and had just discovered the wonderful world of electronic Bulletin Board Systems (BBS).  After playing chess on a friend's BBS for a while I decided to learn more by hosting my own BBS.  So I got a loan from my grandmother, bought a 16 MHZ 286 with 1 MB of RAM, a 40MB hard drive, and a 24 baud modem.  Then I found a free BBS software package and a free BBS chess door (BBS applications were called "doors").  It turns out the free chess door was terrible.  The engine was okay, but the software itself was horrifically slow and thrashed my hard drive constantly.  So I decided to try writing my own.  I didn't know how to program, but my father just happened to have Turbo Pascal on a set of 3.5 inch floppy disks - I don't know why he had this or how he got it, he wasn't a programmer either.  Anyway, I went to the store and picked up a book on Turbo Pascal and went to work.

Weeks later my own chess door named "Chess Access" was operational.  I've still got the source code lying around, but it's fragmented into so many different versions I don't know which one is the most current, or which one actually works.  If I can get it sorted out I'll include that source code in this project.

Anyway, despite making a laughable "database" for this chess door it managed games perfectly well, was nice and snappy, and it had lots of bells and whistles including a messaging system with a built-in text editor.

The next natural step was to write my own chess engine to go with it.  I really had no idea what I was doing, but I eventually got an engine that did a 1 ply search and played somewhat natural moves.  It used `static exchange evaluation` instead of `quiescence search` (both terms/concepts I would learn many years later).

I couldn't quite figure out on my own how to take it to the next level.  Being a self starter and a complete novice I hadn't quite grasped the concept of recursive algorithms.  Luckily my friend that ran the BBS I mentioned earlier also had his own book store.  And one day while browsing his store I came across "How Computers Play Chess" by David Levy!  Perhaps a year later I had the chess engine you see here, in all its not so glorious glory.

CACIO was tightly integrated into the Chess Access application.  So I stripped it down to just engine and supporting UI code.  Surprizingly I think most of the remaining code is UI related.  The amount of engine code is pretty small.

Bugs are Likely
---------------

There are doubtless many flaws in this engine.  The alpha/beta implementation is particularly suspect.  Be aware I have no immediate plans to fix anything.

If using the arrow keys or number pad doesn't work you can just type in your moves using coordinate notation, e.g. Long Algebraic Notation (LAN).

"?=List Commands" not implemented
---------------------------------

For the faint of heart that don't want to figure out what commands are available by looking at the source code, here they are:

* Press any key to abort computer thinking and self play.  
* Use arrow keys or number pad to select from/to squares.  
* 'A' = Toggle automatic computer reply  
* 'B' = Build position  
* 'C' = Compute  
* 'I' = Invert board  
* 'L' = Set computer level (1 through 8)  
* 'N' = New game  
* 'P' = Self play  
* 'S' = Toggle sound (sound probably won't work though)  
* 'T' = Set max time per computer move  
* '<' = Back 1 move  
* '>' = Forward 1 move  
* 'Z' = Mystery command
* 'X' = Exit  

Copyright and Disclaimer
------------------------

Copyright (c) 1994-2015 Shawn Chidester <zd3nik@gmail.com>

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
