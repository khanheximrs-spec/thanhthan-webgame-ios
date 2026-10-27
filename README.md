# ThanhThan WebGame - iOS

Source iPhone app using WKWebView to open `https://play.thanhthan.info/`.

**Important:** This is an online web-game wrapper (requires Internet), not the original game source and not an offline port. No signed IPA is contained in this repository.

## Build unsigned IPA with GitHub Actions

1. Upload **all files and directories inside this ZIP**, not the ZIP itself, to the main branch of this GitHub repository. Include the hidden `.github` folder and `.xcodeproj` directory.
2. Commit the files. GitHub Actions workflow `Build ThanhThan iOS IPA` runs on each push to `main`.
3. Open Actions > Build ThanhThan iOS IPA and select the latest run.
4. When the run succeeds, download artifact `ThanhThanWebGame-unsigned-IPA` and extract `ThanhThanWebGame-unsigned.ipa`.
5. Sign the IPA using a valid Apple signing method before installing it on a real iPhone. Do not share Apple credentials.

Compatible deployment target is iOS 15.0 or newer as configured, but not yet device-tested. For access or playback issues, first check that Safari can open the URL.
