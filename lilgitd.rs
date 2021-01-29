/*
 * lilgitd serves as a ~daemon component paired with a shell profile/prompt
 * plugin. The shell plugin prints $PWD to lilgitd's stdin once per prompt
 * and waits for it to print a response on stdout. lilgitd will read-loop on
 * stdin, treat each line as a path, and attempt to print 3 values on stdout
 * as a response:
 * - whether the path is a repo
 * - whether the repo is dirty
 * - a description of the repo's checkout/worktree
 */

use std::{io, path::Path, process::Command, str};

use git2::{ErrorCode::UnbornBranch, Reference, Repository};
use tokio::signal::unix::{signal, SignalKind};

struct Report {
  is_repo: bool,
  is_dirty: bool,
  description: String,
}

impl Report {
  pub fn new(start_path: &Path) -> Self {
    let repo = match Repository::discover(start_path) {
      Ok(val) => val,
      Err(_e) => {
        return Report {
          is_repo: false,
          is_dirty: false,
          description: "".to_string(),
        }
      }
    };
    let head = match repo.head() {
      Ok(head) => head,
      Err(e) => {
        // probably a new repo
        match e.code() {
          UnbornBranch => {
            let msg = e.message();
            // e.message: "reference \'refs/heads/spangles\' not found"
            if msg.starts_with("reference \'refs/heads/") {
              return Report {
                is_repo: true,
                is_dirty: false,
                description: branch_from_unborn_error(msg),
              };
            } else {
              eprintln!("good question, wtf?");
              return Report {
                is_repo: false,
                is_dirty: false,
                description: "error :(".to_string(),
              };
            }
          }
          _ => {
            eprintln!("good question, wtf?");
            return Report {
              is_repo: false,
              is_dirty: false,
              description: "error :(".to_string(),
            };
          }
        }
      }
    };
    let detached = match repo.head_detached() {
      Ok(detached) => detached,
      Err(_e) => false,
    };
    let name = if detached {
      head
        .target()
        .expect("if we've got a head, we've got a target")
        .to_string()
    } else {
      head
        .shorthand()
        .expect("if we've got a head, it's got a shorthand")
        .to_string()
    };

    return Self {
      is_repo: true,
      is_dirty: dirty(start_path, &repo, detached, &head, &name),
      description: description(detached, &name),
    };
  }
}

// extract name from "reference \'refs/heads/spangles\' not found"
fn branch_from_unborn_error(msg: &str) -> String {
  return match msg.strip_prefix("reference \'refs/heads/") {
    Some(val) => match val.strip_suffix("\' not found") {
      Some(val) => val.to_string(),
      None => "".to_string(),
    },
    None => "".to_string(),
  };
}

fn description(detached: bool, name: &str) -> String {
  if detached {
    return format!("detached @ {:.11}", name);
  } else {
    return name.to_string();
  }
}

fn dirty(
  repo_path: &Path,
  repo: &Repository,
  detached: bool,
  head: &Reference,
  name: &str,
) -> bool {
  if !detached {
    let branch = repo
      .find_branch(&name, git2::BranchType::Local)
      .expect("should always have a branch (we know repo is true, and that we aren't detached)");
    /*
    Point of uncertainty/contention:

        @lovesegfault: You should be handling the error, I think. Even if
        just by logging that it happened. Check out tracing and log for
        good crates to do that.

        Alternatively, there's always eprintln!

        @cole-h Prefer writeln!(std::io::stderr(), "msg") over eprintln!
        in order to not panic and instead propagate (or handle) the error.

    I'm less sure (but I may be missing the point). The upstream may just
    not be set, so I don't see it as a real error (but it's a very real
    possibility--not one I can use expect on). It's just a sign we can
    return early.

    As currently implemented, we're running in the background
    (via coproc) of a shell session, so AFAIK anything we print will end up
    showing in the user's terminal.
    */
    match branch.upstream() {
      Ok(val) => {
        if head.target() != val.get().target() {
          return true;
        }
      }
      Err(_err) => {}
    }

    // TODO: try out some alternatives to this to see how they perform

    // The python implementation was outsourcing this to the underlying
    // commands because status and diff were very slow via pygit2. I
    // don't really know if those are just inherently slow in libgit2,
    // or other approaches may be more tractable via rust.

    let mut y = Command::new("git")
      .arg("-C")
      .arg(repo_path)
      .arg("diff")
      .arg("--quiet")
      .arg("@{u}")
      .output()
      .expect("failed to execute process");
    if y.status.code() == Some(128) {
      y = Command::new("git")
        .arg("-C")
        .arg(repo_path)
        .arg("diff")
        .arg("--quiet")
        .arg("HEAD")
        .output()
        .expect("failed to execute process");
    }
    return !y.status.success();
  }
  return false;
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
  let input = io::stdin();
  /*
  very minimal arg handling
  - normal use: call w/o args, write paths to stdin
  -  debug use: each arg treated as a path to check
  */
  let mut args = std::env::args();
  match args.len() {
    // golden path, only arg is $0
    1 => {
      let mut io_stream = signal(SignalKind::io())?;
      // get SIGINT, but do nothing with it (keep ctrl-c from killing us)
      let mut _int_stream = signal(SignalKind::interrupt())?;

      loop {
        // TODO: maybe worth declaring once and clearing
        // i.e. from_shell.clear();
        let mut from_shell = String::new();
        match input.read_line(&mut from_shell) {
          Ok(n) => {
            if n > 3 {
              let arg = from_shell.trim().to_string();
              let out = Report::new(&Path::new(&arg));
              println!(
                "{} {} {}",
                out.is_repo.to_string(),
                out.is_dirty.to_string(),
                out.description
              );
            } else if n == 0 {
              io_stream.recv().await;
            }
          }
          Err(_err) => {
            io_stream.recv().await;
          }
        }
      }
    }
    // a single arg
    2 => {
      let arg = std::env::args().nth(1).expect("repo path");
      let out = Report::new(&Path::new(&arg));
      println!(
        "{} {} {}",
        out.is_repo.to_string(),
        out.is_dirty.to_string(),
        out.description
      );
      Ok(())
    }
    // more than 1 arg
    // Note: only handled separate from 1-arg to print path w/ check
    _ => {
      // skip arg $0
      &args.next();
      // treat all remaining args as paths
      for arg in args {
        let out = Report::new(&Path::new(&arg));
        println!(
          "{} {} {} {}",
          arg, // also print the path alongside each
          out.is_repo.to_string(),
          out.is_dirty.to_string(),
          out.description
        );
      }
      Ok(())
    }
  }
}
