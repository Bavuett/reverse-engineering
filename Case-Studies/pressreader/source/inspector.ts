import Java from "frida-java-bridge";
/// <reference types="frida-gum" />
/*
 * =======================================================================
 * DYNAMIC INSPECTOR (TypeScript)
 * =======================================================================
 * 
 * To compile this file to JavaScript for Frida, run:
 * npm run build
 */

Java.perform(() => {
    console.log("[*] Avvio Ispezione Dinamica su FirebasePerfOkHttpClient (TypeScript)...");
    
    const TargetClass = Java.use("com.google.firebase.perf.network.FirebasePerfOkHttpClient");
    
    TargetClass.a.overloads.forEach((overload: any) => {
        // We use a regular 'function' instead of an arrow function so 'this' and 'arguments' are bound properly by Frida
        overload.implementation = function(this: any) {
            console.log("\n=========================================================");
            console.log("[!] CHIAMATA A FirebasePerfOkHttpClient.a()");
            
            for (let i = 0; i < arguments.length; i++) {
                const arg = arguments[i];
                if (arg === null || arg === undefined) continue;
                
                if (typeof arg === 'object' && arg.$className) {
                    const className: string = arg.$className;
                    console.log(`\n-> Ispeziono Argomento ${i} [Classe: ${className}]`);
                    
                    try {
                        let valStr: string = arg.toString();
                        if (valStr.length > 200) {
                            valStr = valStr.substring(0, 200) + "...";
                        }
                        console.log(`   Valore toString: ${valStr}`);
                    } catch(e) {
                        console.log("   [Impossibile chiamare toString su questo oggetto]");
                    }
                    
                    try {
                        const ArgClassWrapper = Java.use(className);
                        const fields = ArgClassWrapper.class.getDeclaredFields();
                        
                        for (let j = 0; j < fields.length; j++) {
                            const field = fields[j];
                            field.setAccessible(true);
                            
                            const fieldName: string = field.getName();
                            const fieldType: string = field.getType().getName();
                            
                            if (fieldType === "w50.q") {
                                console.log("   [BINGO] Trovato URL interno!");
                                console.log(`   La classe '${className}' e' la nostra classe Request.`);
                                console.log(`   Il campo URL si chiama: '${fieldName}'`);
                            }
                        }
                    } catch(e) {
                        // Ignore reflection errors for objects that cannot be inspected (e.g. arrays)
                    }
                }
            }
            console.log("=========================================================\n");
            
            return overload.apply(this, arguments as any);
        };
    });
});


