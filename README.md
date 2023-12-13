# UnlinkDLL

This repo contains the Nim variant of DLL Unlinking/Hiding technique written in Nim.

You can use this code to unlink DLL information from InLoadOrderModuleList, InMemoryOrderModuleList, InInitializationOrderModuleList, and LdrpHashTable double-linked lists for any process.

Note that after unlinking a DLL, you may still see it from Process Hacker or similar tools because these tools can get loaded modules from VAD (Virtual Address Descriptors) instead of these user space lists. You can read the blog post in the Reference section for more details.

# Compiling

You can directly compile the source code with the following command:

`nim c -d:release --opt:size -o:UnlinkDLL.exe Main.nim`

In case you get the error "cannot open file: winim", you should also install winim dependency:

`nimble install winim`

# Usage

```
PS C:\Users\Public> .\UnlinkDLL.exe 11872 MaliciousInjectedDll.dll
[+] List of currently loaded modules:
  [-] winver.exe
  [-] ntdll.dll
  [-] KERNEL32.DLL
  [-] KERNELBASE.dll
  [-] USER32.dll
  [-] win32u.dll
  [-] GDI32.dll
  [-] gdi32full.dll
  [-] msvcp_win.dll
  [-] ucrtbase.dll
  [-] msvcrt.dll
  [-] SHELL32.dll
  [-] IMM32.DLL
  [-] comctl32.dll
  [-] uxtheme.dll
  [-] combase.dll
  [-] RPCRT4.dll
  [-] MSCTF.dll
  [-] OLEAUT32.dll
  [-] sechost.dll
  [-] SHLWAPI.dll
  [-] TextShaping.dll
  [-] WINBRAND.dll
  [-] kernel.appcore.dll
  [-] bcryptPrimitives.dll
  [-] textinputframework.dll
  [-] CoreUIComponents.dll
  [-] CoreMessaging.dll
  [-] WS2_32.dll
  [-] SHCORE.dll
  [-] ntmarta.dll
  [-] wintypes.dll
  [-] advapi32.dll
  [-] MaliciousInjectedDll.dll
[+] Specified Dll is successfully unlinked from PEB!
```

<img width="1545" alt="Screenshot 2023-12-13 at 20 30 07" src="https://github.com/frkngksl/UnlinkDLL/assets/26549173/6420a7a2-0e21-4a2a-9748-c9211a45b313">


# Reference

- https://blog.christophetd.fr/dll-unlinking/
- http://www.rohitab.com/discuss/topic/41944-module-pebldr-hiding-all-4-methods/
