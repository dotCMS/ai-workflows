# Throwaway smoke fixture for the agentic reviewer. DO NOT MERGE.
import subprocess

from _smoke_input import pr_supplied_ref


def show_ref_log() -> None:
    ref = pr_supplied_ref()
    subprocess.run("git log " + ref, shell=True)

# (smoke: re-run on beta.4)

# (smoke: re-run on beta.5 dedup)
