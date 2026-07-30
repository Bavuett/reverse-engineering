/*
 * Minimal Frida hook for eu.spaggiari.classevivastudente (ClasseViva)
 * Target: _AuthenticationService.login() — libapp.so + 0x7249bc (Dart AOT, ARM64)
 *
 * Unlike Blutter's own auto-generated blutter_frida.js (a whole-app generic
 * Dart-object decoder, see blutter_frida_register_constants.js), this hooks
 * exactly one call site whose argument type is statically known
 * (_LoginRequestJTO, class id 7911) and reads only its four string fields by
 * fixed offset — no Classes[] table, no generic getObjectValue dispatch.
 *
 * Logs uid/pass/ident/otp in clear, right before login() serializes them and
 * POSTs to rest/v1/auth/login. See
 * ../notes/Hooking-Dart-AOT-Login-With-Frida.md for the full reasoning behind
 * every constant below.
 */

const LOGIN_OFFSET = 0x7249bc;
const HEAP_REG = 'x28'; // this build's heap-base register, see blutter_frida_register_constants.js

let heapBase = null;

function decompress(ptrOrCompressed) {
    // Every heap pointer's upper 32 bits equal heapBase's upper 32 bits by
    // construction (Dart's compressed-pointer heap lives in one 4GB-aligned
    // region) -- so this is correct whether the input was a full 64-bit
    // pointer already (e.g. straight out of a register) or a 32-bit
    // compressed field value padded with unrelated bytes above it.
    return heapBase.add(ptrOrCompressed.toInt32() >>> 0);
}

function readDartString(fieldAddr) {
    const compressed = fieldAddr.readPointer();
    const obj = decompress(compressed).sub(1); // untag: heap pointers have bit 0 set
    const len = obj.add(8).readU32() >>> 1;    // Dart stores length as a Smi (value << 1)
    return obj.add(16).readUtf8String(len);
}

function hookLogin(libapp) {
    const target = libapp.add(LOGIN_OFFSET);
    Interceptor.attach(target, {
        onEnter(args) {
            if (heapBase === null) {
                heapBase = this.context[HEAP_REG].shl(32);
            }

            // Verified straight from Blutter's disassembly of this exact
            // function (authentication_service.dart, SetupParameters
            // comment): at the function's literal entry point, x1 = `this`,
            // x2 = the _LoginRequestJTO argument. EnterFrame's own first two
            // instructions (stp fp,lr,.. / mov fp,sp) don't touch x1/x2, so
            // hooking at the exact entry address (not one instruction later)
            // keeps this true.
            const req = decompress(this.context.x2).sub(1);

            console.log('[login] credentials about to be POSTed to rest/v1/auth/login:');
            console.log('  uid  :', readDartString(req.add(0x8)));
            console.log('  pass :', readDartString(req.add(0xc)));
            console.log('  ident:', readDartString(req.add(0x10)));
            console.log('  otp  :', readDartString(req.add(0x14)));
        }
    });
    console.log(`[*] login() hooked at ${target}`);
}

function waitForLibapp() {
    const mod = Process.findModuleByName('libapp.so');
    if (mod) {
        hookLogin(mod.base);
    } else {
        setTimeout(waitForLibapp, 300);
    }
}

waitForLibapp();
