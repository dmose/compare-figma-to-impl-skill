Parallels VM on MacOS Apple Silicon

1. Configure
   - HD: 256G (prob serious overkill for -at least artifact- builds)
   - CPU: 4 proc
   - Memory: 12G (on a 32G MacOS host machine)
   - Set it not to share Mac volumes with the GuestOS(XXXcheck in UI) for security reasons
2. Install MacOS.  Most settings should be pretty obvious or default-y, however, a few notes:
    1. "From download" seems like it could work; I installed it from a local file I downloade from Apple.
    2. Choose "Set up as new" on the "Transfer Your Data to This Mac" screen.
    3. On "Create an account" screen, de-select "Allow computer account password to be reset with Apple Account"
    4. On the "Sign in to your Apple Account" page, select the "Other Sign-in Options" dropdown and choose "Sign-in Later in Settings" for improved security.
    
