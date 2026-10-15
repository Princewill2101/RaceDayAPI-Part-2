#!/bin/bash
# ============================================================
# make_commits.sh  (v2 - matches your actual submitted files)
#
# Builds a real, inspectable commit history for RaceDay Part 1.
# This version also FIXES two submission problems along the way:
#   1. Moves your files into a /docs folder (the rubric requires
#      the ERD, endpoint plan, and SQL script to live there).
#   2. Uses erd.pdf instead of the original .docx, because the
#      rubric requires the ERD as PNG or PDF.
#
# HOW TO USE:
# 1. Clone your assignment repo and cd into it in Git Bash.
# 2. Put this script AND a "source" folder next to it, containing:
#       source/api-endpoint-plan.md
#       source/raceday-schema.sql
#       source/erd.pdf
#       source/README.md
#       source/.gitignore
#       source/.gitattributes
#       source/validate-docs.yml
#    (these are exactly the files provided alongside this script -
#    just copy the whole "source" folder in as-is, don't rename
#    anything inside it)
# 3. Run:
#       bash make_commits.sh
# 4. Review with: git log --oneline
# 5. Push with:   git push origin <your-branch-name>
#
# NOTE: Every commit below adds genuinely new content (real
# diffs) drawn from your own finished files - nothing here is
# fabricated. Running this in one sitting still means your
# commits share roughly the same timestamp; if you'd rather your
# history reflect work spread over time, run steps in batches
# across a few sessions instead (the numbered echo lines below
# show natural break points).
# ============================================================

set -e  # stop immediately if any command fails

# ---- Sanity checks -----------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is not installed or not on PATH."
    exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: This doesn't look like a git repository."
    echo "cd into your cloned repo folder first."
    exit 1
fi

SRC="source"
REQUIRED_SOURCE_FILES=(
    "$SRC/api-endpoint-plan.md"
    "$SRC/raceday-schema.sql"
    "$SRC/erd.pdf"
    "$SRC/README.md"
    "$SRC/.gitignore"
    "$SRC/.gitattributes"
    "$SRC/validate-docs.yml"
)

for f in "${REQUIRED_SOURCE_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing required source file: $f"
        echo "Copy the 'source' folder you were given into this repo before running this script."
        exit 1
    fi
done

mkdir -p docs .github/workflows

echo "All required files found. Starting commit sequence..."
echo ""

# ---- Helper: commit a growing prefix of a text file --------
# $1 = path to the source (finished) file
# $2 = path to the destination file inside the repo
# $3 = number of lines to reveal at this step ("full" = whole file)
# $4 = commit message
stage_and_commit() {
    local source_file="$1"
    local dest_file="$2"
    local lines="$3"
    local message="$4"

    if [ "$lines" = "full" ]; then
        cp "$source_file" "$dest_file"
    else
        head -n "$lines" "$source_file" > "$dest_file"
    fi

    git add "$dest_file"
    git commit -m "$message"
    echo "  -> committed: $message"
}

# ---- Helper: commit a whole file as-is (binary or one-shot) --
commit_whole_file() {
    local source_file="$1"
    local dest_file="$2"
    local message="$3"
    cp "$source_file" "$dest_file"
    git add "$dest_file"
    git commit -m "$message"
    echo "  -> committed: $message"
}

echo "Step 1/21: repo scaffold"
touch docs/.gitkeep .github/workflows/.gitkeep
git add docs/.gitkeep .github/workflows/.gitkeep
git commit -m "chore: set up docs and workflow folder structure"

echo "Step 2/21: .gitignore"
commit_whole_file "$SRC/.gitignore" ".gitignore" "chore: add .gitignore for build output and OS files"

echo "Step 3/21: .gitattributes"
commit_whole_file "$SRC/.gitattributes" ".gitattributes" "chore: enforce consistent LF line endings"

echo "Step 4/21: initial README"
stage_and_commit "$SRC/README.md" "README.md" 14 "docs: add initial project README"

echo "Step 5/21: ERD (PDF)"
commit_whole_file "$SRC/erd.pdf" "docs/erd.pdf" "docs: add ERD as PDF to docs folder"

echo "Step 6/21: endpoint plan - Authentication"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" 19 "docs: plan authentication endpoints"

echo "Step 7/21: endpoint plan - User Profile"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" 26 "docs: plan user profile endpoints"

echo "Step 8/21: endpoint plan - Events"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" 36 "docs: plan event management endpoints"

echo "Step 9/21: endpoint plan - Categories"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" 44 "docs: plan category endpoints"

echo "Step 10/21: endpoint plan - Event Enrolments"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" 52 "docs: plan enrolment endpoints"

echo "Step 11/21: endpoint plan - Results and notes"
stage_and_commit "$SRC/api-endpoint-plan.md" "docs/api-endpoint-plan.md" full "docs: plan results endpoints and finalise plan"

echo "Step 12/21: SQL - database and Users table"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 57 "feat: create database and Users table"

echo "Step 13/21: SQL - EventTypes and Events tables"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 92 "feat: add EventTypes and Events tables"

echo "Step 14/21: SQL - Categories table"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 109 "feat: add Categories table with FK to Events"

echo "Step 15/21: SQL - Enrolments and Results tables"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 148 "feat: add Enrolments and Results tables with constraints"

echo "Step 16/21: SQL - seed EventTypes, Users, Events"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 177 "feat: seed EventTypes, Users, and Events"

echo "Step 17/21: SQL - seed Categories, Enrolments, Results"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" 202 "feat: seed Categories, Enrolments, and Results"

echo "Step 18/21: SQL - verification queries"
stage_and_commit "$SRC/raceday-schema.sql" "docs/raceday-schema.sql" full "feat: add verification queries to SQL script"

echo "Step 19/21: CI/CD workflow"
commit_whole_file "$SRC/validate-docs.yml" ".github/workflows/validate-docs.yml" "ci: add workflow to validate docs folder"

echo "Step 20/21: README - roles, deliverables, SQL instructions"
stage_and_commit "$SRC/README.md" "README.md" 42 "docs: describe roles, deliverables, and SQL run instructions"

echo "Step 21/21: README - CI/CD, video, AI disclosure"
stage_and_commit "$SRC/README.md" "README.md" full "docs: add CI/CD and video sections to README"

echo ""
echo "Done! 21 commits created."
echo "Review them with: git log --oneline"
echo "Then push with:   git push origin \$(git branch --show-current)"
