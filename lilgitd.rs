use std::{io, process::Command, str};

use git2::{Reference, Repository};
use libc::{fcntl, getpid};

use tokio::signal::unix::{signal, SignalKind};

struct Report {
    is_repo: bool,
    is_dirty: bool,
    desc: String,
}

fn desc(detached: bool, name: &str) -> String {
    if detached {
        return format!("detached @ {:.11}", name);
    } else {
        return name.to_string();
    }
}

// TODO std::path::{PathBuf} instead of String?
fn dirty(
    repo_path: &String,
    repo: &Repository,
    detached: bool,
    head: &Reference,
    name: &String,
) -> bool {
    if !detached {
        let branch = repo.find_branch(&name, git2::BranchType::Local).unwrap();
        match branch.upstream() {
            Ok(val) => {
                if head.target() != val.get().target() {
                    return true;
                }
            }
            Err(_err) => {}
        }
        /*
        TODO: try out some alternatives to this to see how they perform

        The python implementation was outsourcing this to the underlying
        commands because status and diff were very slow via pygit2. I
        don't really know if those are just inherently slow in libgit2,
        or other approaches may be more tractable via rust.
        */
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
    // TODO
    return false;
}

fn report(start_path: &String) -> Report {
    let repo = match Repository::discover(start_path) {
        Ok(val) => val,
        Err(_err) => {
            return Report {
                is_repo: false,
                is_dirty: false,
                desc: "".to_string(),
            }
        }
    };
    let detached = repo.head_detached().unwrap();
    // let detached = match repo.head_detached() {
    //     Ok(detached) => detached,
    //     Err(e) => false,
    // };
    let head = repo.head().unwrap();
    let name = if detached {
        head.target().unwrap().to_string()
    } else {
        head.shorthand().unwrap().to_string()
    };

    return Report {
        is_repo: true,
        is_dirty: dirty(start_path, &repo, detached, &head, &name),
        desc: desc(detached, &name),
    };
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input = io::stdin();
    let mut args = std::env::args();
    if args.len() == 1 {
        let mut io_stream = signal(SignalKind::io())?;
        // get SIGINT, but do nothing with it (keep ctrl-c from killing us)
        let mut _int_stream = signal(SignalKind::interrupt())?;
        unsafe {
            fcntl(0, libc::F_SETOWN, getpid());
            fcntl(0, libc::F_SETFL, libc::O_ASYNC);
        }
        loop {
            // TODO: maybe worth declaring once and clearing
            // i.e. from_shell.clear();
            let mut from_shell = String::new();
            match input.read_line(&mut from_shell) {
                Ok(n) => {
                    if n > 3 {
                        let out = report(&from_shell.trim().to_string());
                        println!(
                            "{} {} {}",
                            out.is_repo.to_string(),
                            out.is_dirty.to_string(),
                            out.desc
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
    } else if args.len() == 2 {
        let path = std::env::args().nth(1).expect("repo path");
        let out = report(&path);
        println!(
            "{} {} {}",
            out.is_repo.to_string(),
            out.is_dirty.to_string(),
            out.desc
        );
        Ok(())
    } else if args.len() > 2 {
        &args.next();
        for arg in args {
            let out = report(&arg);
            println!(
                "{} {} {} {}",
                arg,
                out.is_repo.to_string(),
                out.is_dirty.to_string(),
                out.desc
            );
        }
        Ok(())
    } else {
        Ok(())
    }
}
