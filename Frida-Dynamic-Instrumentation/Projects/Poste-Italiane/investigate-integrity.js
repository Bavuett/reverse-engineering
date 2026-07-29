Java.perform(() => {
  setTimeout(() => {
    console.log("[*] Enumerating loaded classes for integrity/safetynet/attestation matches...");
    Java.enumerateLoadedClasses({
      onMatch: (name) => {
        const lower = name.toLowerCase();
        if (
          lower.includes("integrity") ||
          lower.includes("safetynet") ||
          lower.includes("attest") ||
          lower.includes("playintegrity")
        ) {
          console.log(`[MATCH] ${name}`);
        }
      },
      onComplete: () => {
        console.log("[*] Enumeration complete.");
      },
    });
  }, 5000);
});
