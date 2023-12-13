import winim

type
  LDR_DATA_TABLE_ENTRY* {.bycopy.} = object
    InLoadOrderModuleList*: LIST_ENTRY
    InMemoryOrderModuleList*: LIST_ENTRY
    InInitializationOrderModuleList*: LIST_ENTRY
    DllBase*: PVOID
    EntryPoint*: PVOID
    SizeOfImage*: ULONG        ##  in bytes
    FullDllName*: UNICODE_STRING
    BaseDllName*: UNICODE_STRING
    Flags*: ULONG              ##  LDR_*
    LoadCount*: USHORT
    TlsIndex*: USHORT
    HashLinks*: LIST_ENTRY
    SectionPointer*: PVOID
    CheckSum*: ULONG
    TimeDateStamp*: ULONG ##     PVOID			LoadedImports;					// seems they are exist only on XP !!!
                        ##     PVOID			EntryPointActivationContext;	// -same-
  PLDR_DATA_TABLE_ENTRY* = ptr LDR_DATA_TABLE_ENTRY

  PEB_LDR_DATA* {.bycopy.} = object
    Length*: ULONG
    Initialized*: BOOLEAN
    SsHandle*: PVOID
    InLoadOrderModuleList*: LIST_ENTRY
    InMemoryOrderModuleList*: LIST_ENTRY
    InInitializationOrderModuleList*: LIST_ENTRY

  PPEB_LDR_DATA* = ptr PEB_LDR_DATA

  PEB* {.bycopy.} = object
    InheritedAddressSpace*: BOOLEAN
    ReadImageFileExecOptions*: BOOLEAN
    BeingDebugged*: BOOLEAN
    Spare*: BOOLEAN
    Mutant*: HANDLE
    ImageBaseAddress*: PVOID
    Ldr*: PPEB_LDR_DATA
    ProcessParameters*: PRTL_USER_PROCESS_PARAMETERS
    SubSystemData*: PVOID
    ProcessHeap*: PVOID
    FastPebLock*: PVOID
    FastPebLockRoutine*: PVOID
    FastPebUnlockRoutine*: PVOID
    EnvironmentUpdateCount*: ULONG
    KernelCallbackTable*: PVOID
    EventLogSection*: PVOID
    EventLog*: PVOID
    FreeList*: PVOID
    TlsExpansionCounter*: ULONG
    TlsBitmap*: PVOID
    TlsBitmapBits*: array[0x2, ULONG]
    ReadOnlySharedMemoryBase*: PVOID
    ReadOnlySharedMemoryHeap*: PVOID
    ReadOnlyStaticServerData*: PVOID
    AnsiCodePageData*: PVOID
    OemCodePageData*: PVOID
    UnicodeCaseTableData*: PVOID
    NumberOfProcessors*: ULONG
    NtGlobalFlag*: ULONG
    Spare2*: array[0x4, BYTE]
    CriticalSectionTimeout*: LARGE_INTEGER
    HeapSegmentReserve*: ULONG
    HeapSegmentCommit*: ULONG
    HeapDeCommitTotalFreeThreshold*: ULONG
    HeapDeCommitFreeBlockThreshold*: ULONG
    NumberOfHeaps*: ULONG
    MaximumNumberOfHeaps*: ULONG
    ProcessHeaps*: ptr PVOID
    GdiSharedHandleTable*: PVOID
    ProcessStarterHelper*: PVOID
    GdiDCAttributeList*: PVOID
    LoaderLock*: PVOID
    OSMajorVersion*: ULONG
    OSMinorVersion*: ULONG
    OSBuildNumber*: ULONG
    OSPlatformId*: ULONG
    ImageSubSystem*: ULONG
    ImageSubSystemMajorVersion*: ULONG
    ImageSubSystemMinorVersion*: ULONG
    GdiHandleBuffer*: array[0x22, ULONG]
    PostProcessInitRoutine*: ULONG
    TlsExpansionBitmap*: ULONG
    TlsExpansionBitmapBits*: array[0x80, BYTE]
    SessionId*: ULONG

  PPEB* = ptr PEB

  NtQueryInformationProcessType* =  proc(hProcess: HANDLE, processInfoClass: int, processInformation: PVOID, processInformationLength: ULONG, returnLength: PULONG):NTSTATUS {.stdcall.}
  