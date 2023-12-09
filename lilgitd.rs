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

use std::{io, path::Path, process::Command};

use gix::{
  head::Kind::{Detached, Symbolic, Unborn},
  remote::Direction,
  Head, Repository,
};
use tokio::signal::unix::{signal, SignalKind};

struct Report {
  is_repo: bool,
  is_dirty: bool,
  description: String,
}

impl Report {
  pub fn new(start_path: &Path) -> Self {
    let repo = match gix::discover(start_path) {
      Ok(val) => val,
      Err(_e) => {
        // not a repo, return early
        return Report {
          is_repo: false,
          is_dirty: false,
          description: "".to_string(),
        };
      }
    };

    let head = repo.head().unwrap();

    let (name, detached) = match head.clone().kind {
      Symbolic(symref) => (symref.name.shorten().to_string(), false),
      Detached {
        target: object_id, ..
      } => (object_id.to_string(), true),
      Unborn(branch_name) => {
        // repo, but no commits; return early
        return Report {
          is_repo: true,
          is_dirty: false,
          description: branch_name.shorten().to_string(),
        };
      }
    };

    return Self {
      is_repo: true,
      is_dirty: dirty(start_path, &repo, detached, &head, &name),
      description: if detached {
        format!("detached @ {:.11}", name)
      } else {
        name.clone()
      },
    };
  }
}

fn dirty(repo_path: &Path, repo: &Repository, detached: bool, head: &Head, name: &String) -> bool {
  if !detached {
    let branch = repo
      .find_reference(name.as_str())
      .expect("should always have a branch (we know repo is true, and that we aren't detached)");

    // TODO: unsure about direction
    let upstream = match branch.remote(Direction::Fetch) {
      Some(Ok(val)) => {
        if head
          .clone()
          .into_peeled_id()
          .expect("head resolves to id")
          .as_ref()
          != repo
            .find_reference(&format!(
              "refs/remotes/{}/{}",
              val.name().expect("unnamed remote?").as_bstr(),
              name
            ))
            .expect("remote reference exists")
            .peel_to_id_in_place()
            .expect("remote ref has an id")
            .as_ref()
        {
          // return early when the branch target doesn't
          // match the upstream's target (i.e., we've
          // used reset to discard a commit)
          return true;
        }
        Some(true)
      }
      None => Some(false),
      Some(Err(_err)) => Some(false),
    };

    /*
    I've tried a few git2 approaches to this and TL;DR:
    Answering this with any sort of diff through libgit2
    is painfully slow on big repos.

    Also stumbled on someone corroborating this observation:
    https://github.com/Kurt-Bonatz/pursue/commit/a8c10a20d91ad19c8a0e799f2a7de3f41ef0a8b3

    TODO: but now that you're switching to gitoxide, it's worth
    figuring out whether these are improved with its idioms.
    */
    let code = if upstream == Some(true) {
      // use upstream
      Command::new("git")
        .arg("-C")
        .arg(repo_path)
        .arg("diff")
        .arg("--quiet")
        .arg("@{u}")
        .status()
    } else {
      // just use HEAD
      Command::new("git")
        .arg("-C")
        .arg(repo_path)
        .arg("diff")
        .arg("--quiet")
        .arg("HEAD")
        .status()
    };
    match code {
      Ok(val) => return !val.success(),
      Err(_e) => return false,
    }
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
      let _ = &args.next();
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
