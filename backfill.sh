#!/bin/bash

# GitHub Contribution History Backfiller with Random Commit Counts
# This script creates backdated commits for the specified years with:
# - Random number of commits per day (1-10)
# - Random commit times between 8AM-8PM
# - Unique content for each commit

# Set the years you want to backfill (adjust as needed)
YEARS=(2019 2020 2021 2022 2023)

# Function to create a random number of commits for a specific date
create_commits_for_date() {
  local commit_date="$1"
  
  # Generate a random number of commits for this day (1-10)
  # Use modulo of random hex to get a random number between 1 and 10
  local random_hex=$(openssl rand -hex 1)
  local decimal_value=$((16#$random_hex))
  local commit_count=$((($decimal_value % 10) + 1))
  
  echo "Creating $commit_count commits for $commit_date"
  
  # Create the specified number of commits
  for i in $(seq 1 $commit_count); do
    # Create a unique file for this date and commit number
    local filename="history/${commit_date}-${i}.txt"
    mkdir -p history
    
    # Add content to the file
    echo "Backdated entry for ${commit_date} - Commit #${i}" > "$filename"
    echo "Created at: $(date)" >> "$filename"
    echo "Random: $(openssl rand -hex 8)" >> "$filename"
    
    # Stage the file
    git add "$filename"
    
    # Randomize the hour and minute slightly for more realistic distribution
    local random_hour=$((8 + ($RANDOM % 12))) # Between 8 AM and 8 PM
    local random_minute=$(($RANDOM % 60))
    local timestamp=$(printf "%sT%02d:%02d:00" "$commit_date" $random_hour $random_minute)
    
    # Create the commit with explicit date settings
    GIT_AUTHOR_DATE="$timestamp" \
    GIT_COMMITTER_DATE="$timestamp" \
    git commit -m "Update for ${commit_date} - Commit #${i}"
  done
  
  echo "Created $commit_count commits for ${commit_date}"
}

# Ensure we're in a git repository
if [ ! -d .git ]; then
  git init
  echo "# GitHub Contribution History Backfiller" > README.md
  git add README.md
  git commit -m "Initial commit"
fi

# Process each year
for year in "${YEARS[@]}"; do
  echo "==================================="
  echo "Processing year: $year"
  echo "==================================="
  
  # Determine if it's a leap year (2020, 2024, etc.)
  if [ $((year % 4)) -eq 0 ] && [ $((year % 100)) -ne 0 ] || [ $((year % 400)) -eq 0 ]; then
    days_in_year=366
    echo "$year is a leap year with $days_in_year days"
  else
    days_in_year=365
    echo "$year is not a leap year with $days_in_year days"
  fi
  
  # Loop through each day of the year
  for day in $(seq 1 $days_in_year); do
    # Calculate date in YYYY-MM-DD format (macOS/BSD version)
    # For Linux, use: date=$(date -d "${year}-01-01 +$((day-1)) days" +"%Y-%m-%d")
    date=$(date -j -v+"$((day-1))"d -f "%Y-%m-%d" "${year}-01-01" +"%Y-%m-%d")
    
    # Create random commits for this date
    create_commits_for_date "$date"
    
    # Show progress every 30 days
    if [ $((day % 30)) -eq 0 ]; then
      echo "Progress: $day/$days_in_year days for $year"
    fi
  done
  
  echo "Completed all commits for $year"
done

echo "All done! Created backdated commits for all specified years."
echo "Verify with: git log --pretty=format:\"%h %ad %s\" --date=short | head -20"
echo "Push to GitHub with: git push -u origin main"