Java.perform(function () {
  console.log(`[*] Looking for notorious network packages loaded in memory.`);
  // Enumerate all loaded classes and check if they are network-related.
  Java.enumerateLoadedClasses({
    // Called for each loaded class.
    onMatch: function (className) {
      // Check if the class name contains any of the network-related keywords.
      if (className.toLowerCase().includes("okhttp") ||
        className.toLowerCase().includes("retrofit") ||
        className.toLowerCase().includes("volley") ||
        className.toLowerCase().includes("cronet") ||
        className.toLowerCase().includes("squareup") ||
        className.toLowerCase().includes("apache.http") ||
        className.toLowerCase().includes("urlconnection") ||
        className.toLowerCase().includes("ktor")) {
        console.log(`[*] Found: ${className}`);
      }
    },
    // Called when all loaded classes have been enumerated.
    onComplete: function () {
      console.log(`[*] Done.`);
    }
  });
})
