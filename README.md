# GitHub Contribution History Randomizer

When I first discovered this tool, I found it fascinating from a technical perspective. This script generates a random number of commits for each day across specified years, creating an artificially populated GitHub contribution graph.

**Important Disclaimer:** I personally do not use this for my own commit history. True growth comes from genuine, consistent effort - not synthetic activity. Trust yourself, keep learning, and build your coding journey authentically.

## What This Script Does

This repository contains a script that demonstrates how Git's timestamp system works by creating backdated commits. For educational purposes, it:

- Creates multiple random commits (1-10) for each day of specified years
- Timestamps each commit with a random time between 8 AM and 8 PM
- Creates actual file changes with unique content for each commit
- Works on macOS/BSD systems (with Linux adaptations available)
- Shows how GitHub's contribution graph responds to backdated commits

## Features

- **Multiple Years**: Supports any year (2019-2023 included by default)
- **Random Commit Counts**: Creates 1-10 commits per day for more realistic patterns
- **Variable Timestamps**: Distributes commits throughout the day
- **Leap Year Handling**: Automatically handles leap years
- **Progress Tracking**: Shows completion status while running

## Requirements

- Git installed and configured
- macOS/BSD environment (with Linux adaptations available)
- A GitHub account
- Basic terminal skills

## Quick Start

1. Create a new repository on GitHub (e.g., `backfill`)
2. Clone it to your local machine
3. Download the all-in-one script
4. Make it executable: `chmod +x backfill.sh`
5. Run it: `./backfill.sh`
6. Push to GitHub: `git push -u origin main`

## Setup Instructions (Detailed)

1. Create a new repository on GitHub (e.g., `backfill`)
2. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/backfill.git
   cd backfill
   ```

3. Download the script file into the repository:
   - `backfill.sh` - the all-in-one script for multiple years

4. Make the script executable:
   ```bash
   chmod +x backfill.sh
   ```

5. Edit the script to specify which years you want to include:
   ```bash
   # Set the years you want to backfill (adjust as needed)
   YEARS=(2019 2020 2021 2022 2023)
   ```

## Usage

### Running the All-in-One Script

```bash
./backfill.sh
```

This script will:
1. Initialize a Git repository if one doesn't exist
2. Generate 1-10 randomized commits for each day of each specified year
3. Show progress updates as it runs
4. Create a natural, varied contribution pattern

### Verify the Commits

Check that your commits appear with the correct dates:
```bash
git log --pretty=format:"%h %ad %s" --date=short | head -20
```

### Push to GitHub

After running the script, push your repository to GitHub:
```bash
git push -u origin main
```

## How It Works

The script:
1. Loops through each day of each specified year
2. For each day:
   - Generates a random number (1-10) of commits
   - Creates a unique file for each commit with random content
   - Sets a random timestamp between 8 AM and 8 PM for each commit
3. Progress is displayed every 30 days
4. Leap years are handled automatically

## Linux Compatibility

If you're using Linux (which uses GNU date instead of BSD date), you need to modify the date calculation line in the script:

Replace:
```bash
date=$(date -j -v+"$((day-1))"d -f "%Y-%m-%d" "${year}-01-01" +"%Y-%m-%d")
```

With:
```bash
date=$(date -d "${year}-01-01 +$((day-1)) days" +"%Y-%m-%d")
```

## Customization

You can customize the script in several ways:

- **Years**: Change the `YEARS` array to include any years you want
- **Commit Range**: Modify the `commit_count` calculation for more or fewer commits
- **Time Range**: Adjust the `random_hour` calculation for different hours
- **Commit Content**: Change what gets written to each file
- **Frequency**: Adjust the randomization to create different patterns

## Example Script

```bash
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
```

## Ethical Considerations

This tool is shared for educational purposes to understand Git's timestamp mechanisms. Remember:

- **Authentic growth** is more valuable than a filled contribution graph
- **Real skill development** comes through consistent practice and learning
- **Employers value** quality contributions and problem-solving ability over quantity
- **The coding community** respects honesty and genuine effort

Your journey as a developer is about the skills you build, not how your profile appears. Stay dedicated to learning, and your GitHub contributions will naturally reflect your growth.

## License

MIT License - Feel free to use, modify, and distribute as needed.