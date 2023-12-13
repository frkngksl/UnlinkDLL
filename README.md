# UnlinkDLL

This repo contains the Nim variant of the old userspace DLL Unlinking/Hiding technique written in Nim.

You can use this code to unlink DLL information from InLoadOrderModuleList, InMemoryOrderModuleList, InInitializationOrderModuleList, and LdrpHashTable double-linked lists for any process.

Note that after unlinking a DLL, you may still see it from Process Hacker or similar tools because these tools can get loaded modules from VAD (Virtual Address Descriptors) instead of these user space lists. You can read the blog post in the Reference section for more details.

# Compiling

You can directly compile the source code with the following command:

`nim c -d:release --opt:size -o:UnlinkDLL.exe Main.nim`

In case you get the error "cannot open file: winim", you should also install winim dependency:

`nimble install winim`

# Reference

- https://blog.christophetd.fr/dll-unlinking/
- http://www.rohitab.com/discuss/topic/41944-module-pebldr-hiding-all-4-methods/