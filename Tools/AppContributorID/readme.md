# Add Contributor ID

This script modifies URLs from specific Microsoft domains to include a contributor ID. It is designed to be added as a bookmark bar link in your browser.

## How It Works

1. The script reads the current text from the clipboard.
2. It checks if the text starts with one of the allowed domains:
    - `https://startups.microsoft.com`
    - `https://learn.microsoft.com`
    - `https://azure.microsoft.com`
    - `https://developer.microsoft.com`
    - `https://techcommunity.microsoft.com`
    - `https://code.visualstudio.com`
    - `https://devblogs.microsoft.com`
    - `https://cloudblogs.microsoft.com`
3. If the text starts with an allowed domain, it modifies the URL to remove language-specific segments (`/en-us/`, `/fi-fi/`, `/sv-se/`) and appends the contributor ID (`?wt.mc_id=xxxxxxx`).
4. The modified URL is then written back to the clipboard.
5. The background color of the webpage changes to yellow if the URL was successfully modified and copied, or red if the URL was not from an allowed domain.

## How to Use

1. Copy the script from the `AddContributorIdSingleLine.js` file (same content as in `AddContributorId.js`, but at least Edge needs the content without line breaks).
2. Create a new bookmark in your browser.
3. Paste the script into the URL field of the bookmark.
4. Name the bookmark (e.g., "Add Contributor ID").
5. Save the bookmark.

To use the bookmark:
1. Copy a URL from one of the allowed domains to your clipboard.
2. Click the bookmark in your browser's bookmark bar (if your current page is not allowed to use the clipboard, the browser will prompt for permissions on first-time use).
3. The URL in your clipboard will be modified to include the contributor ID.

## How to Change the Contributor ID

1. Open the `AddContributorIdSingleLine.js` file.
2. Locate the line that appends the contributor ID:
    ```javascript
    "?wt.mc_id=xxxxxx";
    ```