// Excerpt from blutter_out_arm64/blutter_frida.js — Blutter's auto-generated,
// whole-app Frida script for eu.spaggiari.classevivastudente. The full file
// is ~785KB (a `Classes[]` table covering every Dart class in the app, plus a
// generic decoder able to print any object of any class). Only the part that
// matters for this case study is kept: the concrete register roles for THIS
// build, and the two helpers (`decompressPointer`, `getObjectCid`) that
// `Case-Studies/classeviva/hook_login.js` re-derives its own minimal version
// of. See notes/Hooking-Dart-AOT-Login-With-Frida.md for how these were used.

const PointerCompressedEnabled = true;
const CompressedWordSize = 4;
const HeapAddressReg = 'x28';
const NullReg = 'x22';
const StackReg = 'x15';

let HeapAddress = 0;
// this function must be called at least on first interception of Dart function
function init(context) {
    if (HeapAddress === 0) {
        // heap bit register value is not shifted
        HeapAddress = context[HeapAddressReg].shl(32);
    }
}

function isHeapObject(ptr) {
    return (ptr.toInt32() & 1) == 1;
}

function getObjectTag(ptr) {
    const tag = ptr.readU64();
    const objSize = ((tag >> 8) & 0xf) * 8;
    const cid = (tag >> ClassIdTagPos) & ClassIdTagMask;
    return [cid, objSize];
}

function decompressPointer(dptr) {
    if (PointerCompressedEnabled) {
        if (HeapAddress === 0)
            console.error("Uninitialized HeapAddress");
        return HeapAddress.add(dptr.toInt32());
    }
}

function getArg(context, idx) {
    // Note: argument pointer is never compressed
    let stack = context[StackReg];
    return stack.add(8 * idx).readPointer();
}

const ClassIdTagPos = 12;
const ClassIdTagMask = 0xfffff;

const CidNull = 171;
const CidSmi = 60;
const CidString = 94;
const CidTwoByteString = 95;

// Relevant Classes[] entries (of ~thousands) for this investigation:
// {id:94,name:"String",lenOffset:8,dataOffset:16}
// {id:1093,name:"_AuthenticationService",fbitmap:0,sid:45,size:20,argOffset:-1}
// {id:7911,name:"_LoginRequestJTO",fbitmap:0,sid:7910,size:24,argOffset:-1}
