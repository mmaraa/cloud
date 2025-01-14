javascript: (function () {
  navigator.clipboard
    .readText()
    .then(function (text) {
      const allowedDomains = [
        "https://startups.microsoft.com",
        "https://learn.microsoft.com",
        "https://azure.microsoft.com",
        "https://developer.microsoft.com",
        "https://techcommunity.microsoft.com",
        "https://code.visualstudio.com",
        "https://devblogs.microsoft.com",
        "https://cloudblogs.microsoft.com",
      ];
      const startsWithAllowedDomain = allowedDomains.some(function (domain) {
        return text.startsWith(domain);
      });
      if (startsWithAllowedDomain) {
        const modifiedText =
          text.replace(/\/(en-us|fi-fi|sv-se)\//g, "/") +
          "?wt.mc_id=xxxxxx";
        navigator.clipboard
          .writeText(modifiedText)
          .then(function () {
            document.body.style.transition = "background-color 0.3s";
            document.body.style.backgroundColor = "yellow";
            setTimeout(function () {
              document.body.style.backgroundColor = "";
            }, 300);
          })
          .catch(function (err) {
            console.error("Failed to write to clipboard: " + err);
          });
      } else {
        document.body.style.transition = "background-color 0.3s";
        document.body.style.backgroundColor = "red";
        setTimeout(function () {
          document.body.style.backgroundColor = "";
        }, 300);
      }
    })
    .catch(function (err) {
      console.error("Failed to read from clipboard: " + err);
    });
})();
