# lilgit - A smol (quick) git status plugin

![lilgit demo](lilgit.gif)

Early on Christmas Eve, @colemickens was kind enough to mention gitstatusd as a way to cut down on prompt-induced command lag in large repos like nixpkgs.

I noticed it was still a little slow, and that it returns a lot of detail I don't use in my prompt--so I wrote lilgit to figure out if I could trade detail for speed. (See [Performance](#performance) for more.)

Merry Christmas.

## What does it cover?
Some of the speed comes from cutting corners, so I know it won't be acceptable for everyone. I'm happy to discuss cases where you think it is wrong or misleading (especially if we can make it more accurate without a large performance penalty). It covers:
- a "name", which is
    - blank if not in repo
    - branch name if on branch
    - `detached @ 11_chars_of_hash` if detached
    - "plain" if clean, and red if dirty
- my idiomatic sense of whether the working copy is ~dirty:
    - latest commit on branch != latest on remote branch
    - working copy differs from upstream
    - working copy differs from HEAD

## How do I use this?
This is still a pretty rough cut, but I currently:
- include something like [default.nix](default.nix) as a dependency for my bashrc package
- update my bashrc to include
    - `source lilgit.bash` 
    - include `$__lilgit` in my PS1

## Performance

This isn't a perfect picture, but you can find a benchmark table in each CI run's "performance" job. Here's an example:

