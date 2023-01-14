# lilgit - A smol (quick) git status plugin

![lilgit demo](lilgit.gif)

Early on Christmas Eve 2020, @colemickens was kind enough to mention gitstatusd as a way to cut down on prompt-induced command lag in large repos like nixpkgs.

I noticed it was still a little slow, and that it returns a lot of detail I don't use in my prompt--so I wrote lilgit to figure out if I could trade detail for speed. (See [Performance](#performance) for more.)

Merry Christmas.

## How do I try it out?

If you have Nix installed you can open a lilgit ~demo shell by running:

```bash
# if you have nix-command and flakes enabled:
nix develop github:abathur/lilgit

# otherwise, you can use either of the below:
nix develop github:abathur/lilgit --extra-experimental-features 'flakes nix-command'
nix-shell -E 'import (fetchGit { url="https://github.com/abathur/lilgit"; ref="main"; } + "/shell.nix")'
```

Each time you run a command, it'll clearly indicate lilgit's output, and how long it took to generate.

## What does it cover?

Some of the speed comes from what I've left out, so I know it won't work for everyone. I'm happy to discuss cases where you think it is wrong or misleading (especially if we can make it more accurate without a large performance penalty).

It prints a "name", which is:
- blank if not in repo
- branch name if on branch
- `detached @ 11_chars_of_hash` if detached

That name is:
- plain/uncolored if "clean"
- red if it meets my idiomatic sense of "dirty":
    - latest local commit != latest upstream
    - working copy differs from upstream
    - working copy differs from HEAD

## Does this work in $SHELL?

I assume it just works in bash for now, because the MVP depends on bash `coproc`.

I don't see any reason why it shouldn't work in other shells, and I'm [open to help improving the daemonization model](https://github.com/abathur/lilgit/issues/2).

## How do I use this?

> Note: still getting this updated for flakes. If you want to see a full flake example, check out https://github.com/abathur/bashrc.nix.

First you'll need the lilgit package:

```nix
lilgit = import (self.fetchFromGitHub {
  owner = "abathur";
  repo = "lilgit";
  rev = "v0.3.1";
  hash = "sha256-1HDIm9sb4lPfoyn369cbOEI1UcWp3eSk0HEbIp/3NuA=";
}) { };
```

From here, you'll need to:
1. `source lilgit.bash` from your bashrc/profile
2. add `$__lilgit` to your `PS1`
3. add `__go_off_now_lilgit` to an EXIT trap
4. make sure your profile can find lilgit when it runs

There are two main ways to do this last part:
1. add `lilgit` to your system/user packages, and let your profile find lilgit via `PATH` lookup
2. explicitly write/substitute the correct path to lilgit into your profile

The exact steps you'd take to write/substitute it will depend on how you have your bashrc/profile set up.

I personally define a separate package for my bashrc, which looks a little like:
```nix
{ resholve, shellcheck, lilgit }:

resholve.mkDerivation rec {
  version = "unset";
  pname = "bashrc";

  src = ./.;

  installPhase = ''
    install -Dv bashrc $out/bin/bashrc
  '';

  solutions = {
    profile = {
      interpreter = "none";
      inputs = [ lilgit ];
      scripts = [ "bin/bashrc" ];
    };
  };

  doInstallCheck = true;
  installCheckInputs = [ shellcheck ];
  installCheckPhase = ''
    shellcheck -x $out/bin/bashrc
  '';
}
```

## Performance

This isn't a perfect picture, but you can find a benchmark table in each CI run's "performance" job. Here's an example:

