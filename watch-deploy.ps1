# ==============================================================================
# Low-Poly World Git Auto-Deploy Watcher
# ==============================================================================
# This script monitors your repository for any updates, additions, or fixes,
# automatically commits them, and pushes them to GitHub.
# Since it uses `git status`, it naturally respects your `.gitignore` file.
# ==============================================================================

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [AUTO-DEPLOY] LOW-POLY WORLD - AUTOMATIC DEPLOYMENT WATCHER" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Folder: $($pwd.Path)" -ForegroundColor Yellow
Write-Host " Checking for updates/fixes/adds every 5 seconds..." -ForegroundColor DarkGray
Write-Host " Respects your .gitignore. Press Ctrl+C to terminate." -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

while ($true) {
    # Check git status for modified, untracked, or deleted files
    $changes = git status --porcelain 2>$null

    if ($changes) {
        Write-Host ""
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] >> Detected local modifications:" -ForegroundColor Yellow
        $changes | ForEach-Object {
            Write-Host "   $_" -ForegroundColor DarkYellow
        }

        # Debounce: wait 3 seconds to let concurrent/multiple file writes finish
        Write-Host "Waiting 3 seconds for file writes to settle..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 3

        Write-Host "Staging changes..." -ForegroundColor Cyan
        git add -A

        # Format a dynamic commit message with timestamp and short change summary
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $commitMsg = "Auto-update: $timestamp"

        Write-Host "Committing changes: '$commitMsg'..." -ForegroundColor Cyan
        $commitOutput = git commit -m $commitMsg 2>&1
        Write-Host "   $commitOutput" -ForegroundColor DarkGray

        Write-Host "Pushing to GitHub (origin main)..." -ForegroundColor Cyan
        # Capture stderr and stdout
        $pushOutput = git push origin main 2>&1
        $pushSuccess = $?

        # Check output for typical success indicators or exit code
        if ($pushSuccess -and ($pushOutput -notmatch "fatal:" -and $pushOutput -notmatch "error:")) {
            Write-Host "SUCCESS: Successfully pushed to GitHub!" -ForegroundColor Green
            Write-Host "Vercel & Hetzner VPS builds triggered automatically." -ForegroundColor Green
        } else {
            Write-Host "ERROR: Error occurred during push:" -ForegroundColor Red
            Write-Host "   $pushOutput" -ForegroundColor Red
            Write-Host "Retrying in 15 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 15
        }
        
        Write-Host ""
        Write-Host "Resuming monitoring..." -ForegroundColor DarkGray
    }

    Start-Sleep -Seconds 5
}
