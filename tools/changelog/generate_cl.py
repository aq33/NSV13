"""
Generate changelog .yml files from merged pull requests.

The body of the changelog is taken from the PR description, between the `:cl:`
and `/:cl:` markers (see .github/PULL_REQUEST_TEMPLATE.md). The resulting file
is written to html/changelogs/AutoChangeLog-pr-<number>.yml, where
ss13_genchangelog.py later compiles it into html/changelog.html.

This script only writes files to the working tree; committing and pushing is
the job of the caller (.github/workflows/changelog.yml).

Usage:
    python tools/changelog/generate_cl.py                # PRs of $GITHUB_SHA (CI)
    python tools/changelog/generate_cl.py 341 353        # explicit PR numbers
    python tools/changelog/generate_cl.py 9-353          # a range of PR numbers (backfill)

Environment variables:
    GITHUB_REPOSITORY: owner/name of the repository (set by GitHub Actions)
    GITHUB_TOKEN:      token used to read PRs (the workflow token is enough)
    GITHUB_SHA:        commit to look up PRs for, when no PR numbers are given

Tag names and their mapping to changelog prefixes live in tags.yml next to this file.
"""
import os
import re
import sys
from pathlib import Path

import yaml
from github import Auth, Github, GithubException

# Line endings are `\r\n` when the PR was written in the GitHub UI and `\n` when
# it was created through the API or `gh`, so both have to be accepted.
CL_BODY = re.compile(r":cl:(.*?)\r?\n(.+?)\r?\n\s*/:cl:", re.DOTALL)
CL_SPLIT = re.compile(r"^\s*(\w+):\s+(\S.*?)\s*$", re.MULTILINE)

ROOT = Path(__file__).resolve().parents[2]
CL_DIR = ROOT / "html" / "changelogs"


def log(message, level=None):
    """Print a message; in GitHub Actions `level` turns it into an annotation."""
    if level and os.getenv("GITHUB_ACTIONS"):
        print(f"::{level}::{message}")
    else:
        print(message)


def parse_pr_args(args):
    numbers = []
    for arg in args:
        if "-" in arg:
            start, end = arg.split("-", 1)
            numbers.extend(range(int(start), int(end) + 1))
        else:
            numbers.append(int(arg))
    return numbers


def build_changelog(pr, tags):
    """Return the changelog dict for a PR, or None when the PR has no usable :cl: block."""
    body = pr.body or ""
    match = CL_BODY.search(body)
    if not match:
        return None

    author = match.group(1).strip() or pr.user.login
    changes = []
    for tag, text in CL_SPLIT.findall(match.group(2)):
        tag = tag.lower()
        if tag not in tags["tags"]:
            continue
        if text in tags["defaults"].values():  # untouched template line
            continue
        changes.append({tags["tags"][tag]: text})

    if not changes:
        return None

    changelog = {"author": author, "delete-after": True, "changes": changes}
    if pr.merged_at:
        changelog["date"] = pr.merged_at.date()
    return changelog


def write_changelog(pr_number, changelog):
    CL_DIR.mkdir(parents=True, exist_ok=True)
    target = CL_DIR / f"AutoChangeLog-pr-{pr_number}.yml"
    with open(target, "w", encoding="utf-8", newline="\n") as f:
        yaml.safe_dump(changelog, f, allow_unicode=True, sort_keys=False, width=1000)
    return target


def main(argv):
    repo_name = os.getenv("GITHUB_REPOSITORY")
    token = os.getenv("GITHUB_TOKEN")
    if not repo_name:
        log("GITHUB_REPOSITORY is not set", "error")
        return 1

    with open(ROOT / "tools" / "changelog" / "tags.yml", encoding="utf-8") as f:
        tags = yaml.safe_load(f)

    gh = Github(auth=Auth.Token(token)) if token else Github()
    repo = gh.get_repo(repo_name)

    if argv:
        prs = []
        for number in parse_pr_args(argv):
            try:
                pr = repo.get_pull(number)
            except GithubException as e:
                log(f"PR #{number}: {e.data.get('message', e)}", "warning")
                continue
            if pr.merged:
                prs.append(pr)
            else:
                log(f"PR #{number} is not merged, skipping")
    else:
        sha = os.getenv("GITHUB_SHA")
        if not sha:
            log("Neither PR numbers nor GITHUB_SHA given", "error")
            return 1
        prs = [pr for pr in repo.get_commit(sha).get_pulls() if pr.merged]
        if not prs:
            log(f"Commit {sha[:10]} is not a merged pull request, nothing to do", "notice")
            return 0

    written = 0
    for pr in prs:
        changelog = build_changelog(pr, tags)
        if changelog is None:
            log(f"PR #{pr.number} has no changelog entries", "notice")
            continue
        target = write_changelog(pr.number, changelog)
        log(f"PR #{pr.number}: wrote {target.relative_to(ROOT)} ({len(changelog['changes'])} entries)")
        written += 1

    log(f"Done, {written} changelog file(s) written")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