```
test                                          status-provider  time   footprint
----                                          ----             ----   ----
'1x clean @ master'                           lilgit.bash      315ms  2276KB
'1x clean @ master'                           gitstatus.bash   865ms  30MB
'1x clean @ master'                           gitparse.bash    1.0s   2924KB
----                                          ----             ----   ----
'1x clean @ detached'                         lilgit.bash      101ms  2276KB
'1x clean @ detached'                         gitstatus.bash   925ms  30MB
'1x clean @ detached'                         gitparse.bash    984ms  2888KB
----                                          ----             ----   ----
'1x clean @ new branch'                       lilgit.bash      218ms  2272KB
'1x clean @ new branch'                       gitstatus.bash   872ms  29MB
'1x clean @ new branch'                       gitparse.bash    352ms  2900KB
----                                          ----             ----   ----
'1x dirty after rm'                           lilgit.bash      259ms  2272KB
'1x dirty after rm'                           gitstatus.bash   803ms  30MB
'1x dirty after rm'                           gitparse.bash    334ms  2880KB
----                                          ----             ----   ----
'1x clean after reset --hard'                 lilgit.bash      251ms  2268KB
'1x clean after reset --hard'                 gitstatus.bash   845ms  30MB
'1x clean after reset --hard'                 gitparse.bash    350ms  2828KB
----                                          ----             ----   ----
'1x dirty after append'                       lilgit.bash      228ms  2284KB
'1x dirty after append'                       gitstatus.bash   824ms  30MB
'1x dirty after append'                       gitparse.bash    359ms  2916KB
----                                          ----             ----   ----
'1x dirty after stage'                        lilgit.bash      224ms  2276KB
'1x dirty after stage'                        gitstatus.bash   885ms  30MB
'1x dirty after stage'                        gitparse.bash    325ms  2908KB
----                                          ----             ----   ----
'1x clean after commit'                       lilgit.bash      193ms  2256KB
'1x clean after commit'                       gitstatus.bash   830ms  30MB
'1x clean after commit'                       gitparse.bash    285ms  2864KB
----                                          ----             ----   ----
'1x dirty after reset --soft w/o upstream'    lilgit.bash      229ms  2276KB
'1x dirty after reset --soft w/o upstream'    gitstatus.bash   800ms  30MB
'1x dirty after reset --soft w/o upstream'    gitparse.bash    322ms  2912KB
----                                          ----             ----   ----
'1x clean after reset --hard w/o upstream'    lilgit.bash      222ms  2264KB
'1x clean after reset --hard w/o upstream'    gitstatus.bash   888ms  30MB
'1x clean after reset --hard w/o upstream'    gitparse.bash    330ms  2940KB
----                                          ----             ----   ----
'1x dirty after reset --soft w/ upstream'     lilgit.bash      102ms  2296KB
'1x dirty after reset --soft w/ upstream'     gitstatus.bash   846ms  30MB
'1x dirty after reset --soft w/ upstream'     gitparse.bash    339ms  2904KB
----                                          ----             ----   ----
'1x dirty after reset --hard w/ upstream'     lilgit.bash      108ms  2288KB
'1x dirty after reset --hard w/ upstream'     gitstatus.bash   872ms  30MB
'1x dirty after reset --hard w/ upstream'     gitparse.bash    368ms  2884KB

test                                          status-provider  time   footprint
----                                          ----             ----   ----
'10x clean @ master'                          lilgit.bash      1.28s  2428KB
'10x clean @ master'                          gitstatus.bash   2.62s  30MB
'10x clean @ master'                          gitparse.bash    8.59s  2900KB
----                                          ----             ----   ----
'10x clean @ detached'                        lilgit.bash      110ms  2288KB
'10x clean @ detached'                        gitstatus.bash   2.75s  30MB
'10x clean @ detached'                        gitparse.bash    2.77s  2916KB
----                                          ----             ----   ----
'10x clean @ new branch'                      lilgit.bash      1.33s  2368KB
'10x clean @ new branch'                      gitstatus.bash   2.71s  30MB
'10x clean @ new branch'                      gitparse.bash    2.23s  2964KB
----                                          ----             ----   ----
'10x dirty after rm'                          lilgit.bash      1.38s  2372KB
'10x dirty after rm'                          gitstatus.bash   2.69s  30MB
'10x dirty after rm'                          gitparse.bash    2.19s  2940KB
----                                          ----             ----   ----
'10x clean after reset --hard'                lilgit.bash      1.38s  2384KB
'10x clean after reset --hard'                gitstatus.bash   2.75s  30MB
'10x clean after reset --hard'                gitparse.bash    2.19s  2948KB
----                                          ----             ----   ----
'10x dirty after append'                      lilgit.bash      1.33s  2380KB
'10x dirty after append'                      gitstatus.bash   2.57s  30MB
'10x dirty after append'                      gitparse.bash    1.98s  2892KB
----                                          ----             ----   ----
'10x dirty after stage'                       lilgit.bash      1.33s  2376KB
'10x dirty after stage'                       gitstatus.bash   2.52s  30MB
'10x dirty after stage'                       gitparse.bash    1.96s  2936KB
----                                          ----             ----   ----
'10x clean after commit'                      lilgit.bash      1.9s   2364KB
'10x clean after commit'                      gitstatus.bash   2.54s  30MB
'10x clean after commit'                      gitparse.bash    1.82s  2928KB
----                                          ----             ----   ----
'10x dirty after reset --soft w/o upstream'   lilgit.bash      1.26s  2344KB
'10x dirty after reset --soft w/o upstream'   gitstatus.bash   2.49s  30MB
'10x dirty after reset --soft w/o upstream'   gitparse.bash    2.2s   2928KB
----                                          ----             ----   ----
'10x clean after reset --hard w/o upstream'   lilgit.bash      1.29s  2356KB
'10x clean after reset --hard w/o upstream'   gitstatus.bash   2.67s  29MB
'10x clean after reset --hard w/o upstream'   gitparse.bash    2.13s  2928KB
----                                          ----             ----   ----
'10x dirty after reset --soft w/ upstream'    lilgit.bash      112ms  2408KB
'10x dirty after reset --soft w/ upstream'    gitstatus.bash   2.56s  30MB
'10x dirty after reset --soft w/ upstream'    gitparse.bash    2.3s   2900KB
----                                          ----             ----   ----
'10x dirty after reset --hard w/ upstream'    lilgit.bash      115ms  2408KB
'10x dirty after reset --hard w/ upstream'    gitstatus.bash   2.48s  30MB
'10x dirty after reset --hard w/ upstream'    gitparse.bash    2.7s   2932KB

test                                          status-provider  time   footprint
----                                          ----             ----   ----
'100x clean @ master'                         lilgit.bash      10.9s  2436KB
'100x clean @ master'                         gitstatus.bash   19.0s  30MB
'100x clean @ master'                         gitparse.bash    1m22s  2980KB
----                                          ----             ----   ----
'100x clean @ detached'                       lilgit.bash      180ms  2296KB
'100x clean @ detached'                       gitstatus.bash   19.5s  30MB
'100x clean @ detached'                       gitparse.bash    19.5s  2928KB
----                                          ----             ----   ----
'100x clean @ new branch'                     lilgit.bash      11.7s  2404KB
'100x clean @ new branch'                     gitstatus.bash   14.0s  30MB
'100x clean @ new branch'                     gitparse.bash    18.5s  2980KB
----                                          ----             ----   ----
'100x dirty after rm'                         lilgit.bash      11.4s  2376KB
'100x dirty after rm'                         gitstatus.bash   13.9s  30MB
'100x dirty after rm'                         gitparse.bash    19.2s  2980KB
----                                          ----             ----   ----
'100x clean after reset --hard'               lilgit.bash      11.7s  2392KB
'100x clean after reset --hard'               gitstatus.bash   13.8s  30MB
'100x clean after reset --hard'               gitparse.bash    18.6s  2964KB
----                                          ----             ----   ----
'100x dirty after append'                     lilgit.bash      11.5s  2376KB
'100x dirty after append'                     gitstatus.bash   13.9s  30MB
'100x dirty after append'                     gitparse.bash    18.4s  2988KB
----                                          ----             ----   ----
'100x dirty after stage'                      lilgit.bash      11.5s  2372KB
'100x dirty after stage'                      gitstatus.bash   13.8s  30MB
'100x dirty after stage'                      gitparse.bash    18.7s  2972KB
----                                          ----             ----   ----
'100x clean after commit'                     lilgit.bash      9.39s  2384KB
'100x clean after commit'                     gitstatus.bash   14.0s  30MB
'100x clean after commit'                     gitparse.bash    15.8s  2956KB
----                                          ----             ----   ----
'100x dirty after reset --soft w/o upstream'  lilgit.bash      11.1s  2396KB
'100x dirty after reset --soft w/o upstream'  gitstatus.bash   13.8s  30MB
'100x dirty after reset --soft w/o upstream'  gitparse.bash    18.4s  2976KB
----                                          ----             ----   ----
'100x clean after reset --hard w/o upstream'  lilgit.bash      11.3s  2400KB
'100x clean after reset --hard w/o upstream'  gitstatus.bash   13.9s  30MB
'100x clean after reset --hard w/o upstream'  gitparse.bash    18.6s  2972KB
----                                          ----             ----   ----
'100x dirty after reset --soft w/ upstream'   lilgit.bash      208ms  2356KB
'100x dirty after reset --soft w/ upstream'   gitstatus.bash   14.0s  30MB
'100x dirty after reset --soft w/ upstream'   gitparse.bash    18.8s  2980KB
----                                          ----             ----   ----
'100x dirty after reset --hard w/ upstream'   lilgit.bash      211ms  2376KB
'100x dirty after reset --hard w/ upstream'   gitstatus.bash   13.9s  30MB
'100x dirty after reset --hard w/ upstream'   gitparse.bash    18.7s  2972KB
```

Notes:
- Each test only pays the startup overhead once, and then runs the prompt-printing function the specified number of times. I've used a few different counts so that it's easier to get a sense of what the fixed startup costs and per-call performance.
- I'm measuring the memory use with the bsd `footprint` command, because it seems to do a good job of measuring the persistent marginal overhead of the daemons (which GNU time was missing). Both gitparse.bash and lilgit.bash can trigger git invocations like `git diff --quiet` and `git status`, which take nearly 15MB against my local nixpkgs checkout according to GNU time. I'll be happy if anyone contributes a more accurate accounting of this.
- The current difference in daemonization models for lilgit and gitstatus mean the reported numbers for both are a bit of a fiction relative to real world uses (lilgitd's per-instance use should be fairly stable--but it will currently run one instance per terminal; gitstatusd may continue to take up more memory as you use it against different repos).
