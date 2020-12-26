# lilgit - A smol (quick) git status plugin

![lilgit demo](lilgit.gif)

Early on Christmas Eve, @colemickens was kind enough to mention gitstatusd as a way to cut down on prompt-induced command lag in large repos like nixpkgs.

I in turn was dumb enough to snipe myself by noticing:
- it consumes over 330MB of memory after using it in nixpkgs/
- the first run of gitstatus_query took ~2.6s (vs 2.1 for git status), and subsequent runs were taking ~730ms
- gitstatus_query returns a lot of information I don't use in my prompt (I'm bearish on prompts packed with info that isn't actionable without running other git commands) 

So, I wrote lilgit. Merry Christmas.

## How do I use this?
This is still a pretty rough cut, but I currently:
- including something like [default.nix](default.nix) as a dependency for my bashrc package
- update my bashrc to include
    - `source lilgit.bash` 
    - use `$__lilgit` in my PS1
