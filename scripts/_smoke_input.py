# Throwaway smoke fixture for the agentic reviewer. DO NOT MERGE.
import os


def pr_supplied_ref() -> str:
    # Attacker-controlled: the PR-supplied ref/title arrives via the environment.
    return os.environ.get("PR_REF", "")