```
test                                          status-provider  time   footprint
----                                          ----             ----   ----
'1x clean @ master'                           lilgit.bash      342ms  12MB
'1x clean @ master'                           gitstatus.bash   786ms  29MB
'1x clean @ master'                           gitparse.bash    932ms  2880KB
----                                          ----             ----   ----
'1x clean @ detached'                         lilgit.bash      215ms  12MB
'1x clean @ detached'                         gitstatus.bash   726ms  29MB
'1x clean @ detached'                         gitparse.bash    953ms  2892KB
----                                          ----             ----   ----
'1x clean @ new branch'                       lilgit.bash      339ms  11MB
'1x clean @ new branch'                       gitstatus.bash   782ms  29MB
'1x clean @ new branch'                       gitparse.bash    366ms  2892KB
----                                          ----             ----   ----
'1x dirty after rm'                           lilgit.bash      340ms  12MB
'1x dirty after rm'                           gitstatus.bash   788ms  29MB
'1x dirty after rm'                           gitparse.bash    327ms  2904KB
----                                          ----             ----   ----
'1x clean after reset --hard'                 lilgit.bash      359ms  11MB
'1x clean after reset --hard'                 gitstatus.bash   777ms  29MB
'1x clean after reset --hard'                 gitparse.bash    352ms  2900KB
----                                          ----             ----   ----
'1x dirty after append'                       lilgit.bash      351ms  11MB
'1x dirty after append'                       gitstatus.bash   779ms  29MB
'1x dirty after append'                       gitparse.bash    363ms  2900KB
----                                          ----             ----   ----
'1x dirty after stage'                        lilgit.bash      327ms  12MB
'1x dirty after stage'                        gitstatus.bash   830ms  29MB
'1x dirty after stage'                        gitparse.bash    317ms  2888KB
----                                          ----             ----   ----
'1x clean after commit'                       lilgit.bash      375ms  12MB
'1x clean after commit'                       gitstatus.bash   801ms  29MB
'1x clean after commit'                       gitparse.bash    299ms  2880KB
----                                          ----             ----   ----
'1x dirty after reset --soft w/o upstream'    lilgit.bash      335ms  12MB
'1x dirty after reset --soft w/o upstream'    gitstatus.bash   818ms  29MB
'1x dirty after reset --soft w/o upstream'    gitparse.bash    321ms  2872KB
----                                          ----             ----   ----
'1x clean after reset --hard w/o upstream'    lilgit.bash      328ms  12MB
'1x clean after reset --hard w/o upstream'    gitstatus.bash   799ms  29MB
'1x clean after reset --hard w/o upstream'    gitparse.bash    380ms  2864KB
----                                          ----             ----   ----
'1x dirty after reset --soft w/ upstream'     lilgit.bash      210ms  12MB
'1x dirty after reset --soft w/ upstream'     gitstatus.bash   759ms  29MB
'1x dirty after reset --soft w/ upstream'     gitparse.bash    339ms  2892KB
----                                          ----             ----   ----
'1x dirty after reset --hard w/ upstream'     lilgit.bash      209ms  12MB
'1x dirty after reset --hard w/ upstream'     gitstatus.bash   788ms  30MB
'1x dirty after reset --hard w/ upstream'     gitparse.bash    354ms  2880KB

test                                          status-provider  time   footprint
----                                          ----             ----   ----
'10x clean @ master'                          lilgit.bash      1.14s  12MB
'10x clean @ master'                          gitstatus.bash   2.56s  29MB
'10x clean @ master'                          gitparse.bash    7.97s  2932KB
----                                          ----             ----   ----
'10x clean @ detached'                        lilgit.bash      215ms  12MB
'10x clean @ detached'                        gitstatus.bash   2.32s  30MB
'10x clean @ detached'                        gitparse.bash    2.45s  2936KB
----                                          ----             ----   ----
'10x clean @ new branch'                      lilgit.bash      1.27s  12MB
'10x clean @ new branch'                      gitstatus.bash   2.32s  29MB
'10x clean @ new branch'                      gitparse.bash    1.87s  2920KB
----                                          ----             ----   ----
'10x dirty after rm'                          lilgit.bash      1.26s  12MB
'10x dirty after rm'                          gitstatus.bash   2.31s  29MB
'10x dirty after rm'                          gitparse.bash    1.90s  2912KB
----                                          ----             ----   ----
'10x clean after reset --hard'                lilgit.bash      1.28s  12MB
'10x clean after reset --hard'                gitstatus.bash   2.30s  29MB
'10x clean after reset --hard'                gitparse.bash    1.92s  2908KB
----                                          ----             ----   ----
'10x dirty after append'                      lilgit.bash      1.26s  12MB
'10x dirty after append'                      gitstatus.bash   2.20s  29MB
'10x dirty after append'                      gitparse.bash    1.83s  2920KB
----                                          ----             ----   ----
'10x dirty after stage'                       lilgit.bash      1.27s  12MB
'10x dirty after stage'                       gitstatus.bash   2.16s  29MB
'10x dirty after stage'                       gitparse.bash    1.86s  2916KB
----                                          ----             ----   ----
'10x clean after commit'                      lilgit.bash      1.12s  12MB
'10x clean after commit'                      gitstatus.bash   2.13s  29MB
'10x clean after commit'                      gitparse.bash    1.68s  2904KB
----                                          ----             ----   ----
'10x dirty after reset --soft w/o upstream'   lilgit.bash      1.24s  12MB
'10x dirty after reset --soft w/o upstream'   gitstatus.bash   2.12s  29MB
'10x dirty after reset --soft w/o upstream'   gitparse.bash    1.83s  2964KB
----                                          ----             ----   ----
'10x clean after reset --hard w/o upstream'   lilgit.bash      1.25s  12MB
'10x clean after reset --hard w/o upstream'   gitstatus.bash   2.23s  29MB
'10x clean after reset --hard w/o upstream'   gitparse.bash    1.85s  2920KB
----                                          ----             ----   ----
'10x dirty after reset --soft w/ upstream'    lilgit.bash      212ms  12MB
'10x dirty after reset --soft w/ upstream'    gitstatus.bash   2.12s  30MB
'10x dirty after reset --soft w/ upstream'    gitparse.bash    1.97s  2888KB
----                                          ----             ----   ----
'10x dirty after reset --hard w/ upstream'    lilgit.bash      211ms  12MB
'10x dirty after reset --hard w/ upstream'    gitstatus.bash   2.12s  30MB
'10x dirty after reset --hard w/ upstream'    gitparse.bash    1.99s  2944KB

test                                          status-provider  time   footprint
----                                          ----             ----   ----
'100x clean @ master'                         lilgit.bash      9.35s  13MB
'100x clean @ master'                         gitstatus.bash   13.2s  29MB
'100x clean @ master'                         gitparse.bash    1m15s  2968KB
----                                          ----             ----   ----
'100x clean @ detached'                       lilgit.bash      278ms  12MB
'100x clean @ detached'                       gitstatus.bash   13.3s  30MB
'100x clean @ detached'                       gitparse.bash    18.1s  2960KB
----                                          ----             ----   ----
'100x clean @ new branch'                     lilgit.bash      11.3s  12MB
'100x clean @ new branch'                     gitstatus.bash   13.6s  29MB
'100x clean @ new branch'                     gitparse.bash    17.6s  2944KB
----                                          ----             ----   ----
'100x dirty after rm'                         lilgit.bash      11.0s  12MB
'100x dirty after rm'                         gitstatus.bash   13.6s  29MB
'100x dirty after rm'                         gitparse.bash    18.2s  2964KB
----                                          ----             ----   ----
'100x clean after reset --hard'               lilgit.bash      11.2s  12MB
'100x clean after reset --hard'               gitstatus.bash   13.7s  29MB
'100x clean after reset --hard'               gitparse.bash    17.9s  2936KB
----                                          ----             ----   ----
'100x dirty after append'                     lilgit.bash      11.2s  12MB
'100x dirty after append'                     gitstatus.bash   13.6s  29MB
'100x dirty after append'                     gitparse.bash    17.9s  2980KB
----                                          ----             ----   ----
'100x dirty after stage'                      lilgit.bash      11.3s  12MB
'100x dirty after stage'                      gitstatus.bash   13.7s  29MB
'100x dirty after stage'                      gitparse.bash    18.0s  2952KB
----                                          ----             ----   ----
'100x clean after commit'                     lilgit.bash      9.60s  12MB
'100x clean after commit'                     gitstatus.bash   13.6s  29MB
'100x clean after commit'                     gitparse.bash    16.0s  2964KB
----                                          ----             ----   ----
'100x dirty after reset --soft w/o upstream'  lilgit.bash      11.1s  12MB
'100x dirty after reset --soft w/o upstream'  gitstatus.bash   13.6s  29MB
'100x dirty after reset --soft w/o upstream'  gitparse.bash    17.4s  2976KB
----                                          ----             ----   ----
'100x clean after reset --hard w/o upstream'  lilgit.bash      11.2s  12MB
'100x clean after reset --hard w/o upstream'  gitstatus.bash   13.8s  30MB
'100x clean after reset --hard w/o upstream'  gitparse.bash    17.7s  2920KB
----                                          ----             ----   ----
'100x dirty after reset --soft w/ upstream'   lilgit.bash      349ms  13MB
'100x dirty after reset --soft w/ upstream'   gitstatus.bash   13.7s  30MB
'100x dirty after reset --soft w/ upstream'   gitparse.bash    19.5s  2960KB
----                                          ----             ----   ----
'100x dirty after reset --hard w/ upstream'   lilgit.bash      338ms  14MB
'100x dirty after reset --hard w/ upstream'   gitstatus.bash   13.6s  30MB
'100x dirty after reset --hard w/ upstream'   gitparse.bash    19.0s  2948KB
```

Notes:
- Each test only pays the startup overhead once, and then runs the prompt-printing function the specified number of times. I've used a few different counts so that it's easier to get a sense of what the fixed startup costs and per-call performance.
- I'm measuring the memory use with the bsd `footprint` command, because it seems to do a good job of measuring the persistent marginal overhead of the daemons (which GNU time was missing). Both gitparse.bash and lilgit.bash can trigger git invocations like `git diff --quiet` and `git status`, which take nearly 15MB against my local nixpkgs checkout according to GNU time. I'll be happy if anyone contributes a more accurate accounting of this.
- The current difference in daemonization models for lilgit and gitstatus mean the reported numbers for both are a bit of a fiction relative to real world uses (lilgitd's per-instance use should be fairly stable--but it will currently run one instance per terminal; gitstatusd may continue to take up more memory as you use it against different repos).
